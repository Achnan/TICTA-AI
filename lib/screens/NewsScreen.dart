import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/thera_app_bar.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  int _navIndex = 0;

  void _onNavTapped(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/select-course');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const TheraAppBar(title: "ข่าวสาร"),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Text(
            'ประกาศสำคัญ',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 1.5),

          const SizedBox(height: 16),

          _buildNewsCard(
            imagePath: 'assets/picture/therapy_news.png',
            title: 'คำแนะนำจากผู้เชี่ยวชาญด้านกายภาพ',
            date: '18 กรกฎาคม 2025',
            author: 'นพ. สมคิด แซ่แต้',
          ),

          const SizedBox(height: 24),

          _buildNewsCard(
            imagePath: 'assets/picture/therapy_news.png',
            title: 'กิจกรรมฟื้นฟูสำหรับผู้สูงอายุประจำสัปดาห์',
            date: '16 กรกฎาคม 2025',
            author: 'ศูนย์ฟื้นฟูสุขภาพ',
          ),
        ],
      ),
      bottomNavigationBar: TheraBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTapped,
      ),
    );
  }

  Widget _buildNewsCard({
    required String imagePath,
    required String title,
    required String date,
    required String author,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.2)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.centerLeft,
            child: Text(
              '$author • $date',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          )
        ],
      ),
    );
  }
}
