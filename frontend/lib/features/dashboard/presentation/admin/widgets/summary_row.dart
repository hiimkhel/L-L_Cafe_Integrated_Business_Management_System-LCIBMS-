import 'package:flutter/material.dart';
import 'package:frontend/core/models/dashboard_models.dart';
import 'package:frontend/features/dashboard/presentation/admin/widgets/summary_card.dart';

class SummaryRow extends StatelessWidget {
  final List<SummaryCardData> cards;

  const SummaryRow({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        cards.length,
        (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: i < cards.length - 1 ? 12 : 0,
            ),
            child: SummaryCard(
              data: cards[i],
            ),
          ),
        ),
      ),
    );
  }
}