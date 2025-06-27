import 'package:flutter/material.dart';

class TheraBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<String>? labels;

  const TheraBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.labels,
  });

  static const Color bgColor = Color(0xFF1C3D5A);
  static const Color selectedBlockColor = Color(0xFF2C7A7B);
  static const Color iconNormalColor = Color(0xFF91BEBE);
  static const Color iconSelectedColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final usedLabels = labels ?? ['ข่าวสาร', 'เลือกคอร์ส', 'ผู้ใช้งาน'];

    return Container(
      decoration: const BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            offset: Offset(0, -4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedItemColor: iconSelectedColor,
          unselectedItemColor: iconNormalColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: List.generate(3, (index) {
            final isSelected = index == currentIndex;
            final iconData = [
              Icons.newspaper,
              Icons.accessibility_new_rounded,
              Icons.emoji_events_rounded,
            ][index];
            return BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: isSelected
                    ? BoxDecoration(
                        color: selectedBlockColor,
                        borderRadius: BorderRadius.circular(18),
                      )
                    : null,
                child: Icon(
                  iconData,
                  size: isSelected ? 28 : 24,
                  color: isSelected ? iconSelectedColor : iconNormalColor,
                ),
              ),
              label: usedLabels[index],
            );
          }),
        ),
      ),
    );
  }
}
