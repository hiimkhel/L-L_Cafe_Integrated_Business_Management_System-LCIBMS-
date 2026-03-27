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
      padding: const EdgeInsets.all(20),
      color: AppColors.textLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          MainCard(),
          SizedBox(height: 20),
          TableCard(),
        ],
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
    return Container(
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

          Row(
            children: [
              Expanded(child: ContentInfo()),
              SizedBox(width: 20),
              Expanded(child: ContentPreview()),
            ],
          ),
        ],
      ),
    );
  }
}

class ContentInfo extends StatelessWidget {
  const ContentInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("CONTENT INFORMATION"),
        SizedBox(height: 10),
        TextField(decoration: InputDecoration(hintText: "Title")),
        SizedBox(height: 10),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(hintText: "Description"),
        ),
      ],
    );
  }
}


class ContentPreview extends StatelessWidget {
  const ContentPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("CONTENT PREVIEW"),
        const SizedBox(height: 10),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey,
          ),
          child: const Center(child: Text("Preview")),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCC9A8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("CARD"),
              Text("HEADING"),
              Text("STATUS"),
            ],
          ),
          SizedBox(height: 10),
          Text("Table rows here..."),
        ],
      ),
    );
  }
}