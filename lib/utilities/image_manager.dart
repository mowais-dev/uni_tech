import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Pick an image from gallery
Future<XFile?> pickImage() async {
  final picker = ImagePicker();
  return await picker.pickImage(source: ImageSource.gallery);
}

/// Upload image (web only)
Future<String> uploadImage(XFile file, String productId) async {
  // Convert image to bytes
  Uint8List data = await file.readAsBytes();

  // Create a reference in Firebase Storage
  final storageRef = FirebaseStorage.instance.ref();
  final imageRef = storageRef.child("products/$productId.jpg");

  // Upload the file as bytes
  UploadTask uploadTask = imageRef.putData(data);
  TaskSnapshot snapshot = await uploadTask;

  // Get the download URL
  String downloadUrl = await snapshot.ref.getDownloadURL();
  print("Image uploaded: $downloadUrl");
  return downloadUrl;
}
