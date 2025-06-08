// 📁 檔名：crop_page.dart（美化輸入欄位 + 地圖 + SQLite） 開始接API 並分析結果

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropPage extends StatefulWidget {
  const CropPage({Key? key}) : super(key: key);

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();
  double _currentZoom = 7.0;

  String cropType = '稻米';
  String cropVariety = '';
  String growthStage = '育苗期';
  LatLng? selectedLocation;
  String soilType = '壤土';
  String irrigationMethod = '滴灌';
  double area = 100;
  bool isLoading = false;
  String? suggestionResult;

  final List<String> cropTypes = ['稻米', '番茄', '高麗菜'];
  final Map<String, List<String>> cropStages = {
    '稻米': ['育苗期', '分蘗期', '抽穗期', '成熟期'],
    '番茄': ['苗期', '開花期', '結果期', '成熟期'],
    '高麗菜': ['定植期', '結球期', '成熟期'],
  };
  final Map<String, List<String>> cropVarieties = {
    '稻米': ['台南11號', '台中秈10號'],
    '番茄': ['聖女小番茄', '牛番茄'],
    '高麗菜': ['夏高麗', '冬高麗'],
  };
  final List<String> soilTypes = ['砂質壤土', '黏土', '壤土'];
  final List<String> irrigationMethods = ['滴灌', '漫灌', '噴灌'];
  List<String> get currentStageOptions => cropStages[cropType]!;
  List<String> get currentVarietyOptions => cropVarieties[cropType]!;

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    if (selectedLocation == null) return;

    setState(() => isLoading = true);

    try {
      final db = await openDatabase(
        join(await getDatabasesPath(), 'crop.db'),
        onCreate: (db, version) {
          return db.execute('''CREATE TABLE crops(
          id INTEGER PRIMARY KEY,
          cropType TEXT, cropVariety TEXT, growthStage TEXT,
          latitude REAL, longitude REAL,
          soilType TEXT, irrigationMethod TEXT, area REAL
        )''');
        },
        version: 1,
      );
      await db.insert('crops', {
        'cropType': cropType,
        'cropVariety': cropVariety,
        'growthStage': growthStage,
        'latitude': selectedLocation!.latitude,
        'longitude': selectedLocation!.longitude,
        'soilType': soilType,
        'irrigationMethod': irrigationMethod,
        'area': area,
      });

      final weatherRes = await http.post(
        //Uri.parse('http://127.0.0.1:8000/weather'),
        Uri.parse('https://gemini-api-101700959874.asia-east1.run.app/weather'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'location': {
            'lat': selectedLocation!.latitude,
            'lng': selectedLocation!.longitude,
          },
        }),
      );
      final weatherData = jsonDecode(weatherRes.body);

      final prompt =
          '''
作物：$cropType
品種：$cropVariety
生長階段：$growthStage
種植面積：${area.toStringAsFixed(0)} 平方公尺
土壤種類：$soilType
灌溉方式：$irrigationMethod
當地天氣：
- 今日氣溫：${weatherData['temperature']}℃
- 相對濕度：${weatherData['humidity']}%
- 降雨機率：${weatherData['rain_prob']}%
- 風速：${weatherData['wind_speed']} m/s
請針對上述資訊，建議：
1. 今日建議用水量
2. 適合灌溉的時間段，並簡要說明原因。
''';

      final geminiRes = await http.post(
        //Uri.parse('http://127.0.0.1:8000/chat'),
        Uri.parse('https://gemini-api-101700959874.asia-east1.run.app/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );
      final geminiReply = jsonDecode(geminiRes.body);
      final suggestion = geminiReply['response'];

      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('完成分析'),
          content: const Text('點選下方按鈕查看節水建議'),
          actions: [
            CupertinoDialogAction(
              child: const Text('查看建議'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/recommendation',
                  arguments: suggestion,
                );
              },
            ),
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => suggestionResult = '發生錯誤：$e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          '作物灌溉建議',
          style: TextStyle(color: CupertinoColors.activeBlue),
        ),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),
              _buildSection('作物種類', cropType, cropTypes, (val) {
                setState(() {
                  cropType = val!;
                  cropVariety = cropVarieties[cropType]!.first;
                  growthStage = cropStages[cropType]!.first;
                });
              }),
              _buildSection(
                '品種',
                cropVariety,
                currentVarietyOptions,
                (val) => setState(() => cropVariety = val!),
              ),
              _buildSection(
                '生長階段',
                growthStage,
                currentStageOptions,
                (val) => setState(() => growthStage = val!),
              ),
              const SizedBox(height: 12),
              const Text(
                '選擇種植地區（點擊地圖）：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 320,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: LatLng(23.5, 121),
                          zoom: _currentZoom,
                          onTap: (tapPos, latlng) =>
                              setState(() => selectedLocation = latlng),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          if (selectedLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: selectedLocation!,
                                  builder: (_) => const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Column(
                          children: [
                            FloatingActionButton(
                              mini: true,
                              backgroundColor: CupertinoColors.systemGrey4,
                              onPressed: _zoomIn,
                              child: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton(
                              mini: true,
                              backgroundColor: CupertinoColors.systemGrey4,
                              onPressed: _zoomOut,
                              child: const Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (selectedLocation != null)
                Text(
                  '📍 經度: ${selectedLocation!.longitude.toStringAsFixed(5)}, 緯度: ${selectedLocation!.latitude.toStringAsFixed(5)}',
                ),
              _buildSection(
                '土壤種類',
                soilType,
                soilTypes,
                (val) => setState(() => soilType = val!),
              ),
              _buildSection(
                '灌溉方式',
                irrigationMethod,
                irrigationMethods,
                (val) => setState(() => irrigationMethod = val!),
              ),
              const SizedBox(height: 12),
              Text(
                '種植面積（平方公尺）：${area.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16),
              ),
              CupertinoSlider(
                value: area,
                min: 50,
                max: 500,
                divisions: 9,
                onChanged: (val) => setState(() => area = val),
              ),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(30),
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: isLoading ? null : _submitData,
                child: isLoading
                    ? const CupertinoActivityIndicator()
                    : const Text('送出', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              if (suggestionResult != null)
                Text(
                  suggestionResult!,
                  style: const TextStyle(color: CupertinoColors.activeGreen),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String label,
    String value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            borderRadius: BorderRadius.circular(12),
            color: CupertinoColors.systemGrey5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 16)),
                const Icon(CupertinoIcons.chevron_down, size: 18),
              ],
            ),
            onPressed: () async {
              final result = await showCupertinoModalPopup(
                context: context,
                builder: (_) => CupertinoActionSheet(
                  title: Text(label),
                  actions: options
                      .map(
                        (opt) => CupertinoActionSheetAction(
                          onPressed: () => Navigator.pop(context, opt),
                          child: Text(opt),
                        ),
                      )
                      .toList(),
                  cancelButton: CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ),
              );
              if (result != null) onChanged(result);
            },
          ),
        ],
      ),
    );
  }
}
