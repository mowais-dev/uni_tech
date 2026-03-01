import 'package:uni_tech/models/Category.dart';
import 'package:uni_tech/models/Product.dart';
import 'package:uni_tech/partials/animation_wrapper.dart';
import 'package:uni_tech/partials/glass_container.dart';
import 'package:uni_tech/partials/layout/layout.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CategoryProfileScreen extends ConsumerStatefulWidget {
  const CategoryProfileScreen({required this.category, super.key});
  final Category? category;

  @override
  ConsumerState<CategoryProfileScreen> createState() =>
      _CategoryProfileScreenState();
}

class _CategoryProfileScreenState extends ConsumerState<CategoryProfileScreen> {
  List<Product> categoryProducts = [];
  String placeholder = "Loading...";

  @override
  void initState() {
    super.initState();
    loadCategoryProducts();
  }

  Future<void> loadCategoryProducts() async {
    List<Product> a = await getCategoryProducts(widget.category!.id);
    setState(() {
      if (a.isNotEmpty) {
        categoryProducts = a;
      } else {
        placeholder = "There are 0 products created under this category.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      content: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: categoryProducts.isNotEmpty ? 300 : 500,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 35,
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(style: formHeaderText, widget.category!.name),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(style: whiteText, "Created at:"),
                          Text(
                            style: whiteText,
                            DateFormat(
                              'yyyy-MM-dd',
                            ).format(widget.category!.createdAt.toDate()),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(style: whiteText, "Total Products:"),
                          Text(
                            style: whiteText,
                            categoryProducts.length.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),
              Expanded(
                flex: 65,
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Products in this category", style: formHeaderText),
                      SizedBox(height: 20),
                      if (categoryProducts.isNotEmpty) ...{
                        for (int i = 0; i < categoryProducts.length; i++) ...{
                          InkWell(
                            onTap: () {
                              ref
                                  .read(navigationProvider.notifier)
                                  .setScreen(
                                    AppRoutes.productsDetails,
                                    categoryProducts[i].id,
                                  );
                            },
                            child: AnimatedWrapper(
                              duration: Duration(milliseconds: i * 350),
                              animations: [AnimationAllowedType.fade],
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadiusGeometry.directional(
                                            bottomStart: Radius.circular(20),
                                            topStart: Radius.circular(20),
                                          ),
                                      child: Image.network(
                                        categoryProducts[i].image,
                                        height: 60,
                                        width: 60,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 9,
                                    child: GlassContainer(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 20,
                                      ),
                                      border: BorderRadius.only(
                                        bottomRight: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            categoryProducts[i].name,
                                            style: formSubHeaderText,
                                          ),
                                          Text(
                                            "\$${categoryProducts[i].price}",
                                            style: formSubHeaderText,
                                          ),
                                          Text(
                                            "${categoryProducts[i].stock} Items Left",
                                            style: formSubHeaderText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        },
                      } else ...{
                        Center(
                          child: Text(placeholder, style: formSubHeaderText),
                        ),
                      },
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
