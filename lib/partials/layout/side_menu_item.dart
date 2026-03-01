import 'package:uni_tech/styles/texts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SideMeanuItem extends ConsumerWidget {
  const SideMeanuItem({required this.item, required this.isCompact, super.key});

  final Map<String, dynamic> item;
  final bool isCompact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(navigationProvider);
    final isActive = currentScreen.screen == item["name"];
    return Material(
      color: Colors.transparent,
      child: ListTile(
        selected: isActive,
        selectedTileColor: const Color.fromARGB(255, 49, 49, 49),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(item["icon"], color: kwhite),
        hoverColor: kwhite.withAlpha(20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: Text(
          isCompact ? "" : titles[item["name"]]!["title"]!,
          style: GoogleFonts.michroma(
            color: kwhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          ref.read(navigationProvider.notifier).setScreen(item["name"]);
        },
      ),
    );
  }
}
