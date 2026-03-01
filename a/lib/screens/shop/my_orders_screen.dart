import 'package:uni_tech/models/Order.dart';
import 'package:uni_tech/models/Product.dart';
import 'package:uni_tech/providers/auth_provider.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/screens/shop/widgets/shop_scaffold.dart';
import 'package:uni_tech/screens/shop/widgets/shop_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _currency = NumberFormat.simpleCurrency();

  List<Order> _orders = [];
  // productId -> Product (cached)
  final Map<String, Product?> _productCache = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = ref.read(authProvider.notifier).getAuth();
      if (user == null) {
        if (mounted)
          setState(() {
            _orders = [];
            _loading = false;
          });
        return;
      }
      final orders = await getOrdersByUserId(user.id);

      // Pre-fetch unique products
      final uniqueIds = orders.map((o) => o.productId).toSet();
      for (final id in uniqueIds) {
        if (!_productCache.containsKey(id)) {
          _productCache[id] = await getProductById(id);
        }
      }

      if (mounted)
        setState(() {
          _orders = orders;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return '—';
    try {
      return DateFormat('dd MMM yyyy, HH:mm').format(ts.toDate());
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return ShopScaffold(
      searchController: _searchController,
      onSearchChanged: (_) {},
      onLogoTap:
          () => ref
              .read(navigationProvider.notifier)
              .setScreen(AppRoutes.shopHome),
      onLoginTap:
          () =>
              ref.read(navigationProvider.notifier).setScreen(AppRoutes.login),
      onSignupTap:
          () =>
              ref.read(navigationProvider.notifier).setScreen(AppRoutes.signup),
      onCartTap:
          () => ref
              .read(navigationProvider.notifier)
              .setScreen(AppRoutes.shopCart),
      cartCount: 0,
      user: user,
      onProfile:
          () => ref
              .read(navigationProvider.notifier)
              .setScreen(AppRoutes.myProfile),
      onLogout: () => ref.read(authProvider.notifier).clearAuth(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Orders', style: ShopText.heading),
                  const SizedBox(height: 4),
                  Text(
                    'Track your purchases and order history.',
                    style: ShopText.caption(),
                  ),
                ],
              ),
              if (!_loading && _orders.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ShopColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ShopColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${_orders.length} order${_orders.length == 1 ? '' : 's'}',
                    style: ShopText.caption(ShopColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Body ─────────────────────────────────────────────────────────
          if (_loading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60),
              decoration: BoxDecoration(
                color: ShopColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ShopColors.border),
              ),
              child: const Column(
                children: [
                  CircularProgressIndicator(color: ShopColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Loading orders…',
                    style: TextStyle(color: ShopColors.muted),
                  ),
                ],
              ),
            )
          else if (_error != null)
            _errorState()
          else if (_orders.isEmpty)
            _emptyState()
          else
            _orderList(),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: ShopColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ShopColors.border),
        boxShadow: ShopShadows.soft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: ShopColors.muted,
          ),
          const SizedBox(height: 12),
          Text('No orders yet', style: ShopText.body()),
          const SizedBox(height: 6),
          Text(
            'Browse products and place your first order.',
            style: ShopText.caption(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                () => ref
                    .read(navigationProvider.notifier)
                    .setScreen(AppRoutes.shopHome),
            style: ShopButtonStyles.primary,
            child: const Text('Start shopping'),
          ),
        ],
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────
  Widget _errorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: ShopColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text('Failed to load orders', style: ShopText.body()),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── Order list ─────────────────────────────────────────────────────────────
  Widget _orderList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _orderCard(_orders[index], index),
    );
  }

  Widget _orderCard(Order order, int index) {
    final product = _productCache[order.productId];
    final productName = product?.name ?? 'Product';
    final productImage = product?.image ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShopColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ShopColors.border),
        boxShadow: ShopShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image / icon
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child:
                productImage.isNotEmpty
                    ? Image.network(
                      productImage,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _productIconBox(),
                    )
                    : _productIconBox(),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        productName,
                        style: ShopText.body(ShopColors.text, FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _currency.format(order.total),
                      style: ShopText.body(ShopColors.primary, FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Qty: ${order.quantity}  ·  ${_formatDate(order.createdAt)}',
                  style: ShopText.caption(),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: ShopColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        order.address,
                        style: ShopText.caption(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Status chip
                _statusChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productIconBox() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: ShopColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.local_shipping_outlined,
        color: ShopColors.primary,
      ),
    );
  }

  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.4)),
      ),
      child: Text(
        'In Progress',
        style: TextStyle(
          color: Colors.green[700],
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
