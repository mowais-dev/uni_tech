import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uni_tech/models/Order.dart';
import 'package:uni_tech/models/User.dart';
import 'package:uuid/uuid.dart';

final db = FirebaseFirestore.instance;
final idGenerator = Uuid();

/// Keep track of generated IDs for relationships
final List<String> userIds = [];
final List<String> productIds = [];
final Map<String, String> categoryMap = {}; // categoryName -> categoryId

/// Seeder for Users
Future<void> seedUsers() async {
  final users = [
    {
      "name": "Muhammad Owais",
      "image": "https://placehold.co/150",
      "role": UserRole.admin.name,
      "password": "password",
      "email": "owais@gamil.com",
      "phone": "03001234567",
      "age": 21,
    },
    {
      "name": "Ali Raza",
      "image": "https://placehold.co/150",
      "role": UserRole.user.name,
      "password": "password",
      "email": "ali.raza@example.com",
      "phone": "03011234567",
      "age": 25,
    },
    // ... rest of users
  ];

  for (var user in users) {
    final userId = idGenerator.v4();
    userIds.add(userId);

    await db.collection("users").doc(userId).set({
      "id": userId,
      ...user,
      "created": FieldValue.serverTimestamp(),
    });
  }
  print("✅ Users seeded!");
}

/// Seeder for Categories
Future<void> seedCategories() async {
  final categories = [
    "Electronics",
    "Clothing",
    "Books",
    "Home & Kitchen",
    "Sports & Fitness",
    "Beauty & Health",
    "Toys & Games",
    "Footwear",
    "Groceries",
    "Accessories",
  ];

  for (var category in categories) {
    final categoryId = idGenerator.v4();
    categoryMap[category] = categoryId;

    await db.collection("categories").doc(categoryId).set({
      "id": categoryId,
      "name": category,
      "created": FieldValue.serverTimestamp(),
    });
  }
  print("✅ Categories seeded!");
}

/// Seeder for Products
Future<void> seedProducts() async {
  final products = [
    {
      "name": "iPhone 15 Pro",
      "price": 1200,
      "stock": 15,
      "category": "Electronics",
    },
    {"name": "Nike Air Max", "price": 180, "stock": 30, "category": "Footwear"},
    {"name": "The Lean Startup", "price": 25, "stock": 50, "category": "Books"},
    {
      "name": "Non-stick Frying Pan",
      "price": 40,
      "stock": 20,
      "category": "Home & Kitchen",
    },
    {
      "name": "Football",
      "price": 35,
      "stock": 40,
      "category": "Sports & Fitness",
    },
    {
      "name": "Lipstick Set",
      "price": 15,
      "stock": 60,
      "category": "Beauty & Health",
    },
    {
      "name": "Lego Classic Box",
      "price": 60,
      "stock": 25,
      "category": "Toys & Games",
    },
    {
      "name": "Adidas T-Shirt",
      "price": 30,
      "stock": 35,
      "category": "Clothing",
    },
    {
      "name": "Organic Rice (5kg)",
      "price": 12,
      "stock": 100,
      "category": "Groceries",
    },
    {
      "name": "Leather Wallet",
      "price": 45,
      "stock": 22,
      "category": "Accessories",
    },
  ];

  var i = 1;
  for (var product in products) {
    final productId = idGenerator.v4();
    productIds.add(productId);

    final categoryId = categoryMap[product["category"]] ?? "";

    await db.collection("products").doc(productId).set({
      "id": productId,
      "image": "https://picsum.photos/300/300?random=$i",
      "categoryId": categoryId, // use id instead of name
      "name": product["name"],
      "price": product["price"],
      "stock": product["stock"],
      "created": FieldValue.serverTimestamp(),
    });
    i++;
  }
  print("✅ Products seeded!");
}

/// Seeder for Orders
Future<void> seedOrders() async {
  final orders = [
    {"quantity": 1, "status": OrderStatus.completed.name},
    {"quantity": 2, "status": OrderStatus.cancelled.name},
    {"quantity": 1, "status": OrderStatus.inProgress.name},
    {"quantity": 3, "status": OrderStatus.completed.name},
    {"quantity": 2, "status": OrderStatus.cancelled.name},
    {"quantity": 1, "status": OrderStatus.completed.name},
    {"quantity": 5, "status": OrderStatus.completed.name},
    {"quantity": 1, "status": OrderStatus.completed.name},
    {"quantity": 4, "status": OrderStatus.inProgress.name},
    {"quantity": 2, "status": OrderStatus.cancelled.name},
  ];

  for (var i = 0; i < orders.length; i++) {
    final orderId = idGenerator.v4();
    final userId = userIds[i % userIds.length];
    final productId = productIds[i % productIds.length];

    await db.collection("orders").doc(orderId).set({
      "id": orderId,
      "userId": userId,
      "productId": productId,
      ...orders[i],
      "created": FieldValue.serverTimestamp(),
    });
  }
  print("✅ Orders seeded!");
}

/// Run all seeders
Future<void> runSeeders() async {
  await seedUsers();
  await seedCategories();
  await seedProducts();
  await seedOrders();
  print("🌱 All seed data inserted!");
}
