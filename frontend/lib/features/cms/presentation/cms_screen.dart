import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_sidebar.dart';
import '../../../../config/theme/app_colors.dart';
import "../../../core/widgets/admin_header.dart";

class CMSScreen extends StatefulWidget {
  final int activeIndex;
  const CMSScreen({super.key, this.activeIndex = 6});

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
          // Sidebar
          Sidebar(activeIndex: activeIndex),

          // Main content area
          Expanded(
            child: Column(
              children: [
                const AdminHeader(title: "CMS"),

                const Expanded(
                  child: CMSMainSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class CMSMainSection extends StatelessWidget {
  const CMSMainSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: const MainCard(),
            ),
            const SizedBox(height: 20),
            const TableCard(),
          ],
        ),
      ),
    );
  }
}


class TopControls extends StatefulWidget {
  const TopControls({super.key});

  @override
  State<TopControls> createState() => _TopControlsState();
}

class _TopControlsState extends State<TopControls> {
  String selectedCard = "Select Card to Update"; // default value

  final List<String> cardOptions = [
    "Select Card to Update",
    "Event Card",
    "Feature Card",
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: Icon(Icons.dashboard_customize, size: 28, color: AppColors.primary),
        ),

        SizedBox(
          width: 320, // fixed width
          child: DropdownButtonFormField<String>(
            value: selectedCard,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: AppColors.textLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: AppColors.receiptBg, width: 2),
              ),
            ),
            icon: const Icon(Icons.arrow_drop_down),
            style: TextStyle(color: AppColors.receiptDark), // text color
            items: cardOptions.map((card) {
              return DropdownMenuItem(
                value: card,
                child: Text(card),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCard = value!;
              });
            },
          ),
        ),

        const Spacer(),

        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.primary,
            backgroundColor: AppColors.textLight,
            side: BorderSide(
              color: AppColors.primary,
              width: 1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          ),
          child: const Text("SAVE"),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.textLight,
            backgroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          ),
          child: const Text("PUBLISH"),
        ),
      ],
    );
  }
}

class MainCard extends StatelessWidget {
  const MainCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded( 
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            TopControls(),
            SizedBox(height: 20),

            // THIS NOW HAS HEIGHT
            Expanded(
              child: Row(
                children: [
                  Expanded(child: ContentInfo()),

                  // Divider
                  VerticalDivider(
                    color: AppColors.primary,
                    width: 60,
                    thickness: 1.5,
                  ),

                  Expanded(child: ContentPreview()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentInfo extends StatelessWidget {
  const ContentInfo({super.key});

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
              child: const Center(
                child: Text(
                  "CONTENT INFORMATION",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColors.textLight
                  ),
                ),
              ),
            ),
          ),
        ),
        TitleRow(title: "Title"),
        SizedBox(height: 16),
        SubtitleRow(title: "Description"),
        SizedBox(height: 16),
        ImageUploadRow(),
      ],
    );
  }
}
// ------------------- REUSABLE ROW WIDGET -------------------
class ContentRow extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final double rowHeight;

  const ContentRow({
    super.key,
    required this.icon,
    required this.child,
    this.rowHeight = 60, // default row height
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon column
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(width: 10),

          // Vertical divider
          Container(
            width: 1,
            height: rowHeight,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),

          // Input / upload field column
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

// ------------------- TITLE ROW -------------------
class TitleRow extends StatelessWidget {
  final String title;
  const TitleRow({super.key, required this.title});

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
          border: Border.all(color: AppColors.primary, style: BorderStyle.solid, width: 1),
        ),
        child: TextField(
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: title,
            border: InputBorder.none, // remove underline
          ),
        ),
      ),
    );
  }
}

// ------------------- SUBTITLE / DESCRIPTION ROW -------------------
class SubtitleRow extends StatelessWidget {
  final String title;
  const SubtitleRow({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ContentRow(
      icon: Icons.subtitles,
      rowHeight: 100, // taller for multi-line
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: AppColors.primary, style: BorderStyle.solid, width: 1),
        ),
        child: TextField(
          maxLines: null,
          expands: true, // fills container height
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

// ------------------- IMAGE UPLOAD ROW -------------------
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
          border: Border.all(color: AppColors.primary, style: BorderStyle.solid, width: 1),
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
        // Title
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

        // THIS takes remaining height
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),

            // Inner preview box
            child: Center(
              child: Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey,
                ),
                child: const Center(child: Text("Preview")),
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
          // Title
          const Text(
            "CONTENT LIST",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: const [
              Expanded(child: Text("CARD", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text("HEADING", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(width: 80), // space for actions
            ],
          ),

          const SizedBox(height: 10),
          const Divider(),

          // Rows
          const TableRowItem(
            card: "Event",
            heading: "School Fair",
            status: "Published",
          ),
          const TableRowItem(
            card: "Feature",
            heading: "New Program",
            status: "Draft",
          ),
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

            // Actions
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
        const Divider(),
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
        color: isPublished
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
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