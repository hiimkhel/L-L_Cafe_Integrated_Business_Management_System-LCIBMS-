import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/admin_sidebar.dart';
import 'package:frontend/core/widgets/admin_header.dart';
import 'package:frontend/config/theme/app_colors.dart';

class ReviewsScreen extends StatefulWidget {
  final int activeIndex;
  const ReviewsScreen({super.key, this.activeIndex = 5});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late int activeIndex;
  String activeSegment = "ALL REVIEWS";
  String sortBy = "Newest";

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
                      padding: const EdgeInsets.all(8),
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
                                ? AppColors.secondary
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: activeSegment == segment
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.85),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                          ),
                          child: Text(
                            segment,
                            style: TextStyle(
                              color: activeSegment == segment
                                  ? AppColors.background
                                  : AppColors.primary,
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
              const SizedBox(width: 12),
              _buildDropdownButton(sortBy, ["Newest", "Oldest"], (val) {
                setState(() => sortBy = val!);
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _ReviewsList() {

    List reviewsData = List.from(
      reviews
    );

    if (sortBy == "NEWEST") {
      reviewsData.sort((a, b) =>
          (b["submittedAt"] as String)
              .compareTo(a["submittedAt"] as String));
    } else if (sortBy == "OLDEST") {
      reviewsData.sort((a, b) =>
          (a["submittedAt"] as String)
              .compareTo(b["submittedAt"] as String));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical : 4, horizontal: 24),
      child: ListView.builder(
        itemCount: reviewsData.length,
        itemBuilder: (context, index) {
          final review = reviewsData[index];
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 Avatar
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

          // 🔹 Customer Info (LEFT COLUMN)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review["customerId"],
                style: const TextStyle(
                  color: AppColors.primary,
                    fontWeight: FontWeight.w100, fontSize: 14),
              ),
              Text(
                review["customerName"],
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                review["submittedAt"],
                style: TextStyle(
                    fontSize: 12, 
                    color: AppColors.primary.withOpacity(0.4)
                    ),
              ),
            ],
          ),

          const SizedBox(width: 32),

          // Review Content (CENTER - EXPANDED)
          Expanded(
            child: Text(
              review["reviewContent"],
              style: TextStyle(
                  fontSize: 12, color: AppColors.primary.withOpacity(0.8),
                  fontWeight: FontWeight.w100,
                  ),
            ),
          ),

          const SizedBox(width: 24),

          // 🔹 Rating + Publish (RIGHT)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (review["rating"] as double).toStringAsFixed(1),
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800, fontSize: 14),
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
                    color:AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildDropdownButton(
      String current, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: current,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.primary,
        ),

        style: TextStyle(
          color: AppColors.primary,
          fontSize: 14,
        ),
        
        dropdownColor: Colors.white,
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