import 'package:uni_tech/providers/auth_provider.dart';
import 'package:uni_tech/providers/cart_provider.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/screens/shop/widgets/shop_scaffold.dart';
import 'package:uni_tech/screens/shop/widgets/shop_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ShopCartScreen extends ConsumerStatefulWidget {
  ShopCartScreen({super.key});

  @override
  ConsumerState<ShopCartScreen> createState() => _ShopCartScreenState();
}

class _ShopCartScreenState extends ConsumerState<ShopCartScreen> {
  final _currency = NumberFormat.simpleCurrency();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final cartCount = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final total = cartNotifier.totalAmount;

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
      onCartTap: () {},
      cartCount: cartCount,
      user: authState.user,
      onProfile:
          () => ref
              .read(navigationProvider.notifier)
              .setScreen(AppRoutes.myProfile),
      onLogout: () => ref.read(authProvider.notifier).clearAuth(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Cart', style: ShopText.heading),
          const SizedBox(height: 12),
          if (cartItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 80),
              decoration: BoxDecoration(
                color: ShopColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: ShopColors.border),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 48,
                    color: ShopColors.muted,
                  ),
                  const SizedBox(height: 12),
                  Text('Your cart is empty', style: ShopText.body()),
                  const SizedBox(height: 8),
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
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 960;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: ShopColors.border),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartItems.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      item.product.image,
                                      height: 88,
                                      width: 88,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: ShopText.body(
                                            ShopColors.text,
                                            FontWeight.w700,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _currency.format(item.product.price),
                                          style: ShopText.body(
                                            ShopColors.primary,
                                            FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            _QtyButton(
                                              icon: Icons.remove,
                                              onPressed:
                                                  () => cartNotifier
                                                      .updateQuantity(
                                                        item.product.id,
                                                        -1,
                                                      ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              child: Text(
                                                item.quantity.toString(),
                                                style: ShopText.body(),
                                              ),
                                            ),
                                            _QtyButton(
                                              icon: Icons.add,
                                              onPressed:
                                                  () => cartNotifier
                                                      .updateQuantity(
                                                        item.product.id,
                                                        1,
                                                      ),
                                            ),
                                            const SizedBox(width: 14),
                                            Text(
                                              'Subtotal: ${_currency.format(item.subtotal)}',
                                              style: ShopText.caption(
                                                ShopColors.muted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: ShopColors.muted,
                                    ),
                                    onPressed:
                                        () => cartNotifier.removeItem(
                                          item.product.id,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: isWide ? 18 : 0, height: isWide ? 0 : 18),
                    Flexible(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ShopColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ShopColors.border),
                            boxShadow: ShopShadows.soft,
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Summary',
                                style: ShopText.body(
                                  ShopColors.text,
                                  FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _summaryRow(
                                'Items (${cartCount.toString()})',
                                _currency.format(total),
                              ),
                              _summaryRow('Shipping', 'Free'),
                              const Divider(height: 24),
                              _summaryRow(
                                'Grand Total',
                                _currency.format(total),
                                emphasize: true,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  final user =
                                      ref.read(authProvider.notifier).getAuth();
                                  if (user == null) {
                                    ref
                                        .read(navigationProvider.notifier)
                                        .setScreen(AppRoutes.signup);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please sign up to checkout.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  ref
                                      .read(navigationProvider.notifier)
                                      .setScreen(AppRoutes.shopCheckout);
                                },
                                style: ShopButtonStyles.primary,
                                child: const Text('Checkout'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                emphasize
                    ? ShopText.body(ShopColors.text, FontWeight.w800)
                    : ShopText.body(),
          ),
          Text(
            value,
            style:
                emphasize
                    ? ShopText.body(ShopColors.text, FontWeight.w800)
                    : ShopText.body(),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: ShopColors.border),
        ),
        child: Icon(icon, size: 16, color: ShopColors.text),
      ),
    );
  }
}
