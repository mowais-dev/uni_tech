import 'package:uni_tech/models/Category.dart';
import 'package:uni_tech/partials/animation_wrapper.dart';
import 'package:uni_tech/partials/glass_container.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:uni_tech/utilities/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesList extends ConsumerStatefulWidget {
  const CategoriesList({super.key});

  @override
  ConsumerState<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends ConsumerState<CategoriesList> {
  List<Category> categories = [];
  String placeholderText = "Loading...";
  bool confirmingDeletion = false;
  final TextEditingController nameControllerForEditing =
      TextEditingController();
  final TextEditingController nameControllerForCreation =
      TextEditingController();
  Future<void> loadcategories() async {
    final u = await getAllCategories();
    setState(() {
      categories = u;
      if (categories.isEmpty) {
        placeholderText = "No Categories found";
      }
    });
  }

  Future<void> updateCategoryFromDB(int index) async {
    await updateCategory(categories[index].id, {
      "name": nameControllerForEditing.text,
    });

    setState(() {
      categories[index].name = nameControllerForEditing.text;
    });
  }

  Future<void> deleteCategoryFromDB(String id) async {
    await deleteCategory(id);
    setState(() {
      categories.removeWhere((category) => category.id == id);
    });
    showCustomAlert(
      context,
      'Category deleted successfully!',
      backgroundColor: ksuccess,
    );
  }

  Future<void> addCategoryToDB() async {
    await addCategory(nameControllerForCreation.text);
    loadcategories();
  }

  Future<void> openCategoryUpdateModal(int index) async {
    Category category = categories[index];
    nameControllerForEditing.text = category.name;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 22, 22, 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text("Update Category", style: formHeaderText),
              content:
                  confirmingDeletion
                      ? Text(
                        "Do you really want to delete this category? All products of this category will be deleted too.",
                        style: formSubHeaderText,
                      )
                      : TextField(
                        controller: nameControllerForEditing,
                        cursorColor: kwhite,
                        style: whiteText,
                        keyboardType: TextInputType.text,
                        decoration: inputDecoration("Category Name"),
                      ),
              actions:
                  confirmingDeletion
                      ? [
                        TextButton(
                          onPressed: () {
                            setStateDialog(() {
                              confirmingDeletion = false;
                            });
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kdanger,
                          ),
                          onPressed: () {
                            deleteCategoryFromDB(category.id);
                            Navigator.pop(context);
                          },
                          child: Text('Delete', style: whiteText),
                        ),
                      ]
                      : [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white70,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel', style: whiteText),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kinfo,
                          ),
                          onPressed: () {
                            updateCategoryFromDB(index);
                            Navigator.pop(context);
                            showCustomAlert(
                              context,
                              "Category Updated!",
                              backgroundColor: kinfo,
                            );
                          },
                          child: Text('Update', style: whiteText),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kdanger,
                          ),
                          onPressed: () {
                            setStateDialog(() {
                              confirmingDeletion = true;
                            });
                          },
                          child: Text('Delete This Category', style: whiteText),
                        ),
                      ],
            );
          },
        );
      },
    );
  }

  Future<void> openCategoryAddModal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 22, 22, 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text("Create New Category", style: formHeaderText),
              content: TextField(
                controller: nameControllerForCreation,
                cursorColor: kwhite,
                style: whiteText,
                keyboardType: TextInputType.text,
                decoration: inputDecoration("Category Name"),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: whiteText),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: ksuccess),
                  onPressed: () {
                    addCategoryToDB();
                    Navigator.pop(context);
                    showCustomAlert(
                      context,
                      "Category Created!",
                      backgroundColor: ksuccess,
                    );
                  },
                  child: Text('Create', style: whiteText),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadcategories();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedWrapper(
            duration: Duration(milliseconds: 800),
            animations: [AnimationAllowedType.slide],
            slideDirection: SlideDirection.right,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  label: "Add New Category",
                  size: "medium",
                  onClick: openCategoryAddModal,
                  backgroundColor: Colors.green,
                  foregroundColor: kwhite,
                ),
              ],
            ),
          ),
          SizedBox(height: 25),

          categories.isNotEmpty
              ? GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 6,
                ),
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  return InkWell(
                    onTap: () {
                      ref
                          .read(navigationProvider.notifier)
                          .setScreen(
                            AppRoutes.categoriesDetails,
                            categories[i].id,
                          );
                    },
                    child: AnimatedWrapper(
                      duration: Duration(milliseconds: i * 150),
                      animations: [AnimationAllowedType.fade],
                      child: GlassContainer(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(categories[i].name, style: formHeaderText),
                              IconButton(
                                onPressed: () {
                                  openCategoryUpdateModal(i);
                                },
                                icon: Icon(Icons.edit, color: kwhite),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
              : Center(
                heightFactor: 100,
                child: Text(placeholderText, style: tableHeaderStyle),
              ),
        ],
      ),
    );
  }
}
