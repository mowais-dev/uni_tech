import 'package:uni_tech/partials/layout/layout.dart';
import 'package:uni_tech/screens/users/_partials/users_table.dart';
import 'package:flutter/material.dart';

class UsersIndexScreen extends StatefulWidget {
  UsersIndexScreen({super.key});

  @override
  State<UsersIndexScreen> createState() => _UsersIndexScreen();
}

class _UsersIndexScreen extends State<UsersIndexScreen> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      content: Column(
        mainAxisSize: MainAxisSize.max,
        children: [UsersTable(), SizedBox(height: 150)],
      ),
    );
  }
}
