import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

enum OrderStatus { inProgress, completed, cancelled }

class Order {
  Order({
    this.docId = '',
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.total,
    required this.address,
    this.createdAt,
  });

  final String docId;
  final String userId;
  final String productId;
  final int quantity;
  final int total;
  final String address;
  final Timestamp? createdAt;

  factory Order.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      docId: doc.id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      total: (data['total'] as num?)?.toInt() ?? 0,
      address: data['address'] ?? '',
      createdAt: data['created'] as Timestamp?,
    );
  }
}

/// Get all orders for a specific user
Future<List<Order>> getOrdersByUserId(String userId) async {
  final snapshot =
      await db.collection("orders").where("userId", isEqualTo: userId).get();
  final orders = snapshot.docs.map((doc) => Order.fromDocument(doc)).toList();
  // Sort by createdAt descending in Dart (avoids requiring a composite index)
  orders.sort((a, b) {
    if (a.createdAt == null && b.createdAt == null) return 0;
    if (a.createdAt == null) return 1;
    if (b.createdAt == null) return -1;
    return b.createdAt!.compareTo(a.createdAt!);
  });
  return orders;
}

/// Add order
Future<void> addOrder(
  String userId,
  String productId,
  int quantity,
  int total,
  String address,
) async {
  await db.collection("orders").add({
    "userId": userId,
    "productId": productId,
    "quantity": quantity,
    "total": total,
    "address": address,
    "status": OrderStatus.inProgress.name,
    "created": FieldValue.serverTimestamp(),
  });
}

/// Get all orders
Future<void> getAllOrders() async {
  final snapshot = await db.collection("orders").get();
  for (var doc in snapshot.docs) {
    print("${doc.id} => ${doc.data()}");
  }
}

/// Get order by ID
Future<void> getOrderById(String orderId) async {
  final doc = await db.collection("orders").doc(orderId).get();
  if (doc.exists) {
    print("Order ${doc.id} => ${doc.data()}");
  } else {
    print("No order found with ID $orderId");
  }
}

/// Update order
Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
  await db.collection("orders").doc(orderId).update(data);
  print("Order $orderId updated!");
}

/// Delete order
Future<void> deleteOrder(String orderId) async {
  await db.collection("orders").doc(orderId).delete();
  print("Order $orderId deleted!");
}

/// Real-time stream of orders
Stream<QuerySnapshot> ordersStream() {
  return db.collection("orders").snapshots();
}
