import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:math';

final db = FirebaseFirestore.instance;
final uuid = Uuid();

enum UserRole { admin, user }

class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.phone,
    required this.role,
    required this.password,
    required this.age,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String image;
  final String phone;
  final UserRole role;
  final String password;
  final int age;
  final Timestamp createdAt;

  /// Convert Firestore document to User object
  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return User(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      image: data['image'] ?? '',
      phone: data['phone'] ?? '',
      password: data['password'] ?? '',
      age: int.tryParse(data['age'].toString()) ?? 0,
      role:
          (data['role'] ?? 'user') == 'admin' ? UserRole.admin : UserRole.user,
      createdAt: data['created'] ?? Timestamp.now(),
    );
  }

  /// Convert User object to JSON for Firestore
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "image": image,
    "phone": phone,
    "role": role.name, // save as string
    "password": password,
    "age": age,
    "created": FieldValue.serverTimestamp(), // use FieldValue only when writing
  };
}

/// Example: add user
Future<void> addUser(
  String name,
  String email,
  String image,
  int age,
  String password,
  String phone,
  UserRole role,
) async {
  final userId = uuid.v4();

  final user = User(
    id: userId,
    name: name,
    email: email,
    image: image,
    phone: phone,
    role: role,
    password: password,
    age: age,
    createdAt: Timestamp.now(),
  );

  await db.collection("users").doc(userId).set(user.toJson());
  print("✅ User added with ID: $userId");
}

/// Encrypt token "UUID password"
String encryptToken(String token) {
  final parts = token.split(" ");
  if (parts.length != 2) return token;

  String id = parts[0];
  String password = parts[1];

  List<String> chunks = id.split("-");

  // Generate random salt
  String salt = Random().nextInt(999999).toString();

  // Pick a random index to insert password
  int insertIndex = Random().nextInt(chunks.length + 1);

  // Build structure
  Map<String, dynamic> data = {
    "chunks": chunks,
    "password": password,
    "index": insertIndex,
    "salt": salt,
  };

  // Encode as base64
  return base64Url.encode(utf8.encode(jsonEncode(data)));
}

/// Decrypt encrypted token
String decryptToken(String encrypted) {
  String decoded = utf8.decode(base64Url.decode(encrypted));
  final data = jsonDecode(decoded);

  List<String> chunks = List<String>.from(data["chunks"]);
  String password = data["password"];

  String id = chunks.join("-");

  return [id, password].join(" ");
}

Future<User?> authencateUser(String? accessToken) async {
  String password = accessToken!.split(" ")[1];
  String id = accessToken.split(" ")[0];

  final doc = await db.collection("users").doc(id).get();
  if (doc.exists) {
    User user = User.fromDocument(doc);
    print("in authencation ${user.name}");
    if (user.password == password) {
      return user;
    }
  }
  return null;
}

/// Get user by email
Future<User?> getUserByEmail(String email) async {
  final query =
      await db
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

  if (query.docs.isNotEmpty) {
    return User.fromDocument(query.docs.first);
  } else {
    return null;
  }
}

/// Get all users
Future<List<User>> getAllUsers() async {
  final db = FirebaseFirestore.instance;
  final snapshot = await db.collection("users").get();

  return snapshot.docs.map((doc) => User.fromDocument(doc)).toList();
}

/// Get user by ID
Future<User?> getUserById(String userId) async {
  final doc = await db.collection("users").doc(userId).get();
  if (doc.exists) {
    return User.fromDocument(doc);
  }
  return null;
}

/// Update user
Future<void> updateUser(String userId, Map<String, dynamic> data) async {
  await db.collection("users").doc(userId).update(data);
  print("✅ User $userId updated!");
}

/// Delete user
Future<void> deleteUser(String userId) async {
  await db.collection("users").doc(userId).delete();
  print("❌ User $userId deleted!");
}

/// Real-time stream of all users
Stream<QuerySnapshot> usersStream() {
  return db.collection("users").snapshots();
}
