import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  // Instancia de Storage
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube un archivo y devuelve la URL pública de descarga.
  /// Retorna null si falla.
  Future<String?> uploadImage(File image, String folderName) async {
    try {
      // 1. Crear nombre único para el archivo
      // Ejemplo: clientes/172839405_image.jpg
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 2. Crear la referencia (la ruta dentro de Firebase)
      final Reference ref = _storage.ref().child('$folderName/$fileName');

      // 3. Subir el archivo
      final UploadTask uploadTask = ref.putFile(image);

      // 4. Esperar a que termine la subida
      final TaskSnapshot snapshot = await uploadTask;

      // 5. Obtener la URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error subiendo imagen a Firebase: $e');
      return null;
    }
  }
}