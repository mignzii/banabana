import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';

class ImagePickerSheet extends StatelessWidget {
  final void Function(List<String> paths) onImagesPicked;
  const ImagePickerSheet({super.key, required this.onImagesPicked});

  Future<void> _pick(BuildContext context, ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final files = await picker.pickMultiImage(limit: 5);
      if (files.isNotEmpty) onImagesPicked(files.map((f) => f.path).toList());
    } else {
      final file = await picker.pickImage(source: source);
      if (file != null) onImagesPicked([file.path]);
    }
  }

  static void show(
    BuildContext context, {
    required void Function(List<String>) onImagesPicked,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ImagePickerSheet(onImagesPicked: onImagesPicked),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ajouter des photos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Galerie (max 5)'),
              onTap: () => _pick(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: const Text('Appareil photo'),
              onTap: () => _pick(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}
