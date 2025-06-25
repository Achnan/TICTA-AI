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

  static const Color bgColor = Color(0xFF1C3D5A); // Dark navy
  static const Color selectedBlockColor = Color(0xFF2C7A7B); // Softer teal
  static const Color iconNormalColor = Color(0xFF91BEBE);
  static const Color iconSelectedColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final usedLabels = labels ?? ['ข่าวสาร', 'เลือกคอร์ส', 'ผู้ใช้งาน'];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedItemColor: iconSelectedColor,
        unselectedItemColor: iconNormalColor,
        items: [
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(Icons.newspaper, 0),
            label: usedLabels[0],
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(Icons.accessibility_new_rounded, 1),
            label: usedLabels[1],
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(Icons.emoji_events_rounded, 2),
            label: usedLabels[2],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    final bool isSelected = index == currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: isSelected
          ? BoxDecoration(
              color: selectedBlockColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            )
          : null,
      child: Icon(
        icon,
        size: isSelected ? 28 : 24,
        color: isSelected ? iconSelectedColor : iconNormalColor,
      ),
    );
  }
}
