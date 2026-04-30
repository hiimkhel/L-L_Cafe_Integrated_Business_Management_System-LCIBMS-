import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../config/theme/app_colors.dart';
import "../../../core/widgets/admin_header.dart";
import 'package:frontend/core/services/customer/cms_service.dart';

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

  final List<String> cardOptions = ["primary", "secondary"];

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
    debugPrint("CMS_DEBUG: Publish Button Clicked");

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
      debugPrint("CMS_DEBUG: Attempting API call for ID: $idToUse");

      final success = await CmsService.publishPromotion(
        idToUse,
        {
          "Title": titleController.text,
          "buttonText": buttonController.text,
          "description": [
            {
              "type": "paragraph",
              "children": [{"type": "text", "text": descController.text}]
            }
          ],
        },
      );

      debugPrint("CMS_DEBUG: API Response success = $success");

      if (mounted) {
        debugPrint("CMS_DEBUG: Widget is mounted, attempting to show SnackBar");
        
        // Use root messenger to be safe
        final messenger = ScaffoldMessenger.of(context);
        messenger.removeCurrentSnackBar();

        messenger.showSnackBar(
          SnackBar(
            content: Text(success ? "Promotion updated successfully!" : "Failed to update promotion."),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(20), // Makes it float clearly
          ),
        );

        if (success) {
          debugPrint("CMS_DEBUG: Re-loading promo data...");
          await loadPromo(selectedCard);
        }
      } else {
        debugPrint("CMS_DEBUG: Error - Widget unmounted before SnackBar could show");
      }
    } catch (e) {
      debugPrint("CMS_DEBUG: Exception in handlePublish: $e");
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
      debugPrint("CMS_DEBUG: Publishing process finished");
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
                onCardChange: (value) {
                  setState(() => selectedCard = value!);
                  loadPromo(value);
                },
                titleController: titleController,
                descController: descController,
                buttonController: buttonController,
                selectedPromo: selectedPromo,
                onPublish: handlePublish,
                isPublishing: _isPublishing,
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
  final Function(String?) onCardChange;
  final TextEditingController titleController;
  final TextEditingController descController;
  final TextEditingController buttonController;
  final Map<String, dynamic>? selectedPromo;
  final VoidCallback onPublish;
  final bool isPublishing;

  const MainCard({
    super.key,
    required this.selectedCard,
    required this.cardOptions,
    required this.onCardChange,
    required this.titleController,
    required this.descController,
    required this.buttonController,
    required this.selectedPromo,
    required this.onPublish,
    required this.isPublishing,
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
            selectedPromo: selectedPromo,
            isPublishing: isPublishing,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(child: ContentInfo(titleController: titleController, descController: descController)),
                const VerticalDivider(color: AppColors.primary, width: 60, thickness: 1.5),
                const Expanded(child: ContentPreview()),
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
  final Function(String?) onChanged;
  final VoidCallback onPublish;
  final Map<String, dynamic>? selectedPromo;
  final bool isPublishing;

  const TopControls({
    super.key,
    required this.selectedCard,
    required this.cardOptions,
    required this.onChanged,
    required this.onPublish,
    required this.selectedPromo,
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
            items: cardOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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
  const ContentInfo({
    super.key,
    required this.titleController,
    required this.descController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleRow(title: "Title", controller: titleController),
        const SizedBox(height: 16),
        SubtitleRow(title: "Description", controller: descController),
        const SizedBox(height: 16),
        const ImageUploadRow(),
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
  const ImageUploadRow({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentRow(
      icon: Icons.image,
      rowHeight: 140,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.textLight,
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload, size: 36, color: AppColors.primary),
            const SizedBox(height: 8),
            const Text(
              "Choose a file or drag & drop it here",
              style: TextStyle(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.textLight,
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text("Browse File"),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentPreview extends StatelessWidget {
  const ContentPreview({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade300,
                ),
                child: const Center(child: Text("Preview Area")),
              ),
            ),
          ),
        ),
      ],
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