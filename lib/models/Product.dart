import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uni_tech/models/Category.dart';

class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.image,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String image;
  final double price;
  final int stock;
  final String categoryId;
  final Timestamp createdAt;

  factory Product.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Category.values.forEach((e) => print([e.name, data['category']]));

    return Product(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      price: (data['price'] as num).toDouble(),
      stock: data['stock'] ?? 0,
      categoryId: data['categoryId'],
      image: data['image'] ?? 'https://picsum.photos/300/300',
      createdAt: data['created'] ?? Timestamp.now(),
    );
  }

  Future<Category?> getCategory() async {
    if (categoryId.isEmpty) return null;

    final doc = await db.collection("categories").doc(categoryId).get();
    if (!doc.exists) return null;

    return Category.fromDocument(doc);
  }

  /// Convert Product to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "price": price,
      "image": image,
      "categoryId": categoryId,
      "stock": stock,
      "created": createdAt,
    };
  }
}

/// Add product
Future<String> addProduct(
  String id,
  String name,
  String image,
  double price,
  String categoryId,
  int stock,
) async {
  final product = Product(
    id: id,
    name: name,
    price: price,
    stock: stock,
    categoryId: categoryId,
    image: image,
    createdAt: Timestamp.now(),
  );

  await db.collection("products").doc(product.id).set(product.toJson());

  return product.id;
}

/// Get all products once
Future<List<Product>> getCategoryProducts(String id) async {
  final db = FirebaseFirestore.instance;
  final snapshot =
      await db.collection("products").where("categoryId", isEqualTo: id).get();

  return snapshot.docs.map((doc) => Product.fromDocument(doc)).toList();
}

/// Get all products once
Future<List<Product>> getAllProducts() async {
  final db = FirebaseFirestore.instance;
  final snapshot = await db.collection("products").get();

  return snapshot.docs.map((doc) => Product.fromDocument(doc)).toList();
}

/// Get product by ID
Future<Product?> getProductById(String productId) async {
  final doc = await db.collection("products").doc(productId).get();
  if (doc.exists) {
    return Product.fromDocument(doc);
  }
  return null;
}

/// Update product
Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
  await db.collection("products").doc(productId).update(data);
  print("Product $productId updated!");
}

/// Delete product
Future<void> deleteProduct(String productId) async {
  await db.collection("products").doc(productId).delete();
  print("Product $productId deleted!");
}

/// Real-time stream of products
Stream<List<Product>> productsStream() {
  return db
      .collection("products")
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Product.fromDocument(doc)).toList(),
      );
}
