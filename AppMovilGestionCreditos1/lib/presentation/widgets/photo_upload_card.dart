import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoUploadCard extends StatefulWidget {
  final String label;
  final Function(File?) onImageSelected;

  const PhotoUploadCard({
    super.key,
    required this.label,
    required this.onImageSelected,
  });

  @override
  State<PhotoUploadCard> createState() => _PhotoUploadCardState();
}

class _PhotoUploadCardState extends State<PhotoUploadCard> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      widget.onImageSelected(_image); // Devolvemos la imagen al padre
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        height: 150,
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _OptionBtn(Icons.camera_alt, 'Cámara', () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            }),
            _OptionBtn(Icons.image, 'Galería', () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GestureDetector(
          onTap: _showOptions,
          child: Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
              image: _image != null
                  ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: _image == null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_rounded, size: 40, color: theme.primaryColor),
                const SizedBox(height: 5),
                Text("Subir Foto", style: TextStyle(color: theme.primaryColor)),
              ],
            )
                : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.black26, // Filtro oscuro para ver el icono de editar
              ),
              child: const Center(
                child: Icon(Icons.edit, color: Colors.white, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

// Botón auxiliar interno
class _OptionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OptionBtn(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 30, child: Icon(icon)),
          const SizedBox(height: 5),
          Text(label)
        ],
      ),
    );
  }
}