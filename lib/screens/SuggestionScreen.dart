import 'package:flutter/material.dart';
import 'package:theraphy_flutter/services/suggestion_service.dart';

class SuggestionScreen extends StatefulWidget {
  const SuggestionScreen({super.key});

  @override
  State<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {
  final Map<String, String> keywordCategoryMap = SuggestionService.keywordCategoryMap;

  String? selectedKeyword;
  bool dontShowAgain = false;

  void _submit() async {
    if (selectedKeyword == null) return;

    await SuggestionService.saveSuggestion(selectedKeyword!, skip: dontShowAgain);

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/select-course');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('คำแนะนำเบื้องต้น')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('คุณมีอาการใดมากที่สุด?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            // 🔁 สร้าง RadioList จาก map
            ...keywordCategoryMap.entries.map((entry) => RadioListTile(
                  title: Text(entry.key),
                  value: entry.key,
                  groupValue: selectedKeyword,
                  onChanged: (val) {
                    setState(() {
                      selectedKeyword = val as String;
                    });
                  },
                )),

            const SizedBox(height: 20),

            CheckboxListTile(
              value: dontShowAgain,
              onChanged: (val) => setState(() => dontShowAgain = val ?? false),
              title: const Text("ไม่ต้องแสดงหน้านี้อีก"),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const Spacer(),

            Center(
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('เริ่มใช้งาน'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
