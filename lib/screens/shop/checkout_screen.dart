import 'package:uni_tech/models/Order.dart';
import 'package:uni_tech/providers/auth_provider.dart';
import 'package:uni_tech/providers/cart_provider.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/screens/shop/widgets/shop_scaffold.dart';
import 'package:uni_tech/screens/shop/widgets/shop_theme.dart';
import 'package:uni_tech/services/stripe_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _navSearchController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: '');
  final _postalController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  String _shipping = 'standard';
  String _payment = 'card';
  bool _submitting = false;
  bool _cardComplete = false;
  String? _stripeStatus; // shows step feedback during payment
  final _currency = NumberFormat.simpleCurrency();

  @override
  void initState() {
    super.initState();
    // Initialise Stripe.js lazily – only when checkout screen is opened.
    // Wrapping in try/catch so a Stripe failure doesn't crash the whole screen.
    try {
      StripeService.initStripe();
    } catch (e) {
      debugPrint('Stripe init warning: $e');
    }
    // add dummy data for testing
    _nameController.text = 'John Doe';
    _emailController.text = 'john.doe@example.com';
    _phoneController.text = '555-123-4567';
    _addressController.text = '123 Main St';
    _cityController.text = 'Anytown';
    _countryController.text = 'USA';
    _postalController.text = '12345';
    _cardNumberController.text = '4242 4242 4242 4242';
    _expiryController.text = '12/26';
    _cvcController.text = '123';
  }

  @override
  void dispose() {
    _navSearchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postalController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Card payment requires card to be complete
    if (_payment == 'card' && !_cardComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your complete card details.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    final user = ref.read(authProvider.notifier).getAuth();
    if (user == null) {
      ref.read(navigationProvider.notifier).setScreen(AppRoutes.signup);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign up to checkout.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _stripeStatus = null;
    });

    try {
      final cartItems = ref.read(cartProvider);
      final shippingCost = _shippingCost();
      final cartTotal = ref.read(cartProvider.notifier).totalAmount;
      final grandTotal = cartTotal + shippingCost;

      final fullAddress =
          '${_addressController.text.trim()}, '
          '${_cityController.text.trim()}, '
          '${_countryController.text.trim()} '
          '${_postalController.text.trim()}';

      // ── Stripe payment ─────────────────────────────────────────────────
      if (_payment == 'card') {
        setState(() => _stripeStatus = 'Creating payment intent…');

        final clientSecret = await StripeService.createPaymentIntent(
          amountInCents: StripeService.toCents(grandTotal),
          receiptEmail: _emailController.text.trim(),
          description: 'UniTech order for ${user.name}',
        );

        setState(() => _stripeStatus = 'Confirming payment…');

        await StripeService.confirmCardPayment(
          clientSecret: clientSecret,
          customerName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          cardNumber: _cardNumberController.text.replaceAll(' ', ''),
          expMonth: _expiryController.text.split('/')[0].trim(),
          expYear: '20${_expiryController.text.split('/').last.trim()}',
          cvc: _cvcController.text.trim(),
        );
      }

      // ── Save orders to Firestore ────────────────────────────────────────
      setState(() => _stripeStatus = 'Saving your order…');

      for (final item in cartItems) {
        final itemSubtotal = item.subtotal;
        final shippingShare =
            cartTotal > 0 ? (itemSubtotal / cartTotal) * shippingCost : 0.0;
        final orderTotal = (itemSubtotal + shippingShare).round();

        await addOrder(
          user.id,
          item.product.id,
          item.quantity,
          orderTotal,
          fullAddress,
        );
      }

      ref.read(cartProvider.notifier).clear();

      if (!mounted) return;
      setState(() {
        _submitting = false;
        _stripeStatus = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Your order has been placed.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      ref.read(navigationProvider.notifier).setScreen(AppRoutes.myOrders);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _stripeStatus = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment failed: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
        ),
      );
    }
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

    if (cartItems.isEmpty) {
      return ShopScaffold(
        searchController: _navSearchController,
        onSearchChanged: (_) {},
        onLogoTap:
            () => ref
                .read(navigationProvider.notifier)
                .setScreen(AppRoutes.shopHome),
        onLoginTap:
            () => ref
                .read(navigationProvider.notifier)
                .setScreen(AppRoutes.login),
        onSignupTap:
            () => ref
                .read(navigationProvider.notifier)
                .setScreen(AppRoutes.signup),
        onCartTap:
            () => ref
                .read(navigationProvider.notifier)
                .setScreen(AppRoutes.shopCart),
        cartCount: cartCount,
        user: authState.user,
        onProfile:
            () => ref
                .read(navigationProvider.notifier)
                .setScreen(AppRoutes.myProfile),
        onLogout: () => ref.read(authProvider.notifier).clearAuth(),
        child: Container(
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
                Icons.remove_shopping_cart_outlined,
                size: 52,
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
                child: const Text('Browse products'),
              ),
            ],
          ),
        ),
      );
    }

    return ShopScaffold(
      searchController: _navSearchController,
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
      cartCount: cartCount,
      user: authState.user,
      onProfile:
          () => ref
              .read(navigationProvider.notifier)
              .setScreen(AppRoutes.myProfile),
      onLogout: () => ref.read(authProvider.notifier).clearAuth(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 980;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: ShopColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Shipping Details', style: ShopText.heading),
                          const SizedBox(height: 14),
                          _twoColumn(
                            isWide,
                            _inputField(
                              label: 'Full Name',
                              controller: _nameController,
                              validator:
                                  (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Required'
                                          : null,
                            ),
                            _inputField(
                              label: 'Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Required';
                                final emailRegex = RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                );
                                return emailRegex.hasMatch(v.trim())
                                    ? null
                                    : 'Invalid email';
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _twoColumn(
                            isWide,
                            _inputField(
                              label: 'Phone',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator:
                                  (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Required'
                                          : null,
                            ),
                            _inputField(
                              label: 'Address',
                              controller: _addressController,
                              validator:
                                  (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Required'
                                          : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _twoColumn(
                            isWide,
                            _inputField(
                              label: 'City',
                              controller: _cityController,
                              validator:
                                  (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Required'
                                          : null,
                            ),
                            _inputField(
                              label: 'Country',
                              controller: _countryController,
                              validator:
                                  (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Required'
                                          : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _twoColumn(
                            isWide,
                            _inputField(
                              label: 'Postal Code',
                              controller: _postalController,
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Required'
                                          : null,
                            ),
                            _shippingSelector(),
                          ),
                          const SizedBox(height: 18),
                          Text('Payment', style: ShopText.heading),
                          const SizedBox(height: 10),
                          _paymentSelector(),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _placeOrder,
                              style: ShopButtonStyles.primary,
                              child:
                                  _submitting
                                      ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Text('Place Order'),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        ...cartItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.product.image,
                                    height: 52,
                                    width: 52,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.quantity} x ${_currency.format(item.product.price)}',
                                        style: ShopText.caption(),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _currency.format(item.subtotal),
                                  style: ShopText.body(
                                    ShopColors.text,
                                    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        _summaryRow(
                          'Items (${cartCount.toString()})',
                          _currency.format(total),
                        ),
                        _summaryRow('Shipping', _shippingLabel()),
                        const Divider(height: 24),
                        _summaryRow(
                          'Grand Total',
                          _currency.format(total + _shippingCost()),
                          emphasize: true,
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

  Widget _twoColumn(bool isWide, Widget left, Widget right) {
    if (!isWide) {
      return Column(children: [left, const SizedBox(height: 12), right]);
    }
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: ShopColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ShopColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ShopColors.primary),
        ),
      ),
    );
  }

  Widget _shippingSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ShopColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ShopColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping',
            style: ShopText.body(ShopColors.text, FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _shippingOption('standard', 'Standard (3-5 days)', 0),
          _shippingOption('express', 'Express (1-2 days)', 6),
        ],
      ),
    );
  }

  Widget _shippingOption(String value, String label, double price) {
    return RadioListTile<String>(
      value: value,
      groupValue: _shipping,
      onChanged: (val) => setState(() => _shipping = val ?? 'standard'),
      contentPadding: EdgeInsets.zero,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: ShopText.body()),
          Text(
            price == 0 ? 'Free' : _currency.format(price),
            style: ShopText.caption(),
          ),
        ],
      ),
    );
  }

  Widget _paymentSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ShopColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ShopColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _paymentOption('card', 'Credit / Debit Card', 'Secure card payment'),
          _paymentOption('cod', 'Cash on Delivery', 'Pay when you receive'),
          // ── Stripe card field ─────────────────────────────────────────
          if (_payment == 'card') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ShopColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      _cardComplete
                          ? Colors.green.withOpacity(0.6)
                          : ShopColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: ShopColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Secured by Stripe',
                        style: ShopText.caption(ShopColors.muted),
                      ),
                      const Spacer(),
                      if (_cardComplete)
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Card ready',
                              style: ShopText.caption(Colors.green),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Card number
                  _cardInputField(
                    label: 'Card Number',
                    controller: _cardNumberController,
                    hint: '4242 4242 4242 4242',
                    maxLength: 19,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CardNumberFormatter(),
                    ],
                    onChanged: (_) => _updateCardComplete(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _cardInputField(
                          label: 'Expiry (MM/YY)',
                          controller: _expiryController,
                          hint: '12/26',
                          maxLength: 5,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ExpiryFormatter(),
                          ],
                          onChanged: (_) => _updateCardComplete(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _cardInputField(
                          label: 'CVC',
                          controller: _cvcController,
                          hint: '123',
                          maxLength: 3,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => _updateCardComplete(),
                          obscure: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_submitting && _stripeStatus != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ShopColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _stripeStatus!,
                    style: ShopText.caption(ShopColors.primary),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _paymentOption(String value, String title, String caption) {
    return RadioListTile<String>(
      value: value,
      groupValue: _payment,
      onChanged: (val) => setState(() => _payment = val ?? 'card'),
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Icon(
            value == 'card' ? Icons.credit_card : Icons.payments_outlined,
            color: ShopColors.text,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ShopText.body(ShopColors.text, FontWeight.w700),
              ),
              Text(caption, style: ShopText.caption()),
            ],
          ),
        ],
      ),
    );
  }

  String _shippingLabel() {
    return _shipping == 'express' ? _currency.format(6) : 'Free';
  }

  double _shippingCost() {
    return _shipping == 'express' ? 6 : 0;
  }

  void _updateCardComplete() {
    final digits = _cardNumberController.text.replaceAll(' ', '');
    final expiry = _expiryController.text;
    final cvc = _cvcController.text;
    setState(() {
      _cardComplete =
          digits.length == 16 &&
          RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry) &&
          cvc.length == 3;
    });
  }

  Widget _cardInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    required List<TextInputFormatter> inputFormatters,
    required void Function(String) onChanged,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLength: maxLength,
      keyboardType: TextInputType.number,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(color: ShopColors.text),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: ShopColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ShopColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ShopColors.primary),
        ),
      ),
    );
  }
}

// ── Stripe card number formatter  (XXXX XXXX XXXX XXXX) ──────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ── Stripe expiry formatter  (MM/YY) ─────────────────────────────────────────
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length <= 2) return newValue.copyWith(text: digits);
    final formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
