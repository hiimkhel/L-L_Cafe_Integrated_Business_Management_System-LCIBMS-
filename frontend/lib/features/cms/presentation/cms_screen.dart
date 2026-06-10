import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/core/widgets/admin_header.dart';
import 'package:frontend/core/services/customer/cms_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE  — matches reviews_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

const _white   = Color(0xFFFFFFFF);
const _surface = Color(0xFFF7F3EE);   // warm tinted panel bg
const _border  = Color(0xFFE8DDD0);   // beige-tinted border
const _beige   = Color(0xFFEFE2C9);   // segment control / header tint
const _green1  = Color(0xFF3D5A45);
const _green2  = Color(0xFF758C6D);
const _gold    = Color(0xFFA98258);
const _dark    = Color(0xFF2D2A26);
const _sub     = Color(0xFF7A7067);

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
      backgroundColor: _white,
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
  // ✅ Button text controller REMOVED

  Map<String, dynamic>? _promo;
  String     _cardType     = 'primary';
  bool       _isPublishing = false;
  bool       _isUploading  = false;
  int?       _uploadedImgId;
  Uint8List? _pickedBytes;
  String?    _existingUrl;

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
    _titleCtrl.addListener(_saveDraft);
    _descCtrl.addListener(_saveDraft);
    // ✅ _btnCtrl listener REMOVED
    _loadPromo(_cardType);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    // ✅ _btnCtrl dispose REMOVED
    super.dispose();
  }

  // ── Draft helpers ─────────────────────────────────────────────────────────

  void _saveDraft() {
    _drafts[_cardType] = {
      'title':         _titleCtrl.text,
      'description':   _descCtrl.text,
      // ✅ buttonText removed from draft
      'uploadedImgId': _uploadedImgId,
      'pickedBytes':   _pickedBytes,
      'existingUrl':   _existingUrl,
    };
  }

  void _restoreDraft(String type) {
    final draft = _drafts[type];
    if (draft == null) return;
    _titleCtrl.text = draft['title']       as String? ?? '';
    _descCtrl.text  = draft['description'] as String? ?? '';
    // ✅ buttonText restore REMOVED
    _uploadedImgId  = draft['uploadedImgId'] as int?;
    _pickedBytes    = draft['pickedBytes']   as Uint8List?;
    _existingUrl    = draft['existingUrl']   as String?;
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> _loadPromo(String type) async {
    try {
      final data = await CmsService.getPromotionByType(type);
      if (!mounted) return;
      setState(() {
        _promo = data;
        if (_drafts.containsKey(type)) {
          _restoreDraft(type);
        } else {
          _titleCtrl.text = data?['Title']      ?? '';
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
        'Title': _titleCtrl.text,
        // ✅ buttonText removed from payload
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
          content: Row(children: [
            Icon(ok ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                color: _white, size: 15),
            const SizedBox(width: 8),
            Text(ok ? 'Promotion published!' : 'Publish failed. Try again.',
                style: const TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: ok ? _green1 : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ));

      if (ok) {
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

  // ── Image ─────────────────────────────────────────────────────────────────

  Future<void> _uploadImage() async {
    const maxBytes = 10 * 1024 * 1024;
    try {
      final result = await FilePicker.pickFiles(type: FileType.image, withData: true);
      if (result == null) return;
      final file = result.files.single;
      if (file.size > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'File too large (${(file.size / 1024 / 1024).toStringAsFixed(1)} MB). Max 10 MB.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }
      setState(() { _isUploading = true; _pickedBytes = file.bytes; });
      final id = await CmsService.uploadFile(file.bytes!, file.name);
      if (!mounted) return;
      setState(() { _uploadedImgId = id; _isUploading = false; });
      _saveDraft();
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline_rounded, color: _white, size: 15),
            const SizedBox(width: 8),
            const Text('Image uploaded — press Publish to save.',
                style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: _green2,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ));
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _clearImage() {
    setState(() { _uploadedImgId = null; _pickedBytes = null; });
    _saveDraft();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
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
                // Edit panel
                Expanded(
                  flex: 4,
                  child: _EditPanel(
                    titleCtrl:     _titleCtrl,
                    descCtrl:      _descCtrl,
                    isUploading:   _isUploading,
                    uploadedImgId: _uploadedImgId,
                    onUpload:      _uploadImage,
                    onClearImage:  _clearImage,
                  ),
                ),

                const SizedBox(width: 20),

                // Preview panel
                Expanded(
                  flex: 6,
                  child: _PreviewPanel(
                    titleCtrl:   _titleCtrl,
                    descCtrl:    _descCtrl,
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
    final publishEnabled = canPublish && !isPublishing && !isUploading;

    return Row(children: [
      // Section label
      Row(children: [
        Container(
          width: 4, height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_green2, _green1]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        const Text('PROMOTION EDITOR',
            style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 0.5,
                color: _green1)),
      ]),

      const SizedBox(width: 20),

      // Card type dropdown — beige-tinted, matches segmented control style
      Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _beige,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: _border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: cardType,
            isDense: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: _sub, size: 18),
            style: const TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: _dark),
            dropdownColor: _white,
            items: cardTypes.entries.map((e) => DropdownMenuItem(
              value: e.key,
              child: Row(children: [
                Icon(
                    e.key == 'primary'
                        ? Icons.web_rounded
                        : Icons.view_sidebar_rounded,
                    size: 15, color: _green2),
                const SizedBox(width: 8),
                Text(e.value),
              ]),
            )).toList(),
            onChanged: isPublishing ? null : onCardChange,
          ),
        ),
      ),

      const Spacer(),

      // Uploading indicator
      if (isUploading)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(children: [
            SizedBox(
              width: 13, height: 13,
              child: CircularProgressIndicator(strokeWidth: 2, color: _gold),
            ),
            const SizedBox(width: 8),
            Text('Uploading image…',
                style: TextStyle(
                    fontFamily: 'Urbanist', fontSize: 12, color: _gold.withOpacity(0.9))),
          ]),
        ),

      // Publish button — green1 filled, same style as reviews action buttons
      GestureDetector(
        onTap: publishEnabled ? onPublish : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: publishEnabled ? _green1 : _border,
            borderRadius: BorderRadius.circular(9),
            boxShadow: publishEnabled
                ? [BoxShadow(
                    color: _green1.withOpacity(0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3))]
                : [],
          ),
          child: isPublishing
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: _white))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.publish_rounded, size: 15,
                      color: publishEnabled ? _white : _sub),
                  const SizedBox(width: 7),
                  Text('PUBLISH',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1.0,
                          color: publishEnabled ? _white : _sub)),
                ]),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT PANEL
// ─────────────────────────────────────────────────────────────────────────────

class _EditPanel extends StatelessWidget {
  final TextEditingController titleCtrl, descCtrl;
  // ✅ btnCtrl REMOVED
  final bool isUploading;
  final int? uploadedImgId;
  final VoidCallback onUpload, onClearImage;

  const _EditPanel({
    required this.titleCtrl,
    required this.descCtrl,
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
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: _dark.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel heading — matches reviews panel header style
          _PanelHeading(icon: Icons.edit_note_rounded, label: 'EDIT CONTENT'),
          const SizedBox(height: 20),
          Divider(color: _border, height: 1),
          const SizedBox(height: 20),

          _FieldLabel(label: 'TITLE'),
          const SizedBox(height: 6),
          _InputBox(
              controller: titleCtrl,
              hint: 'Enter promotion title…',
              maxLines: 1,
              fontSize: 15),

          const SizedBox(height: 16),

          _FieldLabel(label: 'DESCRIPTION'),
          const SizedBox(height: 6),
          Expanded(
            child: _InputBox(
                controller: descCtrl,
                hint: 'Enter promotion description…',
                maxLines: null,
                expands: true,
                fontSize: 13),
          ),

          // ✅ BUTTON TEXT field + SizedBox REMOVED entirely

          const SizedBox(height: 16),

          _FieldLabel(label: 'BANNER IMAGE'),
          const SizedBox(height: 8),
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
  final TextEditingController titleCtrl, descCtrl;
  // ✅ btnCtrl REMOVED
  final Uint8List? pickedBytes;
  final String? existingUrl;
  final bool isPrimary;

  const _PreviewPanel({
    required this.titleCtrl,
    required this.descCtrl,
    required this.pickedBytes,
    required this.existingUrl,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: _dark.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading row
          Row(children: [
            const _PanelHeading(icon: Icons.preview_rounded, label: 'LIVE PREVIEW'),
            const Spacer(),
            // Card type badge — gold for secondary, green for primary
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPrimary ? _green1.withOpacity(0.08) : _gold.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isPrimary ? _green1.withOpacity(0.2) : _gold.withOpacity(0.25)),
              ),
              child: Text(
                isPrimary ? 'MAIN CARD' : 'SECONDARY CARD',
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isPrimary ? _green1 : _gold),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Info banner — uses beige from palette
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: _beige,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border),
            ),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, size: 13, color: _sub),
              const SizedBox(width: 8),
              Text('This is exactly how the card appears on the landing page.',
                  style: TextStyle(
                      fontFamily: 'Urbanist', fontSize: 11, color: _dark.withOpacity(0.6))),
            ]),
          ),

          const SizedBox(height: 20),

          Divider(color: _border, height: 1),
          const SizedBox(height: 20),

          // Live preview — listens to title + desc only (no button)
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([titleCtrl, descCtrl]),
              builder: (_, __) => _LandingCardPreview(
                title:       titleCtrl.text,
                description: descCtrl.text,
                pickedBytes: pickedBytes,
                existingUrl: existingUrl,
                isPrimary:   isPrimary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Footer hint
          Row(children: [
            Icon(Icons.auto_fix_high_rounded, size: 12, color: _sub.withOpacity(0.5)),
            const SizedBox(width: 6),
            Text('Updates live as you type. Press Publish to save changes.',
                style: TextStyle(
                    fontFamily: 'Urbanist', fontSize: 11, color: _sub.withOpacity(0.6))),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LANDING CARD PREVIEW  — button text section removed
// ─────────────────────────────────────────────────────────────────────────────

class _LandingCardPreview extends StatelessWidget {
  final String title, description;
  // ✅ buttonText REMOVED
  final Uint8List? pickedBytes;
  final String? existingUrl;
  final bool isPrimary;

  const _LandingCardPreview({
    required this.title,
    required this.description,
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
            borderRadius: BorderRadius.circular(16),
            child: Stack(children: [
              Positioned.fill(child: _buildBg()),
              // Dark gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Color(0x44000000), Color(0xDD1C2419)],
                    ),
                  ),
                ),
              ),
              // Text content — no button
              Positioned(
                left: 28, bottom: 28, right: cardW * 0.35,
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
                        color: title.isEmpty
                            ? const Color(0xFFFFFFFF).withOpacity(0.3)
                            : const Color(0xFFFFFFFF),
                        height: 1.15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      SizedBox(height: cardH * 0.04),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: cardW > 500 ? 13 : 11,
                          height: 1.5,
                          color: const Color(0xFFFFFFFF).withOpacity(0.8),
                        ),
                      ),
                    ],
                    // ✅ Button preview block REMOVED
                  ],
                ),
              ),
            ]),
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
          Icon(Icons.image_outlined, size: 40, color: Colors.white.withOpacity(0.12)),
          const SizedBox(height: 8),
          Text('No image selected',
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.2))),
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
              ? _green1.withOpacity(0.05)
              : isUploading
                  ? _gold.withOpacity(0.05)
                  : _surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: uploaded
                ? _green1.withOpacity(0.35)
                : isUploading
                    ? _gold.withOpacity(0.4)
                    : _border,
            width: uploaded ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            // Icon container
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: uploaded
                    ? _green1.withOpacity(0.1)
                    : isUploading
                        ? _gold.withOpacity(0.08)
                        : _beige,
                borderRadius: BorderRadius.circular(9),
              ),
              child: isUploading
                  ? Padding(
                      padding: const EdgeInsets.all(9),
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: _gold))
                  : Icon(
                      uploaded
                          ? Icons.check_circle_rounded
                          : Icons.cloud_upload_outlined,
                      size: 18,
                      color: uploaded ? _green1 : _green2),
            ),
            const SizedBox(width: 12),

            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    uploaded
                        ? 'Image uploaded'
                        : isUploading
                            ? 'Uploading…'
                            : 'Click to upload image',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: uploaded
                            ? _green1
                            : isUploading
                                ? _gold
                                : _dark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    uploaded
                        ? 'ID #$uploadedImgId — will link on Publish'
                        : 'PNG, JPG or WEBP, max 10 MB',
                    style: const TextStyle(
                        fontFamily: 'Urbanist', fontSize: 10, color: _sub),
                  ),
                ],
              ),
            ),

            // Action buttons
            if (uploaded)
              Row(children: [
                _SmallBtn(
                    label: 'CHANGE',
                    icon: Icons.swap_horiz_rounded,
                    color: _green2,
                    onTap: onUpload),
                const SizedBox(width: 8),
                _SmallBtn(
                    label: 'REMOVE',
                    icon: Icons.close_rounded,
                    color: Colors.redAccent,
                    onTap: onClear),
              ])
            else if (!isUploading)
              _SmallBtn(
                  label: 'BROWSE',
                  icon: Icons.folder_open_rounded,
                  color: _green2,
                  onTap: onUpload),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _PanelHeading extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PanelHeading({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 17, color: _green2),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.4,
              color: _green1)),
    ]);
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w800,
            fontSize: 10,
            letterSpacing: 1.2,
            color: _sub));
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
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        expands: expands,
        textAlignVertical:
            expands ? TextAlignVertical.top : TextAlignVertical.center,
        style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
            color: _dark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: fontSize,
              color: _sub.withOpacity(0.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withOpacity(0.22)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.5,
                  color: color)),
        ]),
      ),
    );
  }
}