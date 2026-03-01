import 'package:uni_tech/partials/layout/footer.dart';
import 'package:uni_tech/partials/layout/top_navbar.dart';
import 'package:flutter/material.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({required this.content, super.key});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [TopNavbar(), SizedBox(height: 20), content, Footer()],
          ),
        ),
      ),
    );
  }
}
