import 'dart:ui';
import 'package:uni_tech/partials/layout/main_container.dart';
import 'package:uni_tech/partials/layout/side_menu.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Layout extends ConsumerWidget {
  const Layout({required this.content, super.key});

  final Widget content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/background.png"), // <-- from assets
            fit: BoxFit.cover, // makes it cover the container
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child:
              ref.watch(navigationProvider).loading
                  ? Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                  : Container(
                    padding: EdgeInsets.only(left: 20),
                    height: double.infinity,
                    color: kwhite.withOpacity(0.1),
                    child: Row(
                      children: [SideMenu(), MainContainer(content: content)],
                    ),
                  ),
        ),
      ),
    );
  }
}
