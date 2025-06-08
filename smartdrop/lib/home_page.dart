import 'package:flutter/material.dart';
import 'crop_page5_updated.dart';
import 'recommendation_page.dart';
import 'record_page.dart';
import 'analysis_page_normal.dart';
import 'settings_page.dart'; // optional

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    CropPage(),
    RecommendationPage(),
    RecordPage(),
    AnalysisPage(),
    SettingsPage(), // optional
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFB3E5FC), // 淺藍色主題
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: '作物'),
          BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: '建議'),
          BottomNavigationBarItem(icon: Icon(Icons.note_add), label: '記錄'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '分析'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: const Color.fromARGB(255, 83, 82, 82),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
