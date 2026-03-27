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


class TopControls extends StatelessWidget {
  const TopControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text("Select Card to Update..."),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(onPressed: () {}, child: const Text("SAVE")),
        const SizedBox(width: 10),
        ElevatedButton(onPressed: () {}, child: const Text("PUBLISH")),
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
        color: const Color(0xFFDCC9A8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column( // ✅ changed from Row → Column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          TopControls(), // ✅ now inside main card
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