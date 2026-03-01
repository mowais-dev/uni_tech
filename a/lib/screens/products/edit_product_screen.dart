import 'package:uni_tech/models/Product.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/utilities/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:uni_tech/models/Category.dart';
import 'package:uni_tech/partials/glass_container.dart';
import 'package:uni_tech/partials/layout/layout.dart';
import 'package:uni_tech/styles/texts.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;
  const EditProductScreen({required this.product, super.key});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  XFile? selectedImage;
  Uint8List? imageBytes;
  String? uploadedImageUrl;
  String? selectedCategoryId;

  /// Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.product.name;
    priceController.text = widget.product.price.toString();
    stockController.text = widget.product.stock.toString();
    selectedCategoryId = widget.product.categoryId;
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
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
  Future<void> uploadImage(Uint8List imageBytes, String productId) async {
    const apiKey = '488c3689e396e1b07659e01e29d12a9c'; // Replace with your key
    final url = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    try {
      String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        url,
        body: {'image': base64Image, 'name': productId},
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

  /// Add product via form
  Future<void> updateProductByForm() async {
    final String name = nameController.text.trim();
    final String price = priceController.text.trim();
    final String stock = stockController.text.trim();
    final String? categoryId = selectedCategoryId;

    if (name.isEmpty || price.isEmpty || stock.isEmpty || categoryId == null) {
      showCustomAlert(
        context,
        'Please fill all fields.',
        backgroundColor: kinfo,
      );
    }

    try {
      String imageUrl = widget.product.image;

      // Only upload new image if user picked one
      if (imageBytes != null) {
        await uploadImage(imageBytes!, widget.product.id);
        imageUrl = uploadedImageUrl!;
      }
      await updateProduct(widget.product.id, {
        "name": name,
        "image": imageUrl,
        "price": double.parse(price),
        "categoryId": categoryId,
        "stock": int.parse(stock),
      });

      showCustomAlert(
        context,
        'Product updated successfully!',
        backgroundColor: ksuccess,
      );
      ref.read(navigationProvider.notifier).setScreen(AppRoutes.productsIndex);
    } catch (e) {
      showCustomAlert(
        context,
        'Failed to update product: $e',
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
              Text("Add Product", style: formHeaderText),
              Text("Fill the fields below", style: formSubHeaderText),
              SizedBox(height: formSpacing),

              // Product Name + Price
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: nameController,
                      cursorColor: kwhite,
                      style: whiteText,
                      decoration: inputDecoration("Product Name"),
                    ),
                  ),
                  SizedBox(width: formSpacing),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: priceController,
                      cursorColor: kwhite,
                      style: whiteText,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: inputDecoration("Price"),
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
                      controller: stockController,
                      cursorColor: kwhite,
                      style: whiteText,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: inputDecoration("Stock"),
                    ),
                  ),
                  SizedBox(width: formSpacing),
                  Expanded(
                    flex: 1,
                    child: FutureBuilder<List<Category>>(
                      future: getAllCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text("No categories found");
                        }

                        final categories = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          initialValue: selectedCategoryId,
                          decoration: inputDecoration("Category"),
                          dropdownColor: Colors.black,
                          style: whiteText,
                          iconEnabledColor: kwhite,
                          items:
                              categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategoryId = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: formSpacing),

              // Image uploader
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Product Image", style: formSubHeaderText),
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
                                  widget.product.image,
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
                          .setScreen(AppRoutes.productsIndex);
                    },
                    child: Text("Cancel"),
                  ),
                  SizedBox(width: formSpacing),
                  // Save button
                  ElevatedButton(
                    style: primaryButton,
                    onPressed: updateProductByForm,
                    child: Text("Update Product", style: primaryButtonText),
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
