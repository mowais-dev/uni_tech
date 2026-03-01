import 'package:uni_tech/models/Category.dart';
import 'package:uni_tech/models/Product.dart';
import 'package:uni_tech/providers/auth_provider.dart';
import 'package:uni_tech/providers/cart_provider.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/screens/shop/widgets/shop_scaffold.dart';
import 'package:uni_tech/screens/shop/widgets/shop_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ShopHomeScreen extends ConsumerStatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  ConsumerState<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends ConsumerState<ShopHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String _selectedCategory = 'all';
  List<Category> _categories = [];
  bool _categoriesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await getAllCategories();
    if (!mounted) return;
    setState(() {
      _categories = cats;
      _categoriesLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleAddToCart(Product product) {
    final user = ref.read(authProvider.notifier).getAuth();

    if (user == null) {
      ref.read(navigationProvider.notifier).setScreen(AppRoutes.signup);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign up or login to add items.')),
      );
      return;
    }

    ref.read(cartProvider.notifier).addItem(product);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added to cart')));
  }

  int _gridColumns(double width) {
    if (width >= 1100) return 4;
    if (width >= 720) return 2;
    return 1;
  }

  Widget _categoryBar() {
    if (_categoriesLoading) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final chips = <Widget>[
      ChoiceChip(
        label: const Text('All'),
        selected: _selectedCategory == 'all',
        onSelected: (_) => setState(() => _selectedCategory = 'all'),
        backgroundColor: Colors.transparent,
        selectedColor: ShopColors.primary.withOpacity(0.12),
        labelStyle: ShopText.body(
          _selectedCategory == 'all' ? ShopColors.primary : ShopColors.text,
          FontWeight.w700,
        ),
        shape: StadiumBorder(
          side: BorderSide(color: ShopColors.border.withOpacity(0.8)),
        ),
      ),
      ..._categories.map(
        (cat) => ChoiceChip(
          label: Text(cat.name),
          selected: _selectedCategory == cat.id,
          onSelected: (_) => setState(() => _selectedCategory = cat.id),
          backgroundColor: Colors.transparent,
          selectedColor: ShopColors.primary.withOpacity(0.12),
          labelStyle: ShopText.body(
            _selectedCategory == cat.id ? ShopColors.primary : ShopColors.text,
            FontWeight.w700,
          ),
          shape: StadiumBorder(
            side: BorderSide(color: ShopColors.border.withOpacity(0.8)),
          ),
        ),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...chips.expand((chip) => [chip, const SizedBox(width: 8)]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final cartItems = ref.watch(cartProvider);
    final cartCount = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return ShopScaffold(
      searchController: _searchController,
      onSearchChanged:
          (value) => setState(() => _searchTerm = value.toLowerCase()),
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
      cartCount: cartCount,
      user: authState.user,
      categoryBar: _categoryBar(),
      onProfile:
          () => ref
              .read(navigationProvider.notifier)
              .setScreen(AppRoutes.myProfile),
      onLogout: () => ref.read(authProvider.notifier).clearAuth(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Discover products', style: ShopText.heading),
                  const SizedBox(height: 4),
                  Text(
                    'Curated picks for your everyday needs',
                    style: ShopText.body(ShopColors.muted),
                  ),
                ],
              ),
              Text(
                '${cartCount.toString()} items in cart',
                style: ShopText.body(ShopColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 18),
          StreamBuilder<List<Product>>(
            stream: productsStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final products =
                  snapshot.data!
                      .where(
                        (p) =>
                            (_selectedCategory == 'all' ||
                                p.categoryId == _selectedCategory) &&
                            (p.name.toLowerCase().contains(_searchTerm)),
                      )
                      .toList();

              if (products.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: ShopColors.muted,
                        ),
                        const SizedBox(height: 10),
                        Text('No products found', style: ShopText.body()),
                        Text(
                          'Try adjusting filters or search keywords',
                          style: ShopText.caption(),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = _gridColumns(constraints.maxWidth);

                  return GridView.builder(
                    itemCount: products.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: crossAxisCount == 1 ? 1.05 : 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _ProductCard(
                        product: product,
                        onAddToCart: () => _handleAddToCart(product),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.product, required this.onAddToCart});

  final Product product;
  final VoidCallback onAddToCart;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;
  final formatter = NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final oldPrice = widget.product.price * 1.12;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ShopColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _hovered ? ShopShadows.soft : null,
          border: Border.all(
            color:
                _hovered
                    ? ShopColors.primary.withOpacity(0.2)
                    : ShopColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AnimatedScale(
                  scale: _hovered ? 1.02 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    color: ShopColors.background,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 4 / 5,
                        child: Image.network(
                          widget.product.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ShopText.body(ShopColors.text, FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  formatter.format(widget.product.price),
                  style: ShopText.body(ShopColors.primary, FontWeight.w800),
                ),
                const SizedBox(width: 8),
                Text(
                  formatter.format(oldPrice),
                  style: ShopText.caption(
                    ShopColors.muted,
                  ).copyWith(decoration: TextDecoration.lineThrough),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.star, size: 16, color: Colors.amber),
                Icon(Icons.star, size: 16, color: Colors.amber),
                Icon(Icons.star, size: 16, color: Colors.amber),
                Icon(Icons.star_half, size: 16, color: Colors.amber),
                Icon(Icons.star_border, size: 16, color: Colors.amber),
                SizedBox(width: 6),
                Text(
                  '4.5',
                  style: TextStyle(
                    color: ShopColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onAddToCart,
                icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
                label: const Text('Add to Cart'),
                style: ShopButtonStyles.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
