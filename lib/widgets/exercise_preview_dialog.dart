import 'package:flutter/material.dart';

class ExercisePreviewDialog extends StatelessWidget {
  final String title;
  final String imageAsset;
  final String description;

  const ExercisePreviewDialog({
    super.key,
    required this.title,
    required this.imageAsset,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageAsset,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 120, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('ดูคำเตือนและเริ่มฝึก'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
  }
}
