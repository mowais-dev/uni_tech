import 'package:uni_tech/models/Category.dart';
import 'package:uni_tech/models/Product.dart';
import 'package:uni_tech/partials/animation_wrapper.dart';
import 'package:uni_tech/partials/glass_container.dart';
import 'package:uni_tech/providers/auth_provider.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:uni_tech/utilities/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsTable extends ConsumerStatefulWidget {
  final bool isIndexTable;

  const ProductsTable({this.isIndexTable = false, super.key});

  @override
  ConsumerState<ProductsTable> createState() => _ProductsTableState();
}

class _ProductsTableState extends ConsumerState<ProductsTable> {
  List<Product> products = [];

  Map<String, Category> categories = {};

  Future<void> loadProducts() async {
    final p = await getAllProducts();
    final c = await getCategoriesAsMap();
    if (!mounted) return;
    setState(() {
      products = p;
      categories = c;
    });
  }

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
      setState(() {
        products.removeWhere((product) => product.id == id);
      });
      showCustomAlert(
        context,
        'Product deleted successfully!',
        backgroundColor: ksuccess,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    bool showAction =
        widget.isIndexTable &&
        ref.read(authProvider.notifier).getAuth()!.role.name == "admin";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.isIndexTable) ...{
          AnimatedWrapper(
            duration: Duration(milliseconds: 800),
            animations: [AnimationAllowedType.slide],
            slideDirection: SlideDirection.right,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  label: "Add New Product",
                  size: "medium",
                  onClick: () {
                    ref
                        .read(navigationProvider.notifier)
                        .setScreen(AppRoutes.productsCreate);
                  },
                  backgroundColor: Colors.green,
                  foregroundColor: kwhite,
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
        },
        AnimatedWrapper(
          duration: Duration(milliseconds: 800),
          animations: [AnimationAllowedType.fade],
          child: GlassContainer(
            height:
                products.isNotEmpty ? null : MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(vertical: 10),
            child:
                products.isNotEmpty
                    ? DataTable(
                      dataRowHeight: 80,
                      dividerThickness: .5,
                      columns: [
                        DataColumn(
                          label: Text("Name", style: tableHeaderStyle),
                        ),
                        DataColumn(
                          label: Text("Category", style: tableHeaderStyle),
                        ),
                        DataColumn(
                          label: Text("Price", style: tableHeaderStyle),
                        ),
                        DataColumn(
                          label: Text("Stock", style: tableHeaderStyle),
                        ),
                        if (showAction) ...{
                          DataColumn(
                            label: Text("Action", style: tableHeaderStyle),
                          ),
                        },
                      ],
                      rows: [
                        ...products.map(
                          (product) => DataRow(
                            cells: [
                              DataCell(
                                onTap: () {
                                  ref
                                      .read(navigationProvider.notifier)
                                      .setScreen(
                                        AppRoutes.productsDetails,
                                        product.id,
                                      );
                                },
                                Row(
                                  children: [
                                    GlassContainer(
                                      width: 60,
                                      height: 60,
                                      padding: EdgeInsets.all(6),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(15),
                                        child: Image.network(product.image),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Text(product.name, style: tableCellStyle),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  categories[product.categoryId]!.name,
                                  style: tableCellStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  "\$${product.price.toString()}",
                                  style: tableCellStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  "${product.stock.toString()} Items left",
                                  style: tableCellStyle,
                                ),
                              ),
                              if (showAction) ...{
                                DataCell(
                                  Row(
                                    children: [
                                      CustomButton(
                                        label: "Edit",
                                        size: "small",
                                        onClick: () {
                                          ref
                                              .read(navigationProvider.notifier)
                                              .setScreen(
                                                AppRoutes.productsEdit,

                                                product.id,
                                              );
                                        },
                                        backgroundColor: Colors.blue,
                                        foregroundColor: kwhite,
                                      ),
                                      SizedBox(width: 10),
                                      CustomButton(
                                        label: "Delete",
                                        size: "small",
                                        onClick: () {
                                          deleteProductFromDB(product.id);
                                        },
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: kwhite,
                                      ),
                                    ],
                                  ),
                                ),
                              },
                            ],
                          ),
                        ),
                      ],
                    )
                    : Center(
                      child: Text("Loading...", style: tableHeaderStyle),
                    ),
          ),
        ),
      ],
    );
  }
}
