import 'package:uni_tech/partials/layout/side_menu_item.dart';
import 'package:uni_tech/providers/auth_provider.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SideMenu extends ConsumerStatefulWidget {
  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
  double currentNavWidth = 250;
  bool isCompact = false;
  bool isCompactByButton = false;
  bool isHovering = false;
  late List<Map<String, dynamic>> menuItems;
  late bool isAdmin;
  @override
  void initState() {
    super.initState();
    isAdmin = ref.read(authProvider.notifier).getAuth()!.role.name == "admin";
    menuItems =
        isAdmin
            ? [
              {"name": AppRoutes.dashboard, "icon": Icons.home, "active": true},
              {
                "name": AppRoutes.usersIndex,
                "icon": Icons.groups_3_sharp,
                "active": false,
              },
              {
                "name": AppRoutes.productsIndex,
                "icon": Icons.production_quantity_limits,
                "active": false,
              },
              {
                "name": AppRoutes.ordersIndex,
                "icon": Icons.insert_chart_outlined_rounded,
                "active": false,
              },
              {
                "name": AppRoutes.categoriesIndex,
                "icon": Icons.abc,
                "active": false,
              },
            ]
            : [
              {
                "name": AppRoutes.myProfile,
                "icon": Icons.person,
                "active": true,
              },
              {"name": AppRoutes.myOrders, "icon": Icons.home, "active": false},
              {
                "name": AppRoutes.productsIndex,
                "icon": Icons.home,
                "active": true,
              },
              {
                "name": AppRoutes.categoriesIndex,
                "icon": Icons.home,
                "active": true,
              },
            ];
  }

  void toggleCompactView(bool buttonPress) {
    if (!mounted) return;
    setState(() {
      if (buttonPress) {
        isCompactByButton = !isCompactByButton;
      }
      if (isHovering && isCompact) {
        currentNavWidth = 250;
      } else if (!isHovering && isCompact) {
        currentNavWidth = 250;
      } else if (!isHovering && isCompactByButton) {
        currentNavWidth = 70;
      } else if (!isHovering && !isCompactByButton) {
        currentNavWidth = 250;
      } else if (!isCompactByButton && buttonPress && !isCompact) {
        currentNavWidth = 250;
      } else {
        currentNavWidth = currentNavWidth == 250 ? 70 : 250;
      }
      if (currentNavWidth == 250) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          setState(() {
            isCompact = false;
          });
        });
      } else {
        isCompact = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (isCompact) {
          setState(() {
            isHovering = true;
          });
          toggleCompactView(false);
        }
      },
      onExit: (_) {
        if (!isCompactByButton || !isCompact) {
          Future.delayed(const Duration(milliseconds: 400), () {
            setState(() {
              isHovering = false;
            });
            toggleCompactView(false);
          });
        }
      },
      child: AnimatedContainer(
        margin: EdgeInsets.symmetric(vertical: 20),
        duration: const Duration(milliseconds: 400), // animation duration
        curve: Curves.easeInOut, // smooth transition
        width: currentNavWidth,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          gradient: sideMeanuGadient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment:
                      !isCompact
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        IconButton.filled(
                          onPressed: () {
                            toggleCompactView(true);
                          },
                          icon: const Icon(Icons.ac_unit),
                          style: iconButtonStyle,
                        ),
                        if (!isCompact) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Uni Tech",
                                style: GoogleFonts.michroma(
                                  color: kwhite,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                "Version 2.4",
                                style: TextStyle(
                                  color: kmutedtext,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    if (!isCompact) ...[
                      IconButton(
                        onPressed: () {
                          toggleCompactView(true);
                        },
                        icon: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.circle_outlined, size: 30),
                            if (!isCompactByButton)
                              (Icon(Icons.circle, size: 5)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: 20),
                ...menuItems.map((item) {
                  return SideMeanuItem(item: item, isCompact: isCompact);
                }), // remember to call toList() inside children
              ],
            ),
            Column(
              children: [
                if (isAdmin) ...{
                  SideMeanuItem(
                    item: {
                      "name": AppRoutes.myProfile,
                      "icon": Icons.person,
                      "active": false,
                    },
                    isCompact: isCompact,
                  ),
                },
                SideMeanuItem(
                  item: {
                    "name": AppRoutes.logout,
                    "icon": Icons.logout,
                    "active": false,
                  },
                  isCompact: isCompact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
