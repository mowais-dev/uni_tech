import 'package:uni_tech/models/Category.dart';
import 'package:uni_tech/models/Product.dart';
import 'package:uni_tech/partials/glass_container.dart';
import 'package:uni_tech/partials/layout/layout.dart';
import 'package:uni_tech/providers/auth_provider.dart';
import 'package:uni_tech/providers/cart_provider.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:uni_tech/utilities/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DetailProductScreen extends ConsumerStatefulWidget {
  final Product product;
  final Category? category;
  const DetailProductScreen({
    required this.product,
    required this.category,
    super.key,
  });

  @override
  ConsumerState<DetailProductScreen> createState() =>
      _DetailProductScreenState();
}

class _DetailProductScreenState extends ConsumerState<DetailProductScreen> {
  Future<void> deleteProductFromDB(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // prevent closing by tapping outside
      builder: (context) {
        return AlertDialog(
          alignment: Alignment.center, // ⬅ centers the alert on screen
          backgroundColor: Color.fromARGB(255, 22, 22, 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Delete Product', style: whiteText),
          content: const Text(
            'Are you sure you want to delete this product?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete', style: whiteText),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Perform deletion
      await deleteProduct(id);

      showCustomAlert(
        context,
        'Product deleted successfully!',
        backgroundColor: ksuccess,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin =
        ref.read(authProvider.notifier).getAuth()!.role.name == "admin";
    return Layout(
      content: SingleChildScrollView(
        child: Column(
          children: [
            GlassContainer(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(fontSize: 30, color: kwhite),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            widget.product.image,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Stock:",
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: kwhite,
                                      ),
                                    ),
                                    Text(
                                      widget.product.stock.toString(),
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: kwhite,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Price:",
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: kwhite,
                                      ),
                                    ),
                                    Text(
                                      "\$${widget.product.price}",
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: kwhite,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Category:",
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: kwhite,
                                      ),
                                    ),
                                    Text(
                                      widget.category!.name,
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: kwhite,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Date of Creation:",
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: kwhite,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('yyyy-MM-dd').format(
                                        widget.product.createdAt.toDate(),
                                      ),
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: kwhite,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 60),
                            Column(
                              children: [
                                Row(
                                  children:
                                      isAdmin
                                          ? [
                                            Expanded(
                                              child: CustomButton(
                                                backgroundColor: kinfo,
                                                label: "Edit",
                                                onClick: () {
                                                  ref
                                                      .read(
                                                        navigationProvider
                                                            .notifier,
                                                      )
                                                      .setScreen(
                                                        AppRoutes.productsEdit,
                                                        widget.product.id,
                                                      );
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: CustomButton(
                                                backgroundColor: kdanger,
                                                label: "Delete",
                                                onClick: () {
                                                  deleteProductFromDB(
                                                    widget.product.id,
                                                  );
                                                },
                                              ),
                                            ),
                                          ]
                                          : [
                                            Expanded(
                                              child: CustomButton(
                                                // backgroundColor: kinfo,
                                                label: "Order now",
                                                onClick: () {
                                                  ref
                                                      .read(
                                                        cartProvider.notifier,
                                                      )
                                                      .clear();
                                                  ref
                                                      .read(
                                                        cartProvider.notifier,
                                                      )
                                                      .addItem(widget.product);
                                                  ref
                                                      .read(
                                                        navigationProvider
                                                            .notifier,
                                                      )
                                                      .setScreen(
                                                        AppRoutes.shopCheckout,
                                                      );
                                                },
                                              ),
                                            ),
                                          ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        foregroundColor: kwhite,
                                        backgroundColor: Colors.black,
                                        label: "Go Back",
                                        onClick: () {
                                          ref
                                              .read(navigationProvider.notifier)
                                              .setScreen(
                                                AppRoutes.productsIndex,
                                              );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
