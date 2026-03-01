import 'package:uni_tech/providers/auth_provider.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class TopNavbar extends ConsumerWidget {
  const TopNavbar({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(navigationProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            currentScreen.title,
            style: GoogleFonts.michroma(
              color: kwhite,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0, // spacing between letters
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.search, color: kwhite, size: 30),
              SizedBox(width: 25),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  ref.read(authProvider.notifier).getAuth()!.image,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
