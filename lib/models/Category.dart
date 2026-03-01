import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

final db = FirebaseFirestore.instance;

class Category {
  Category({required this.id, required this.name, required this.createdAt});

  final String id;
  String name;
  final Timestamp createdAt;

  /// Factory to build Category from Firestore document
  factory Category.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      createdAt: data['created'] ?? Timestamp.now(),
    );
  }

  set setName(String n) {
    name = n;
  }

  /// Convert Category to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {"name": name, "created": createdAt};
  }
}

Future<Map<String, Category>> getCategoriesAsMap() async {
  final snapshot = await db.collection("categories").get();
  return {for (var doc in snapshot.docs) doc.id: Category.fromDocument(doc)};
}

/// Add category
Future<void> addCategory(String name) async {
  final category = Category(
    id: const Uuid().v4(),
    name: name,
    createdAt: Timestamp.now(),
  );

  await db.collection("categories").doc(category.id).set(category.toJson());
}

/// Get all categories
Future<List<Category>> getAllCategories() async {
  final db = FirebaseFirestore.instance;
  final snapshot = await db.collection("categories").get();

  return snapshot.docs.map((doc) => Category.fromDocument(doc)).toList();
}

/// Get category by ID
Future<Category?> getCategoryById(String categoryId) async {
  final doc = await db.collection("categories").doc(categoryId).get();
  if (doc.exists) {
    return Category.fromDocument(doc);
  }
  return null;
}

/// Update category
Future<void> updateCategory(
  String categoryId,
  Map<String, dynamic> data,
) async {
  await db.collection("categories").doc(categoryId).update(data);
  print("Category $categoryId updated!");
}

/// Delete category
Future<void> deleteCategory(String categoryId) async {
  await db.collection("categories").doc(categoryId).delete();
  final query =
      await db
          .collection("products")
          .where("categoryId", isEqualTo: categoryId)
          .get();

  for (var doc in query.docs) {
    await doc.reference.delete();
  }
  print("Category $categoryId deleted!");
}

/// Real-time stream of categories
Stream<List<Category>> categoriesStream() {
  return db
      .collection("categories")
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Category.fromDocument(doc)).toList(),
      );
}
