import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    if (selectedKeyword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกอาการก่อนเริ่มใช้งาน")),
      );
      return;
    }

    await SuggestionService.saveSuggestion(selectedKeyword!, skip: dontShowAgain);

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/select-course');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('คำแนะนำเบื้องต้น'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE1F5FE), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'คุณมีอาการใดมากที่สุด?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF205781)),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: keywordCategoryMap.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = keywordCategoryMap.entries.elementAt(index);
                      final isSelected = selectedKeyword == entry.key;
                      return InkWell(
                        onTap: () => setState(() => selectedKeyword = entry.key),
                        borderRadius: BorderRadius.circular(30),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF205781) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                            border: Border.all(
                              color: isSelected ? const Color(0xFF205781) : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? Colors.white : Colors.grey,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.key,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white : Colors.black87,
                                        )),
                                    const SizedBox(height: 4),
                                    Text("หมวด: ${entry.value}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isSelected ? Colors.white70 : Colors.black54,
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: dontShowAgain,
                      onChanged: (val) => setState(() => dontShowAgain = val ?? false),
                      activeColor: theme.primaryColor,
                    ),
                    const Text("ไม่ต้องแสดงหน้านี้อีก", style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('เริ่มใช้งาน', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
