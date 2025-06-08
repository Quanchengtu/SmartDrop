// 📁 recommendation_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestion = ModalRoute.of(context)!.settings.arguments as String?;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          '節水建議',
          style: TextStyle(color: CupertinoColors.activeBlue),
        ),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: suggestion == null
              ? const Center(child: Text('無建議資料'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💧 Gemini AI 分析建議：',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Markdown(
                        data: suggestion,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            fontFamily: 'PingFang TC',
                            color: CupertinoColors.label,
                          ),
                          strong: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
