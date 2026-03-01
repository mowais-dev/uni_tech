import 'package:uni_tech/models/User.dart';
import 'package:uni_tech/providers/auth_provider.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/utilities/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:uni_tech/partials/glass_container.dart';
import 'package:uni_tech/partials/layout/layout.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:web/web.dart' as web;
import 'package:http/http.dart' as http;

class EditUserScreen extends ConsumerStatefulWidget {
  final User user;
  const EditUserScreen({required this.user, super.key});

  @override
  ConsumerState<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUserScreen> {
  XFile? selectedImage;
  Uint8List? imageBytes;
  String? uploadedImageUrl;

  /// Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user.name;
    emailController.text = widget.user.email;
    ageController.text = widget.user.age.toString();
    phoneController.text = widget.user.phone;
    passwordController.text = widget.user.password;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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

  Future<void> uploadImage(Uint8List imageBytes, String userId) async {
    const apiKey = '488c3689e396e1b07659e01e29d12a9c';
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
      }
    } catch (e) {
      /* .. */
    }
  }

  Future<void> updateUserByForm() async {
    final String name = nameController.text.trim();
    final String age = ageController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String phone = phoneController.text.trim();

    if (name.isEmpty ||
        age.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty) {
      showCustomAlert(
        context,
        'Please fill all fields.',
        backgroundColor: kinfo,
      );
    }

    try {
      String imageUrl = widget.user.image;

      if (imageBytes != null) {
        await uploadImage(imageBytes!, widget.user.id);
        imageUrl = uploadedImageUrl!;
      }
      await updateUser(widget.user.id, {
        "name": name,
        "image": imageUrl,
        "age": age,
        "email": email,
        "password": password,
        "phone": phone,
      });

      String loggedInUserId = ref.read(authProvider.notifier).getAuth()!.id;
      User? updatedUser = await getUserById(widget.user.id);

      if (updatedUser == null) {
        showCustomAlert(context, 'User Not updated!', backgroundColor: kdanger);
      } else {
        if (widget.user.id == loggedInUserId) {
          ref.read(authProvider.notifier).setAuth(updatedUser);
        }

        web.window.localStorage.setItem(
          "token",
          encryptToken("${updatedUser.id} ${updatedUser.password}"),
        );
        showCustomAlert(
          context,
          'User updated successfully!',
          backgroundColor: ksuccess,
        );
      }

      AppRoutes navigateTo =
          widget.user.id == loggedInUserId
              ? AppRoutes.myProfile
              : AppRoutes.usersDetails;

      ref
          .read(navigationProvider.notifier)
          .setScreen(navigateTo, widget.user.id);
    } catch (e) {
      showCustomAlert(
        context,
        'Failed to update user: $e',
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
              Text("Edit Profile", style: formHeaderText),
              Text("Fill the fields below", style: formSubHeaderText),
              SizedBox(height: formSpacing),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: nameController,
                      cursorColor: kwhite,
                      style: whiteText,
                      decoration: inputDecoration("Name"),
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
                      controller: ageController,
                      cursorColor: kwhite,
                      style: whiteText,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: inputDecoration("Age"),
                    ),
                  ),
                  SizedBox(width: formSpacing),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: phoneController,
                      cursorColor: kwhite,
                      style: whiteText,
                      decoration: inputDecoration("Phone Number"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: formSpacing),
              if (ref.read(authProvider.notifier).getAuth()!.id ==
                  widget.user.id) ...{
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
              },
              SizedBox(height: formSpacing),

              // Image uploader
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Profile Image", style: formSubHeaderText),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            imageBytes != null
                                ? Image.memory(imageBytes!, fit: BoxFit.contain)
                                : Image.network(
                                  widget.user.image,
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
                    onPressed: updateUserByForm,
                    child: Text("Update Profile", style: primaryButtonText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
