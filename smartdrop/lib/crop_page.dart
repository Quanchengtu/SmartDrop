// 📁 檔名：crop_page.dart（含 iOS 風格 + 對應品種與土壤）

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropPage extends StatefulWidget {
  const CropPage({Key? key}) : super(key: key);

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  final _formKey = GlobalKey<FormState>();

  String cropType = '稻米';
  String cropVariety = '';
  String growthStage = '育苗期';
  String location = '';
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

    setState(() => isLoading = true);

    try {
      final weatherResponse = await http.post(
        Uri.parse('http://127.0.0.1:8000/weather'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"location": location}),
      );
      final weatherData = jsonDecode(weatherResponse.body);

      final prompt =
          '''
作物：$cropType
品種：$cropVariety
生長階段：$growthStage
種植地點：$location
土壤種類：$soilType
灌溉方式：$irrigationMethod
種植面積：${area.toStringAsFixed(0)} 平方公尺

氣象資料：
- 今日氣溫：${weatherData['temperature']}℃
- 相對濕度：${weatherData['humidity']}%
- 降雨機率：${weatherData['rain_prob']}%
- 風速：${weatherData['wind_speed']}m/s

請依據上述資料，建議今日的灌溉用水量與適合灌溉的時段，並簡要說明原因。
''';

      final geminiResponse = await http.post(
        Uri.parse('http://127.0.0.1:8000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"prompt": prompt}),
      );
      final geminiData = jsonDecode(geminiResponse.body);

      setState(() => suggestionResult = geminiData['response']);
    } catch (e) {
      setState(() => suggestionResult = '發生錯誤：$e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          '作物灌溉建議',
          //style: TextStyle(color: CupertinoColors.activeBlue),
          style: TextStyle(
            color: CupertinoColors.white, // 改為白字
            fontWeight: FontWeight.bold, // 加粗（可選）
            fontSize: 18, // 放大一點（可選）
          ),
        ),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildDropdown('作物種類', cropType, cropTypes, (val) {
                  setState(() {
                    cropType = val!;
                    cropVariety = cropVarieties[cropType]!.first;
                    growthStage = cropStages[cropType]!.first;
                  });
                }),
                const SizedBox(height: 12),
                _buildDropdown(
                  '品種',
                  cropVariety,
                  currentVarietyOptions,
                  (val) => setState(() => cropVariety = val!),
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  '生長階段',
                  growthStage,
                  currentStageOptions,
                  (val) => setState(() => growthStage = val!),
                ),
                const SizedBox(height: 12),
                _buildTextField('種植地點', (val) => location = val!),
                const SizedBox(height: 12),
                _buildDropdown(
                  '土壤種類',
                  soilType,
                  soilTypes,
                  (val) => setState(() => soilType = val!),
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                  '灌溉方式',
                  irrigationMethod,
                  irrigationMethods,
                  (val) => setState(() => irrigationMethod = val!),
                ),
                const SizedBox(height: 12),
                Text('種植面積（平方公尺）：${area.toStringAsFixed(0)}'),
                CupertinoSlider(
                  value: area,
                  min: 50,
                  max: 500,
                  divisions: 9,
                  onChanged: (val) => setState(() => area = val),
                ),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  onPressed: isLoading ? null : _submitData,
                  child: isLoading
                      ? const CupertinoActivityIndicator()
                      : const Text('送出'),
                ),
                const SizedBox(height: 20),
                if (suggestionResult != null) ...[
                  const Text(
                    '💡 建議結果：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(suggestionResult!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: CupertinoColors.systemGrey5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(value), const Icon(CupertinoIcons.chevron_down)],
          ),
          onPressed: () => showCupertinoModalPopup(
            context: context,
            builder: (_) => CupertinoActionSheet(
              title: Text('選擇 $label'),
              actions: options
                  .map(
                    (opt) => CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                        onChanged(opt);
                      },
                      child: Text(opt),
                    ),
                  )
                  .toList(),
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context),
                isDefaultAction: true,
                child: const Text('取消'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, void Function(String?) onSaved) {
    return CupertinoTextFormFieldRow(
      placeholder: label,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      validator: (val) => val == null || val.isEmpty ? '請填寫$label' : null,
      onSaved: onSaved,
    );
  }
}
