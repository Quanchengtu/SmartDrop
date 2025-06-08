import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Record {
  final String crop;
  final String variety;
  final String stage;
  final String location;
  final DateTime dateTime;
  final String suggestion;
  //final String imageUrl;

  Record({
    required this.crop,
    required this.variety,
    required this.stage,
    required this.location,
    required this.dateTime,
    required this.suggestion,
    //required this.imageUrl,
    // required this.crop,
    // required this.variety,
    // required this.stage,
    // required this.location,
    // required this.dateTime,
    // required this.suggestion,
    // required this.imageUrl,
  });
}

class RecordPage extends StatelessWidget {
  final List<Record> records = [
    Record(
      crop: '番茄',
      variety: '台農2號',
      stage: '開花期',
      location: '台中市外埔區',
      dateTime: DateTime(2025, 6, 8, 3, 43),
      suggestion: '建議今日灌溉 6 公升，以維持最佳土壤濕度。',
      // imageUrl:
      //     'https://upload.wikimedia.org/wikipedia/commons/8/89/Tomato_je.jpg',
    ),
    Record(
      crop: '水稻',
      variety: '高雄139',
      stage: '幼苗期',
      location: '彰化縣田中鎮',
      dateTime: DateTime(2025, 6, 7, 14, 20),
      suggestion: '建議明日觀察土壤濕度，暫停灌溉。',
      // imageUrl:
      //     'https://upload.wikimedia.org/wikipedia/commons/6/6f/Oryza_sativa0.jpg',
    ),
    Record(
      crop: '甘藷',
      variety: '台農57號',
      stage: '塊根發育期',
      location: '雲林縣虎尾鎮',
      dateTime: DateTime(2025, 6, 6, 9, 10),
      suggestion: '預估降雨，建議延後灌溉以防過濕。',
      // imageUrl:
      //     'https://upload.wikimedia.org/wikipedia/commons/1/13/SweetPotato.jpg',
    ),
  ];

  final Color themeColor = const Color(0xFF007AFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('歷史紀錄'),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              // leading: Image.network(
              //   record.imageUrl,
              //   width: 60,
              //   height: 60,
              //   fit: BoxFit.cover,
              // ),
              title: Text(
                '${record.crop}（${record.variety}）',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              subtitle: Text(
                '地點：${record.location}\n時間：${DateFormat('yyyy/MM/dd HH:mm').format(record.dateTime)}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecordDetailPage(
                      record: record,
                      themeColor: themeColor,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class RecordDetailPage extends StatelessWidget {
  final Record record;
  final Color themeColor;

  const RecordDetailPage({required this.record, required this.themeColor});

  Widget buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: themeColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatted = DateFormat(
      'yyyy/MM/dd HH:mm',
    ).format(record.dateTime);
    return Scaffold(
      appBar: AppBar(
        title: const Text('詳細資訊'),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image.network(
            //   record.imageUrl,
            //   width: double.infinity,
            //   height: 200,
            //   fit: BoxFit.cover,
            // ),
            const SizedBox(height: 20),

            // 基本資訊
            buildSection('🌱 基本資訊', [
              Text('作物：${record.crop}', style: TextStyle(fontSize: 16)),
              Text('品種：${record.variety}', style: TextStyle(fontSize: 16)),
              Text('生長階段：${record.stage}', style: TextStyle(fontSize: 16)),
              Text('種植地點：${record.location}', style: TextStyle(fontSize: 16)),
              Text('土壤種類：壤土', style: TextStyle(fontSize: 16)),
              Text('灌溉方式：滴灌', style: TextStyle(fontSize: 16)),
              Text('種植面積：200平方公尺', style: TextStyle(fontSize: 16)),
            ]),

            // 天氣資訊
            buildSection('☁️ 天氣狀況', [
              Text('今日氣溫：32℃', style: TextStyle(fontSize: 16)),
              Text('相對濕度：55%', style: TextStyle(fontSize: 16)),
              Text('降雨機率：20%', style: TextStyle(fontSize: 16)),
              Text('風速：3m/s', style: TextStyle(fontSize: 16)),
            ]),

            // 用水建議
            buildSection('💧 節水建議', [
              Text(record.suggestion, style: TextStyle(fontSize: 16)),
            ]),

            // 時間
            Text(
              '🕒 紀錄時間：$timeFormatted',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
