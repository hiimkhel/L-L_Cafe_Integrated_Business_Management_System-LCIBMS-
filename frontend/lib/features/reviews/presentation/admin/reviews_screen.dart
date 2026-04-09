import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/core/widgets/admin_header.dart';

class ReviewsScreen extends StatefulWidget {
  final int activeIndex;
  const ReviewsScreen({super.key, this.activeIndex = 5});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late int activeIndex;
  String activeSegment = "ALL REVIEWS";
  String sortBy = "RATINGS";
  String filterBy = "NEWEST";

  // Dummy data
  final reviews = List.generate(6, (index) => {
        "customerId": "#1234",
        "customerName": "JUAN DELA CRUZ",
        "submittedAt": "09/09/0909 09:09 PM",
        "reviewContent":
            "YOU HAVE A WAY OF MAKING THINGS FEEL LIGHTER AND MORE INTERESTING JUST BY BEING AROUND—PEOPLE GENUINELY ENJOY YOUR PRESENCE.",
        "rating": 5.0,
        "isPublished": false,
        "avatarUrl": null,
      });

  @override
  void initState() {
    super.initState();
    activeIndex = widget.activeIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
          children: [
            Sidebar(activeIndex: activeIndex),

            Expanded(child: _MainSection()),
          ],
        ),
    );
  }

  
  Widget _MainSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminHeader(title: "REVIEWS"), // optional if you want header

        const SizedBox(height: 16),

        _HeaderSection(),

        const SizedBox(height: 24),

        Expanded(child: _ReviewsList()),
      ],
    );
  }

  Widget _HeaderSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Segmented buttons
          Row(
            children: ["ALL REVIEWS", "POSTED", "ARCHIVED"]
                .map((segment) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            activeSegment = segment;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: activeSegment == segment
                                ? Colors.green[300]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            segment,
                            style: TextStyle(
                              color: activeSegment == segment
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

          // Right: Dropdowns
          Row(
            children: [
              _buildDropdownButton(sortBy, ["RATINGS", "NEWEST"], (val) {
                setState(() => sortBy = val!);
              }),
              const SizedBox(width: 12),
              _buildDropdownButton(filterBy, ["NEWEST", "OLDEST"], (val) {
                setState(() => filterBy = val!);
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _ReviewsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical : 4, horizontal: 24),
      child: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return _ReviewCard(review);
        },
      ),
    );
  }

  Widget _ReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBDD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundImage: review["avatarUrl"] != null
                ? NetworkImage(review["avatarUrl"])
                : null,
            child: review["avatarUrl"] == null
                ? const Icon(Icons.person, size: 28)
                : null,
          ),
          const SizedBox(width: 16),

          // Info + Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${review["customerId"]} ${review["customerName"]}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  review["submittedAt"],
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Text(
                  review["reviewContent"],
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Rating + Publish
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (review["rating"] as double).toStringAsFixed(1),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < (review["rating"] as double).floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: review["isPublished"]
                    ? null
                    : () {
                        setState(() {
                          review["isPublished"] = true;
                        });
                      },
                child: Text(
                  review["isPublished"] ? "PUBLISHED" : "PUBLISH",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: review["isPublished"]
                        ? Colors.grey
                        : Colors.black87,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
        ],
      )
    );
  }
  Widget _buildDropdownButton(
      String current, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: current,
        underline: const SizedBox(),
        items: options
            .map((opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(opt),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}