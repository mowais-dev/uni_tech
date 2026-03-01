import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:uni_tech/models/Order.dart';
import 'package:uni_tech/models/User.dart';
import 'package:uni_tech/partials/glass_container.dart';
import 'package:uni_tech/partials/layout/layout.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({required this.user, super.key});

  final User user;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  List<Order> _orders = [];
  bool _loadingOrders = true;
  final _currency = NumberFormat.simpleCurrency();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await getOrdersByUserId(widget.user.id);
    if (mounted)
      setState(() {
        _orders = orders;
        _loadingOrders = false;
      });
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '—';
    return DateFormat('dd MMM yyyy, HH:mm').format(ts.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Layout(
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 150),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left panel ───────────────────────────────────────────────
              Expanded(
                flex: 35,
                child: GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                            image:
                                user.image.isNotEmpty
                                    ? DecorationImage(
                                      image: NetworkImage(user.image),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              user.image.isEmpty
                                  ? const Icon(Icons.person, size: 50)
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _row("Name:", user.name),
                      const SizedBox(height: 12),
                      _row("Email:", user.email),
                      const SizedBox(height: 12),
                      _row("Phone:", user.phone.isNotEmpty ? user.phone : '—'),
                      const SizedBox(height: 12),
                      _row("Role:", user.role.name.toUpperCase()),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // ── Right panel ──────────────────────────────────────────────
              Expanded(
                flex: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomButton(
                      label: "Edit Profile Data",
                      onClick:
                          () => ref
                              .read(navigationProvider.notifier)
                              .setScreen(AppRoutes.usersEdit, user.id),
                    ),
                    const SizedBox(height: 20),
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("My Orders", style: formHeaderText),
                              if (!_loadingOrders)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_orders.length} order${_orders.length == 1 ? '' : 's'}',
                                    style: GoogleFonts.michroma(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_loadingOrders)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: CircularProgressIndicator(
                                  color: Colors.white54,
                                ),
                              ),
                            )
                          else if (_orders.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.receipt_long_outlined,
                                      color: Colors.white24,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "You have not placed any orders yet.",
                                      style: formSubHeaderText,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ..._orders.map((order) => _orderRow(order)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(style: whiteText, label), Text(style: whiteText, value)],
    );
  }

  Widget _orderRow(Order order) {
    return Column(
      children: [
        const Divider(color: Colors.white12, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_outlined,
                color: Colors.white38,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product: ${order.productId}',
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Address: ${order.address}',
                      style: GoogleFonts.lato(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(order.createdAt),
                      style: GoogleFonts.lato(
                        color: Colors.white30,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _currency.format(order.total),
                    style: GoogleFonts.michroma(
                      color: kwhite,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${order.quantity}',
                    style: GoogleFonts.lato(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
