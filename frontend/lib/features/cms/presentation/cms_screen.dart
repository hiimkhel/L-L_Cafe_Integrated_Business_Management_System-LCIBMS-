import 'package:flutter/material.dart';
import 'dart:async';
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/core/widgets/admin_header.dart';
import 'package:frontend/core/services/customer/cms_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE
// ─────────────────────────────────────────────────────────────────────────────

const _kBg     = Color(0xFFEFE2C9);
const _kCard   = Color(0xFFFAF6F0);
const _kGreen  = Color(0xFF758C6D);
const _kGreen1 = Color(0xFF3D5A45);
const _kBrown  = Color(0xFFA98258);
const _kDark   = Color(0xFF2D2A26);
const _kWhite  = Colors.white;

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN SHELL
// ─────────────────────────────────────────────────────────────────────────────

class CMSScreen extends StatefulWidget {
  final int activeIndex;
  final VoidCallback onLogout;

  const CMSScreen({
    super.key,
    this.activeIndex = 6,
    required this.onLogout,
  });

  @override
  State<CMSScreen> createState() => _CMSScreenState();
}

class _CMSScreenState extends State<CMSScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Row(
        children: [
          Sidebar(activeIndex: widget.activeIndex, onLogout: widget.onLogout),
          Expanded(
            child: Column(
              children: [
                AdminHeader(title: 'CMS', onLogout: widget.onLogout),
                const Expanded(child: _CMSBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CMS BODY
// ─────────────────────────────────────────────────────────────────────────────

class _CMSBody extends StatefulWidget {
  const _CMSBody();

  @override
  State<_CMSBody> createState() => _CMSBodyState();
}

class _CMSBodyState extends State<_CMSBody> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _btnCtrl   = TextEditingController();

  Map<String, dynamic>? _promo;
  String     _cardType     = 'primary';
  bool       _isPublishing = false;
  bool       _isUploading  = false;
  int?       _uploadedImgId;
  Uint8List? _pickedBytes;
  String?    _existingUrl;

  // ── Draft persistence ─────────────────────────────────────────────────────
  // Stores unsaved edits keyed by card type so switching tabs never loses work.
  // Cleared only after a successful publish.
  final Map<String, Map<String, dynamic>> _drafts = {};

  bool get _isPrimary => _cardType == 'primary';

  static const _cardTypes = {
    'primary':   'Main Card',
    'secondary': 'Secondary Card',
  };

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Auto-save a draft on every keystroke so switching tabs never discards work
    _titleCtrl.addListener(_saveDraft);
    _descCtrl.addListener(_saveDraft);
    _btnCtrl.addListener(_saveDraft);
    _loadPromo(_cardType);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  // ── Draft helpers ─────────────────────────────────────────────────────────

  /// Snapshot the current editor state into _drafts[_cardType].
  void _saveDraft() {
    _drafts[_cardType] = {
      'title':         _titleCtrl.text,
      'description':   _descCtrl.text,
      'buttonText':    _btnCtrl.text,
      'uploadedImgId': _uploadedImgId,
      'pickedBytes':   _pickedBytes,
      'existingUrl':   _existingUrl,
    };
  }

  /// Restore a previously saved draft for [type] into the controllers.
  void _restoreDraft(String type) {
    final draft = _drafts[type];
    if (draft == null) return;
    _titleCtrl.text = draft['title']       as String? ?? '';
    _descCtrl.text  = draft['description'] as String? ?? '';
    _btnCtrl.text   = draft['buttonText']  as String? ?? '';
    _uploadedImgId  = draft['uploadedImgId'] as int?;
    _pickedBytes    = draft['pickedBytes']   as Uint8List?;
    _existingUrl    = draft['existingUrl']   as String?;
  }

  // ── Data ─────────────────────────────────────────────────────────────────

  Future<void> _loadPromo(String type) async {
    try {
      final data = await CmsService.getPromotionByType(type);
      if (!mounted) return;
      setState(() {
        _promo = data;

        if (_drafts.containsKey(type)) {
          // ✅ User has unsaved edits for this card — restore them
          //    instead of blowing them away with API values.
          _restoreDraft(type);
        } else {
          // No draft yet — seed the editor from API data
          _titleCtrl.text = data?['Title']      ?? '';
          _btnCtrl.text   = data?['buttonText'] ?? '';
          _descCtrl.text  = CmsService.extractDescription(data?['description']);
          final rawUrl    = data?['image']?['url'];
          _existingUrl    = rawUrl != null ? CmsService.getFullImageUrl(rawUrl) : null;
          _uploadedImgId  = null;
          _pickedBytes    = null;
        }
      });
    } catch (e) {
      debugPrint('CMS load error: $e');
    }
  }

  // ── Publish ───────────────────────────────────────────────────────────────

  Future<void> _publish() async {
    if (_isPublishing || _promo == null) return;
    setState(() => _isPublishing = true);

    try {
      final id = _promo!['documentId'] ?? _promo!['id'];
      final payload = <String, dynamic>{
        'Title':      _titleCtrl.text,
        'buttonText': _btnCtrl.text,
        'description': [
          {
            'type': 'paragraph',
            'children': [{'type': 'text', 'text': _descCtrl.text}],
          }
        ],
      };
      if (_uploadedImgId != null) payload['image'] = _uploadedImgId;

      final messenger = ScaffoldMessenger.of(context);
      final ok = await CmsService.publishPromotion(id, payload);
      if (!mounted) return;

      messenger
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(ok ? '✓  Promotion published!' : '✗  Publish failed. Try again.'),
          backgroundColor: ok ? _kGreen1 : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));

      if (ok) {
        // ✅ Clear draft — published content is now the source of truth
        _drafts.remove(_cardType);
        setState(() { _uploadedImgId = null; _pickedBytes = null; });
        await _loadPromo(_cardType);
      }
    } catch (e) {
      debugPrint('Publish error: $e');
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  // ── Image upload ──────────────────────────────────────────────────────────

  Future<void> _uploadImage() async {
    const maxBytes = 10 * 1024 * 1024;
    try {
      final result = await FilePicker.pickFiles(type: FileType.image, withData: true);
      if (result == null) return;

      final file = result.files.single;
      if (file.size > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('File too large (${(file.size / 1024 / 1024).toStringAsFixed(1)} MB). Max 10 MB.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }

      setState(() { _isUploading = true; _pickedBytes = file.bytes; });

      final id = await CmsService.uploadFile(file.bytes!, file.name);
      if (!mounted) return;
      setState(() {
        _uploadedImgId = id;
        _isUploading   = false;
      });
      // Save image into draft immediately so a card switch doesn't lose it
      _saveDraft();

      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: const Text('Image uploaded — press Publish to save.'),
          backgroundColor: _kGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _clearImage() {
    setState(() { _uploadedImgId = null; _pickedBytes = null; });
    _saveDraft(); // persist the cleared image into the draft
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopBar(
            cardType:     _cardType,
            cardTypes:    _cardTypes,
            isPublishing: _isPublishing,
            isUploading:  _isUploading,
            canPublish:   _promo != null,
            onCardChange: (v) {
              if (v == null || v == _cardType) return;
              // ✅ Save current edits BEFORE switching cards
              _saveDraft();
              setState(() => _cardType = v);
              _loadPromo(v);
            },
            onPublish: _publish,
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 4,
                  child: _EditPanel(
                    titleCtrl:     _titleCtrl,
                    descCtrl:      _descCtrl,
                    btnCtrl:       _btnCtrl,
                    isUploading:   _isUploading,
                    uploadedImgId: _uploadedImgId,
                    onUpload:      _uploadImage,
                    onClearImage:  _clearImage,
                  ),
                ),

                const SizedBox(width: 24),

                Expanded(
                  flex: 6,
                  child: _PreviewPanel(
                    titleCtrl:   _titleCtrl,
                    descCtrl:    _descCtrl,
                    btnCtrl:     _btnCtrl,
                    pickedBytes: _pickedBytes,
                    existingUrl: _existingUrl,
                    isPrimary:   _isPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String cardType;
  final Map<String, String> cardTypes;
  final bool isPublishing, isUploading, canPublish;
  final ValueChanged<String?> onCardChange;
  final VoidCallback onPublish;

  const _TopBar({
    required this.cardType,
    required this.cardTypes,
    required this.isPublishing,
    required this.isUploading,
    required this.canPublish,
    required this.onCardChange,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(children: [
          Container(
            width: 4, height: 22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topCenter,
                  end: Alignment.bottomCenter, colors: [_kGreen, _kGreen1]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Text('PROMOTION EDITOR',
              style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
                  fontSize: 15, letterSpacing: 0.5, color: _kGreen1)),
        ]),

        const SizedBox(width: 24),

        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _kWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kGreen.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: _kDark.withOpacity(0.05),
                blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: cardType,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kGreen, size: 18),
              style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700,
                  fontSize: 13, color: _kDark),
              items: cardTypes.entries.map((e) => DropdownMenuItem(
                value: e.key,
                child: Row(children: [
                  Icon(e.key == 'primary' ? Icons.web_rounded : Icons.view_sidebar_rounded,
                      size: 16, color: _kGreen),
                  const SizedBox(width: 8),
                  Text(e.value),
                ]),
              )).toList(),
              onChanged: isPublishing ? null : onCardChange,
            ),
          ),
        ),

        const Spacer(),

        if (isUploading)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(children: [
              const SizedBox(width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _kBrown)),
              const SizedBox(width: 8),
              Text('Uploading image…', style: TextStyle(fontFamily: 'Urbanist',
                  fontSize: 12, color: _kBrown.withOpacity(0.8))),
            ]),
          ),

        GestureDetector(
          onTap: (canPublish && !isPublishing && !isUploading) ? onPublish : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              gradient: (canPublish && !isPublishing && !isUploading)
                  ? const LinearGradient(colors: [_kGreen, _kGreen1]) : null,
              color: (canPublish && !isPublishing && !isUploading)
                  ? null : _kDark.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              boxShadow: (canPublish && !isPublishing && !isUploading)
                  ? [BoxShadow(color: _kGreen.withOpacity(0.35),
                      blurRadius: 10, offset: const Offset(0, 4))]
                  : [],
            ),
            child: isPublishing
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: _kWhite))
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.publish_rounded, size: 16,
                        color: (canPublish && !isUploading)
                            ? _kWhite : _kDark.withOpacity(0.3)),
                    const SizedBox(width: 8),
                    Text('PUBLISH',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.2,
                          color: (canPublish && !isUploading)
                              ? _kWhite : _kDark.withOpacity(0.3),
                        )),
                  ]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT PANEL
// ─────────────────────────────────────────────────────────────────────────────

class _EditPanel extends StatelessWidget {
  final TextEditingController titleCtrl, descCtrl, btnCtrl;
  final bool isUploading;
  final int? uploadedImgId;
  final VoidCallback onUpload, onClearImage;

  const _EditPanel({
    required this.titleCtrl,
    required this.descCtrl,
    required this.btnCtrl,
    required this.isUploading,
    required this.uploadedImgId,
    required this.onUpload,
    required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGreen.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: _kDark.withOpacity(0.05),
            blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeading(icon: Icons.edit_note_rounded, label: 'EDIT CONTENT'),
          const SizedBox(height: 22),

          _FieldLabel(label: 'TITLE'),
          const SizedBox(height: 6),
          _InputBox(controller: titleCtrl, hint: 'Enter promotion title…',
              maxLines: 1, fontSize: 16),
          const SizedBox(height: 16),

          _FieldLabel(label: 'DESCRIPTION'),
          const SizedBox(height: 6),
          Expanded(
            child: _InputBox(controller: descCtrl,
                hint: 'Enter promotion description…',
                maxLines: null, expands: true, fontSize: 13),
          ),
          const SizedBox(height: 16),

          _FieldLabel(label: 'BUTTON TEXT'),
          const SizedBox(height: 6),
          _InputBox(controller: btnCtrl, hint: 'e.g. ORDER NOW',
              maxLines: 1, fontSize: 14),
          const SizedBox(height: 16),

          _FieldLabel(label: 'BANNER IMAGE'),
          const SizedBox(height: 6),
          _ImageUploadTile(
            isUploading:   isUploading,
            uploadedImgId: uploadedImgId,
            onUpload:      onUpload,
            onClear:       onClearImage,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREVIEW PANEL
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewPanel extends StatelessWidget {
  final TextEditingController titleCtrl, descCtrl, btnCtrl;
  final Uint8List? pickedBytes;
  final String? existingUrl;
  final bool isPrimary;

  const _PreviewPanel({
    required this.titleCtrl,
    required this.descCtrl,
    required this.btnCtrl,
    required this.pickedBytes,
    required this.existingUrl,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGreen.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: _kDark.withOpacity(0.05),
            blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _PanelHeading(icon: Icons.preview_rounded, label: 'LIVE PREVIEW'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _kGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(isPrimary ? 'MAIN CARD' : 'SECONDARY CARD',
                  style: const TextStyle(fontFamily: 'Urbanist', fontSize: 9,
                      fontWeight: FontWeight.w700, letterSpacing: 1.0, color: _kGreen1)),
            ),
          ]),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _kGreen.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kGreen.withOpacity(0.15)),
            ),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 13, color: _kGreen.withOpacity(0.7)),
              const SizedBox(width: 8),
              Text('This is exactly how the card appears on the landing page.',
                  style: TextStyle(fontFamily: 'Urbanist', fontSize: 11,
                      color: _kDark.withOpacity(0.55))),
            ]),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([titleCtrl, descCtrl, btnCtrl]),
              builder: (_, __) => _LandingCardPreview(
                title:       titleCtrl.text,
                description: descCtrl.text,
                buttonText:  btnCtrl.text,
                pickedBytes: pickedBytes,
                existingUrl: existingUrl,
                isPrimary:   isPrimary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(children: [
            Icon(Icons.auto_fix_high_rounded, size: 13, color: _kDark.withOpacity(0.3)),
            const SizedBox(width: 6),
            Text('Updates live as you type. Press Publish to save changes.',
                style: TextStyle(fontFamily: 'Urbanist', fontSize: 11,
                    color: _kDark.withOpacity(0.35))),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LANDING CARD PREVIEW
// ─────────────────────────────────────────────────────────────────────────────

class _LandingCardPreview extends StatelessWidget {
  final String title, description, buttonText;
  final Uint8List? pickedBytes;
  final String? existingUrl;
  final bool isPrimary;

  const _LandingCardPreview({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.isPrimary,
    this.pickedBytes,
    this.existingUrl,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final cardW = constraints.maxWidth;
      final cardH = (cardW / 16 * 7).clamp(160.0, constraints.maxHeight);

      return Center(
        child: SizedBox(
          width: cardW,
          height: cardH,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(child: _buildBg()),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [Color(0x44000000), Color(0xDD1C2419)],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 28,
                  bottom: 28,
                  right: cardW * 0.35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title.isEmpty ? 'Promotion Title' : title.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w900,
                          fontSize: cardW > 500 ? 26 : 20,
                          color: title.isEmpty ? _kWhite.withOpacity(0.3) : _kWhite,
                          height: 1.15,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        SizedBox(height: cardH * 0.04),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: cardW > 500 ? 13 : 11,
                            height: 1.5,
                            color: _kWhite.withOpacity(0.8),
                          ),
                        ),
                      ],
                      SizedBox(height: cardH * 0.06),
                      if (buttonText.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: cardW > 500 ? 28 : 20,
                            vertical: cardW > 500 ? 12 : 9,
                          ),
                          decoration: BoxDecoration(
                            color: isPrimary ? _kWhite : _kBrown,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: (isPrimary ? _kWhite : _kBrown).withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w800,
                              fontSize: cardW > 500 ? 13 : 11,
                              letterSpacing: 0.5,
                              color: isPrimary ? _kGreen1 : _kWhite,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBg() {
    if (pickedBytes != null) return Image.memory(pickedBytes!, fit: BoxFit.cover);
    if (existingUrl != null && existingUrl!.isNotEmpty) {
      return Image.network(
        existingUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder(),
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF2C3A2C),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.image_outlined, size: 40, color: _kWhite.withOpacity(0.12)),
          const SizedBox(height: 8),
          Text('No image selected',
              style: TextStyle(fontFamily: 'Urbanist', fontSize: 11,
                  color: _kWhite.withOpacity(0.2))),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IMAGE UPLOAD TILE
// ─────────────────────────────────────────────────────────────────────────────

class _ImageUploadTile extends StatelessWidget {
  final bool isUploading;
  final int? uploadedImgId;
  final VoidCallback onUpload, onClear;

  const _ImageUploadTile({
    required this.isUploading,
    required this.uploadedImgId,
    required this.onUpload,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final uploaded = uploadedImgId != null;
    return GestureDetector(
      onTap: isUploading ? null : (uploaded ? null : onUpload),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 72,
        decoration: BoxDecoration(
          color: uploaded
              ? const Color(0xFF4CAF50).withOpacity(0.06)
              : isUploading ? _kBrown.withOpacity(0.05) : _kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: uploaded
                ? const Color(0xFF4CAF50).withOpacity(0.5)
                : isUploading ? _kBrown.withOpacity(0.4) : _kGreen.withOpacity(0.25),
            width: uploaded ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: uploaded
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : isUploading ? _kBrown.withOpacity(0.08) : _kGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isUploading
                  ? Padding(
                      padding: const EdgeInsets.all(9),
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: _kBrown.withOpacity(0.7)))
                  : Icon(uploaded ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                      size: 20, color: uploaded ? const Color(0xFF4CAF50) : _kGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    uploaded ? 'Image uploaded'
                        : isUploading ? 'Uploading…'
                        : 'Click to upload image',
                    style: TextStyle(
                      fontFamily: 'Urbanist', fontWeight: FontWeight.w700, fontSize: 12,
                      color: uploaded ? const Color(0xFF4CAF50)
                          : isUploading ? _kBrown : _kDark,
                    ),
                  ),
                  Text(
                    uploaded ? 'ID #$uploadedImgId — will link on Publish'
                        : 'PNG, JPG or WEBP, max 10 MB',
                    style: TextStyle(fontFamily: 'Urbanist', fontSize: 10,
                        color: _kDark.withOpacity(0.4)),
                  ),
                ],
              ),
            ),
            if (uploaded)
              Row(children: [
                _SmallBtn(label: 'CHANGE', icon: Icons.swap_horiz_rounded,
                    color: _kGreen, onTap: onUpload),
                const SizedBox(width: 8),
                _SmallBtn(label: 'REMOVE', icon: Icons.close_rounded,
                    color: Colors.redAccent, onTap: onClear),
              ])
            else if (!isUploading)
              _SmallBtn(label: 'BROWSE', icon: Icons.folder_open_rounded,
                  color: _kGreen, onTap: onUpload),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _PanelHeading extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PanelHeading({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: _kGreen),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w900,
          fontSize: 12, letterSpacing: 1.5, color: _kGreen1)),
    ]);
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w800,
            fontSize: 10, letterSpacing: 1.2, color: _kDark.withOpacity(0.45)));
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int? maxLines;
  final bool expands;
  final double fontSize;

  const _InputBox({
    required this.controller,
    required this.hint,
    required this.maxLines,
    this.expands = false,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kGreen.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: _kDark.withOpacity(0.04),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        expands: expands,
        textAlignVertical: expands ? TextAlignVertical.top : TextAlignVertical.center,
        style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600,
            fontSize: fontSize, color: _kDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'Urbanist', fontSize: fontSize,
              color: _kDark.withOpacity(0.28)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallBtn({
    required this.label, required this.icon,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontFamily: 'Urbanist',
              fontWeight: FontWeight.w800, fontSize: 10,
              letterSpacing: 0.5, color: color)),
        ]),
      ),
    );
  }
}