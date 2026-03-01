import 'package:uni_tech/models/User.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/utilities/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:uni_tech/partials/glass_container.dart';
import 'package:uni_tech/partials/layout/layout.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:uuid/uuid.dart';

class AddUserScreen extends ConsumerStatefulWidget {
  const AddUserScreen({super.key});

  @override
  ConsumerState<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends ConsumerState<AddUserScreen> {
  XFile? selectedImage;
  Uint8List? imageBytes;
  String? uploadedImageUrl;
  String? selectedCategoryId;

  /// Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Pick an image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        selectedImage = file;
        imageBytes = bytes;
      });
    }
  }

  /// Upload image to ImgBB
  Future<void> uploadImage(Uint8List imageBytes, String userId) async {
    const apiKey = '488c3689e396e1b07659e01e29d12a9c'; // Replace with your key
    final url = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    try {
      String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        url,
        body: {'image': base64Image, 'name': userId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data']['url'] as String;

        setState(() {
          uploadedImageUrl = imageUrl;
        });

        print('✅ Image uploaded successfully: $imageUrl');
      } else {
        print('❌ Upload failed: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('⚠️ Error uploading image: $e');
    }
  }

  /// Add user via form
  Future<void> addUserByForm() async {
    if (imageBytes == null) {
      showCustomAlert(
        context,
        'Please upload an image first!',
        backgroundColor: kinfo,
      );
      return;
    }

    final String name = nameController.text.trim();
    final int age = int.tryParse(ageController.text.trim()) ?? 0;
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String phone = phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      showCustomAlert(
        context,
        'Please fill all fields.',
        backgroundColor: kinfo,
      );
    }

    // 🧩 Example: call your addUser() function
    try {
      String id = const Uuid().v4();
      await uploadImage(imageBytes!, id);
      await addUser(
        name,
        email,
        uploadedImageUrl!,
        age,
        password,
        phone,
        UserRole.user,
      );

      // Clear fields
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      phoneController.clear();
      ageController.clear();
      setState(() {
        selectedCategoryId = null;
        imageBytes = null;
        uploadedImageUrl = null;
      });
    } catch (e) {
      showCustomAlert(
        context,
        'Failed to add user: $e',
        backgroundColor: kdanger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      content: GlassContainer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add User", style: formHeaderText),
              Text("Fill the fields below", style: formSubHeaderText),
              SizedBox(height: formSpacing),

              // User Name + Price
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: nameController,
                      cursorColor: kwhite,
                      style: whiteText,
                      decoration: inputDecoration("User Name"),
                    ),
                  ),
                  SizedBox(width: formSpacing),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: emailController,
                      cursorColor: kwhite,
                      style: whiteText,
                      decoration: inputDecoration("Email"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: formSpacing),

              // Stock + Category
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: phoneController,
                      cursorColor: kwhite,
                      style: whiteText,
                      decoration: inputDecoration("Phone Number"),
                    ),
                  ),
                  SizedBox(width: formSpacing),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: ageController,
                      cursorColor: kwhite,
                      style: whiteText,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: inputDecoration("Age"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: formSpacing),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: passwordController,
                      cursorColor: kwhite,
                      style: whiteText,
                      decoration: inputDecoration("Password"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: formSpacing),

              // Image uploader
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("User Image", style: formSubHeaderText),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: kwhite),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black26,
                      ),
                      child:
                          imageBytes == null
                              ? Center(
                                child: Text(
                                  "Tap to select image",
                                  style: whiteText,
                                ),
                              )
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  imageBytes!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                    ),
                  ),
                  if (uploadedImageUrl != null) ...[
                    SizedBox(height: 8),
                    Text("Uploaded: $uploadedImageUrl", style: whiteText),
                  ],
                ],
              ),

              SizedBox(height: formSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: primaryButtonInvert,
                    onPressed: () {
                      ref
                          .read(navigationProvider.notifier)
                          .setScreen(AppRoutes.usersIndex);
                    },
                    child: Text("Cancel"),
                  ),
                  SizedBox(width: formSpacing),
                  ElevatedButton(
                    style: primaryButton,
                    onPressed: () async {
                      if (imageBytes == null) {
                        showCustomAlert(
                          context,
                          'Please select an image first!',
                          backgroundColor: kwarning,
                        );
                        return;
                      }
                      await addUserByForm();
                      showCustomAlert(
                        context,
                        'User created Successfully!',
                        backgroundColor: ksuccess,
                      );
                      ref
                          .read(navigationProvider.notifier)
                          .setScreen(AppRoutes.usersIndex);
                    },
                    child: Text("Save User", style: primaryButtonText),
                  ),
                ],
              ),
              // Save button
            ],
          ),
        ),
      ),
    );
  }
}
