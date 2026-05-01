import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../config/theme/app_colors.dart';
import "../../../core/widgets/admin_header.dart";
import 'package:frontend/core/services/customer/cms_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

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
  late int activeIndex;

  @override
  void initState() {
    super.initState();
    activeIndex = widget.activeIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(activeIndex: activeIndex, onLogout: widget.onLogout),
          Expanded(
            child: Scaffold( // Nested Scaffold ensures SnackBars appear in the content area
              body: Column(
                children: [
                  AdminHeader(title: "CMS", onLogout: widget.onLogout),
                  const Expanded(child: CMSMainSection()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================= MAIN SECTION =========================

class CMSMainSection extends StatefulWidget {
  const CMSMainSection({super.key});

  @override
  State<CMSMainSection> createState() => _CMSMainSectionState();
}

class _CMSMainSectionState extends State<CMSMainSection> {

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController buttonController = TextEditingController();

  Map<String, dynamic>? selectedPromo;
  String selectedCard = "primary";
  bool _isPublishing = false;

  final Map<String, String> cardTypeLabels = {
    "primary": "Main Card",
    "secondary": "Secondary Card",
  };

  final List<String> cardOptions = ["primary", "secondary"];

  // Tracker for pending image ID
  int? _uploadedImageId;
  bool _isUploadingImage = false;

  // Stores the local image data
  Uint8List? _localPickedImageBytes;

  @override
  void initState() {
    super.initState();
    loadPromo(selectedCard);
  }

  Future<void> loadPromo(String? type) async {
    debugPrint("CMS_DEBUG: Loading Promo for type: $type");
    if (type == null) return;

    try {
      final data = await CmsService.getPromotionByType(type);
      if (mounted) {
        setState(() {
          selectedPromo = data;
          titleController.text = data?['Title'] ?? '';
          buttonController.text = data?['buttonText'] ?? '';
          descController.text = CmsService.extractDescription(data?['description']);
        });
        debugPrint("CMS_DEBUG: Load success. ID: ${data?['id']}");
      }
    } catch (e) {
      debugPrint("CMS_DEBUG: Load Error: $e");
    }
  }

  Future<void> handlePublish() async {
    

    if (_isPublishing) {
      debugPrint("CMS_DEBUG: Blocked - already publishing");
      return;
    }
    
    if (selectedPromo == null) {
      debugPrint("CMS_DEBUG: Blocked - selectedPromo is null");
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final idToUse = selectedPromo!['documentId'] ?? selectedPromo!['id'];

      final Map<String, dynamic> payload = {
        "Title": titleController.text,
        "buttonText": buttonController.text,
        "description": [
          {
            "type": "paragraph",
            "children": [{"type": "text", "text": descController.text}]
          }
        ],
      };

      // If an image was uploaded, attach its ID to the promotion
      if (_uploadedImageId != null) {
        payload["image"] = _uploadedImageId;
      }

      final messenger = ScaffoldMessenger.of(context); 
      
      final success = await CmsService.publishPromotion(idToUse, payload);
      debugPrint("CMS_DEBUG: Target ID: $idToUse");
      debugPrint("CMS_DEBUG: Image ID to link: $_uploadedImageId");
      debugPrint("CMS_DEBUG: Full Payload: ${jsonEncode({"data": payload})}");

      if (!mounted) return;

      if (mounted) {

      messenger.removeCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(success ? "Promotion updated!" : "Failed to update."),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

        if (success) {
          setState(() {
            // Clear data
            _uploadedImageId = null;
            _localPickedImageBytes = null;
          });
          await loadPromo(selectedCard);
        }
      } 
    } catch (e) {
      debugPrint("CMS_DEBUG: Exception in handlePublish: $e");
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  } 

  // Function to handle the upload from the UI
  Future<void> handleImageUpload() async {

    const int maxFileSizeInBytes = 10 * 1024 * 1024; 

    try {

      // File picker logic
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true, 
      );

      // Check size
      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;


        
        if (file.size > maxFileSizeInBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("File is too large (${(file.size / 1024 / 1024).toStringAsFixed(1)}MB). Max limit is 10MB."),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        setState(() {
          _isUploadingImage = true;
          // Store bytes for local preview  
          _localPickedImageBytes = file.bytes;
        });
        
        final bytes = file.bytes!;
        final name = file.name;


        final id = await CmsService.uploadFile(bytes, name);

        setState(() {
          _uploadedImageId = id;
          _isUploadingImage = false;
        });

          debugPrint("CMS_DEBUG: Image ID saved in state: $_uploadedImageId");
        if (mounted && id != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image uploaded successfully!")),
          );
        }
      }
    } catch (e) {
      debugPrint("Picker Error: $e");
      setState(() => _isUploadingImage = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: MainCard(
                selectedCard: selectedCard,
                cardOptions: cardOptions,
                cardTypeLabels: cardTypeLabels,
                onCardChange: (value) {
                  setState(() => selectedCard = value!);
                  loadPromo(value);
                },
                titleController: titleController,
                descController: descController,
                buttonController: buttonController,
                selectedPromo: selectedPromo,
                onPublish: handlePublish,
                isUploadingImage: _isUploadingImage,
                onUploadPressed: handleImageUpload,
                isPublishing: _isPublishing,
                localPickedImageBytes: _localPickedImageBytes,
                uploadedImageId: _uploadedImageId,
                onClearImage: () {
                  setState(() {
                    _uploadedImageId = null;
                  });
                  debugPrint("CMS_DEBUG: Image unlinked by user");
                },
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================= COMPONENTS (MainCard & TopControls) =========================

class MainCard extends StatelessWidget {
  final String selectedCard;
  final List<String> cardOptions;
  final Map<String, String> cardTypeLabels;
  final Function(String?) onCardChange;
  final TextEditingController titleController;
  final TextEditingController descController;
  final TextEditingController buttonController;
  final Map<String, dynamic>? selectedPromo;
  final VoidCallback onUploadPressed;
  final bool isUploadingImage;
  final int? uploadedImageId;
  final VoidCallback onClearImage;
  final VoidCallback onPublish;
  final bool isPublishing;
  final Uint8List? localPickedImageBytes;

  const MainCard({
    super.key,
    required this.selectedCard,
    required this.cardOptions,
    required this.cardTypeLabels,
    required this.onCardChange,
    required this.titleController,
    required this.descController,
    required this.buttonController,
    required this.selectedPromo,
    required this.onPublish,
    required this.onClearImage,
    required this.onUploadPressed,
    required this.uploadedImageId,
    required this.isPublishing,
    required this.isUploadingImage,
    required this.localPickedImageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          TopControls(
            selectedCard: selectedCard,
            cardOptions: cardOptions,
            onChanged: onCardChange,
            onPublish: onPublish,
            cardTypeLabels: cardTypeLabels,
            selectedPromo: selectedPromo,
            isUploadingImage: isUploadingImage,
            isPublishing: isPublishing,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(child: ContentInfo(titleController: titleController, 
                descController: descController, onUploadPressed: onUploadPressed, uploadedImageId: uploadedImageId,isUploadingImage: isUploadingImage,
                onClearImage: onClearImage
                )),
                const VerticalDivider(color: AppColors.primary, width: 60, thickness: 1.5),
                Expanded(child: ContentPreview(
                  titleController: titleController,
                  descController: descController,
                  uploadedImageId: uploadedImageId,
                  localImageBytes: localPickedImageBytes,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopControls extends StatelessWidget {
  final String selectedCard;
  final List<String> cardOptions;
  final Map<String, String> cardTypeLabels;
  final Function(String?) onChanged;
  final bool isUploadingImage;

  final VoidCallback onPublish;
  final Map<String, dynamic>? selectedPromo;
  final bool isPublishing;

  const TopControls({
    super.key,
    required this.selectedCard,
    required this.cardOptions,
    required this.onChanged,
    required this.cardTypeLabels,
    required this.onPublish,
    required this.selectedPromo,
    required this.isUploadingImage,
    required this.isPublishing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.dashboard_customize, size: 28, color: AppColors.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 320,
          child: DropdownButtonFormField<String>(
            value: selectedCard,
            items: cardOptions.map((key) {
              return DropdownMenuItem(
                value: key, 
                child: Text(cardTypeLabels[key] ?? key), 
              );
            }).toList(),
            onChanged: isPublishing ? null : onChanged,
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: (selectedPromo == null || isPublishing) ? null : onPublish,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textLight,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          ),
          child: isPublishing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("PUBLISH"),
        ),
      ],
    );
  }
}

// ========================= CONTENT INFO =========================

class ContentInfo extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final VoidCallback onClearImage;
  final VoidCallback onUploadPressed;
  final int? uploadedImageId; 
  final bool isUploadingImage;
  const ContentInfo({
    super.key,
    required this.titleController,
    required this.descController,
    required this.onUploadPressed,
    required this.uploadedImageId,
    required this.onClearImage,
    required this.isUploadingImage
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleRow(title: "Title", controller: titleController),
        const SizedBox(height: 16),
        SubtitleRow(title: "Description", controller: descController),
        const SizedBox(height: 16),
        ImageUploadRow(onPressed: onUploadPressed, uploadedImageId: uploadedImageId,onClear: onClearImage, isUploading: isUploadingImage),
      ],
    );
  }
}

// ========================= UI UTILITIES & COMPONENTS =========================

class ContentRow extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final double rowHeight;

  const ContentRow({
    super.key,
    required this.icon,
    required this.child,
    this.rowHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: rowHeight,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: rowHeight,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class TitleRow extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  const TitleRow({super.key, required this.controller, required this.title});

  @override
  Widget build(BuildContext context) {
    return ContentRow(
      icon: Icons.title,
      rowHeight: 60,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: TextField(
          controller: controller,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: title,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class SubtitleRow extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  const SubtitleRow({super.key, required this.controller, required this.title});

  @override
  Widget build(BuildContext context) {
    return ContentRow(
      icon: Icons.subtitles,
      rowHeight: 100,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: TextField(
          controller: controller,
          maxLines: null,
          expands: true,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: title,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class ImageUploadRow extends StatelessWidget {
  final VoidCallback onPressed;
  final int? uploadedImageId; 
  final VoidCallback onClear;
  final bool isUploading;
  const ImageUploadRow({super.key, required this.onPressed, required this.uploadedImageId, required this.onClear, this.isUploading = false});

  @override
  Widget build(BuildContext context) {
    return ContentRow(
      icon: Icons.image,
      rowHeight: 160,
      child: InkWell(
        onTap: isUploading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: uploadedImageId != null ? Colors.green.withOpacity(0.05) : AppColors.textLight,
            border: Border.all(
              color: uploadedImageId != null ? Colors.green : AppColors.primary.withOpacity(0.5), 
              width: uploadedImageId != null ? 2 : 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isUploading)
                      const CircularProgressIndicator()
                    else if (uploadedImageId != null)
                      const Icon(Icons.check_circle, size: 40, color: Colors.green)
                    else
                      const Icon(Icons.cloud_upload, size: 40, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                      uploadedImageId != null 
                        ? "Image Uploaded!" 
                        : "Click to upload Banner Image",
                      style: TextStyle(
                        color: uploadedImageId != null ? Colors.green : AppColors.primary,
                        fontWeight: uploadedImageId != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (uploadedImageId != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onClear
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class ContentPreview extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final int? uploadedImageId;
  final Uint8List? localImageBytes;
  final bool isUploading;

  const ContentPreview({super.key,
    required this.titleController,
    required this.descController,
    this.uploadedImageId,
    this.localImageBytes,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([titleController, descController]),
      builder: (context, _) {
           return Column(
            children: [
              Center(
                child: IntrinsicWidth(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "CONTENT PREVIEW",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: Listenable.merge([titleController, descController]),
                  builder: (context, _) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Container(
                          height: 260,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: Colors.grey,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Stack(
                              children: [
                                
                                // --- 1. THE IMAGE (Bottom of Stack) ---
                                if (localImageBytes != null)
                                  Opacity(
                                    opacity: 0.4, 
                                    child: Image.memory(
                                      localImageBytes!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover, 
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.grey.shade800, 
                                    child: Icon(
                                      Icons.image, 
                                      size: 80, 
                                      color: Colors.grey.shade400 
                                    ),
                                  ),

                                // --- 2. THE TEXT CONTENT (Top of Stack) ---
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        titleController.text.isEmpty
                                            ? "Title Preview"
                                            : titleController.text,
                                        style: const TextStyle(
                                          fontSize: 24, // Increased size
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        descController.text.isEmpty
                                            ? "Promo description goes here..."
                                            : descController.text,
                                        style: TextStyle(color: Colors.white70),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
      }
    );
  }
}

class TableCard extends StatelessWidget {
  const TableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CONTENT LIST",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: Text("CARD", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text("HEADING", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(width: 80),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.textLight),
          const TableRowItem(card: "Primary", heading: "Main Promo", status: "Published"),
          const TableRowItem(card: "Secondary", heading: "Side Banner", status: "Draft"),
        ],
      ),
    );
  }
}

class TableRowItem extends StatelessWidget {
  final String card;
  final String heading;
  final String status;

  const TableRowItem({
    super.key,
    required this.card,
    required this.heading,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(card)),
            Expanded(child: Text(heading)),
            Expanded(child: StatusBadge(status: status)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: AppColors.primary,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: Colors.red,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        const Divider(color: AppColors.textLight),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isPublished = status == "Published";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPublished ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isPublished ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}