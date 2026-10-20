import 'package:flutter/material.dart';

import '../../core/models/sport_type.dart';

class SportSelectorBar extends StatelessWidget {
  final SportType selectedSport;
  final ValueChanged<SportType> onSelected;

  const SportSelectorBar({
    super.key,
    required this.selectedSport,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFF1E293B),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: SportType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sport = SportType.values[index];
          final selected = sport == selectedSport;

          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(sport.icon, size: 16),
                const SizedBox(width: 6),
                Text(sport.label),
              ],
            ),
            selected: selected,
            onSelected: (_) => onSelected(sport),
            selectedColor: sport.accentColor,
            backgroundColor: const Color(0xFF334155),
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          );
        },
      ),
    );
  }
}

