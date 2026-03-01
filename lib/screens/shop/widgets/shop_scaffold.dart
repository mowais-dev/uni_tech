import 'package:uni_tech/models/User.dart';
import 'package:uni_tech/screens/shop/widgets/shop_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopScaffold extends StatelessWidget {
  const ShopScaffold({
    required this.child,
    required this.searchController,
    required this.onSearchChanged,
    required this.onLogoTap,
    required this.onLoginTap,
    required this.onSignupTap,
    required this.onCartTap,
    required this.cartCount,
    this.categoryBar,
    this.user,
    this.onProfile,
    this.onLogout,
    super.key,
  });

  final Widget child;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onLogoTap;
  final VoidCallback onLoginTap;
  final VoidCallback onSignupTap;
  final VoidCallback onCartTap;
  final int cartCount;
  final User? user;
  final Widget? categoryBar;
  final VoidCallback? onProfile;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShopColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopNav(
              searchController: searchController,
              onSearchChanged: onSearchChanged,
              onLogoTap: onLogoTap,
              onLoginTap: onLoginTap,
              onSignupTap: onSignupTap,
              onCartTap: onCartTap,
              cartCount: cartCount,
              user: user,
              onProfile: onProfile,
              onLogout: onLogout,
            ),
            if (categoryBar != null)
              Container(
                decoration: const BoxDecoration(color: ShopColors.surface),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: categoryBar,
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({
    required this.searchController,
    required this.onSearchChanged,
    required this.onLogoTap,
    required this.onLoginTap,
    required this.onSignupTap,
    required this.onCartTap,
    required this.cartCount,
    required this.user,
    this.onProfile,
    this.onLogout,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onLogoTap;
  final VoidCallback onLoginTap;
  final VoidCallback onSignupTap;
  final VoidCallback onCartTap;
  final int cartCount;
  final User? user;
  final VoidCallback? onProfile;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = user != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        color: ShopColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onLogoTap,
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: ShopColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_mall_outlined,
                    color: ShopColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Uni Shop',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ShopColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: ShopColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ShopColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, color: ShopColors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search for products',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: ShopColors.muted),
                      ),
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (!isLoggedIn) ...[
            OutlinedButton(
              onPressed: onSignupTap,
              style: ShopButtonStyles.ghost,
              child: const Text('Sign Up'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: onLoginTap,
              style: ShopButtonStyles.primary,
              child: const Text('Login'),
            ),
          ] else ...[
            _CartButton(cartCount: cartCount, onTap: onCartTap),
            const SizedBox(width: 12),
            _ProfileButton(
              user: user!,
              onProfile: onProfile,
              onLogout: onLogout,
            ),
          ],
        ],
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.cartCount, required this.onTap});

  final int cartCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ShopColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ShopColors.border),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: ShopColors.text,
            ),
          ),
        ),
        if (cartCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ShopColors.accent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: ShopShadows.soft,
              ),
              child: Text(
                cartCount.toString(),
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.user, this.onProfile, this.onLogout});

  final User user;
  final VoidCallback? onProfile;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 46),
      color: ShopColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 0,
              child: Text('Profile', style: ShopText.body()),
            ),
            PopupMenuItem(
              value: 1,
              child: Text('Logout', style: ShopText.body(Colors.redAccent)),
            ),
          ],
      onSelected: (value) {
        if (value == 0 && onProfile != null) onProfile!();
        if (value == 1 && onLogout != null) onLogout!();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ShopColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ShopColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: ShopColors.primary.withOpacity(0.15),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: ShopText.body(ShopColors.primary, FontWeight.w800),
              ),
            ),
            const SizedBox(width: 8),
            Text(user.name, style: ShopText.body()),
            const Icon(Icons.keyboard_arrow_down, color: ShopColors.text),
          ],
        ),
      ),
    );
  }
}
