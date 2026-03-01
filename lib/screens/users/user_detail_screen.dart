import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:uni_tech/models/Order.dart';
import 'package:uni_tech/models/User.dart';
import 'package:uni_tech/partials/glass_container.dart';
import 'package:uni_tech/partials/layout/layout.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:uni_tech/utilities/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  final User user;
  const UserDetailScreen({required this.user, super.key});

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
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

  // ─── Delete ───────────────────────────────────────────────────────────────
  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            alignment: Alignment.center,
            backgroundColor: const Color.fromARGB(255, 22, 22, 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Delete User', style: whiteText),
            content: const Text(
              'Are you sure you want to permanently delete this user?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete', style: whiteText),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await deleteUser(widget.user.id);
      if (mounted) {
        showCustomAlert(
          context,
          'User deleted successfully!',
          backgroundColor: ksuccess,
        );
        ref.read(navigationProvider.notifier).setScreen(AppRoutes.usersIndex);
      }
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _formatDate(Timestamp? ts) {
    if (ts == null) return '—';
    return DateFormat('dd MMM yyyy, HH:mm').format(ts.toDate());
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.michroma(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.lato(
                color: valueColor ?? kwhite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.white12, height: 1);

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final isAdmin = user.role == UserRole.admin;

    return Layout(
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Page header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('User Details', style: formHeaderText),
                    Row(
                      children: [
                        CustomButton(
                          label: 'Edit User',
                          size: 'medium',
                          backgroundColor: Colors.blue,
                          foregroundColor: kwhite,
                          onClick:
                              () => ref
                                  .read(navigationProvider.notifier)
                                  .setScreen(AppRoutes.usersEdit, user.id),
                        ),
                        const SizedBox(width: 12),
                        CustomButton(
                          label: 'Delete User',
                          size: 'medium',
                          backgroundColor: Colors.redAccent,
                          foregroundColor: kwhite,
                          onClick: _deleteUser,
                        ),
                        const SizedBox(width: 12),
                        CustomButton(
                          label: '← Back to Users',
                          size: 'medium',
                          backgroundColor: const Color.fromARGB(
                            255,
                            50,
                            50,
                            50,
                          ),
                          foregroundColor: kwhite,
                          onClick:
                              () => ref
                                  .read(navigationProvider.notifier)
                                  .setScreen(AppRoutes.usersIndex),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Main body ────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left card: avatar + basic info ──────────────────────
                  Expanded(
                    flex: 35,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isAdmin
                                        ? Colors.amberAccent
                                        : Colors.blueAccent,
                                width: 3,
                              ),
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
                                    ? const Icon(
                                      Icons.person,
                                      size: 55,
                                      color: Colors.white54,
                                    )
                                    : null,
                          ),
                          const SizedBox(height: 16),

                          // Name
                          Text(
                            user.name,
                            style: GoogleFonts.michroma(
                              color: kwhite,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Role badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isAdmin
                                      ? Colors.amber.withOpacity(0.2)
                                      : Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isAdmin
                                        ? Colors.amberAccent
                                        : Colors.blueAccent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              user.role.name.toUpperCase(),
                              style: GoogleFonts.michroma(
                                color:
                                    isAdmin
                                        ? Colors.amberAccent
                                        : Colors.blueAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _divider(),
                          const SizedBox(height: 16),

                          // Contact info
                          _infoRow('Email', user.email),
                          _divider(),
                          _infoRow(
                            'Phone',
                            user.phone.isNotEmpty ? user.phone : '—',
                          ),
                          _divider(),
                          _infoRow('Age', '${user.age} yrs'),
                          _divider(),
                          _infoRow('Joined', _formatDate(user.createdAt)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // ── Right card: extra details  ───────────────────────────
                  Expanded(
                    flex: 65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Account details card
                        GlassContainer(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Account Details', style: formHeaderText),
                              const SizedBox(height: 16),

                              _infoRow('User ID', user.id),
                              _divider(),
                              _infoRow('Full Name', user.name),
                              _divider(),
                              _infoRow('Email Address', user.email),
                              _divider(),
                              _infoRow(
                                'Phone Number',
                                user.phone.isNotEmpty
                                    ? user.phone
                                    : 'Not provided',
                              ),
                              _divider(),
                              _infoRow('Age', '${user.age} years old'),
                              _divider(),
                              _infoRow(
                                'Role',
                                user.role.name.toUpperCase(),
                                valueColor:
                                    isAdmin
                                        ? Colors.amberAccent
                                        : Colors.blueAccent,
                              ),
                              _divider(),
                              _infoRow(
                                'Member Since',
                                _formatDate(user.createdAt),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Security card (masked password)
                        GlassContainer(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Security', style: formHeaderText),
                              const SizedBox(height: 16),
                              _infoRow(
                                'Password',
                                user.password.isNotEmpty
                                    ? '•' * user.password.length.clamp(8, 16)
                                    : '—',
                                valueColor: Colors.grey,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Orders card
                        GlassContainer(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Orders', style: formHeaderText),
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
                                          size: 48,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No orders found for this user.',
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
            ],
          ),
        ),
      ),
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
