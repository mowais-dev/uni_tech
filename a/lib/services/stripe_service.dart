import 'dart:convert';
import 'dart:js_interop';

import 'package:uni_tech/config/stripe_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ── Stripe.js interop stubs ───────────────────────────────────────────────────
// @JS top-level externals bind to matching names on the browser window object.

@JS('stripeInit')
external void _stripeInit(String publishableKey);

@JS('stripeConfirmPayment')
external JSPromise _stripeConfirmPayment(
  String clientSecret,
  String paymentMethodId,
);

// ─────────────────────────────────────────────────────────────────────────────

class StripeService {
  static const String _baseUrl = 'https://api.stripe.com/v1';

  // ── Payment Intent ──────────────────────────────────────────────────────────

  /// Creates a Stripe PaymentIntent and returns the client secret.
  ///
  /// [amount] must be in the smallest currency unit (e.g. cents for USD).
  ///
  /// ⚠️  This calls the Stripe API directly using the secret key.
  ///     In production, replace this call with a request to your own backend
  ///     so the secret key is never exposed to clients.
  static Future<String> createPaymentIntent({
    required int amountInCents,
    String currency = StripeConfig.currency,
    String? receiptEmail,
    String? description,
  }) async {
    try {
      final body = <String, String>{
        'amount': amountInCents.toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
        if (receiptEmail != null && receiptEmail.isNotEmpty)
          'receipt_email': receiptEmail,
        if (description != null && description.isNotEmpty)
          'description': description,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${StripeConfig.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        final errorMsg =
            (data['error'] as Map<String, dynamic>?)?['message'] ??
            'Unknown Stripe error';
        throw Exception(errorMsg);
      }

      return data['client_secret'] as String;
    } catch (e) {
      debugPrint('StripeService.createPaymentIntent error: $e');
      rethrow;
    }
  }

  // ── Init ────────────────────────────────────────────────────────────────────

  /// Initialises Stripe.js with the publishable key.
  /// Call once before the checkout screen is shown.
  static void initStripe() {
    _stripeInit(StripeConfig.publishableKey);
  }

  // ── Create PaymentMethod via REST ──────────────────────────────────────────

  /// Creates a Stripe PaymentMethod using the **publishable key** via the
  /// Stripe REST API.  This is permitted from the browser and is how the
  /// official mobile SDKs tokenise raw card data.
  static Future<String> _createPaymentMethod({
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
    required String name,
    required String email,
    String? phone,
  }) async {
    final body = <String, String>{
      'type': 'card',
      'card[number]': cardNumber.replaceAll(RegExp(r'\s'), ''),
      'card[exp_month]': expMonth,
      'card[exp_year]': expYear,
      'card[cvc]': cvc,
      'billing_details[name]': name,
      'billing_details[email]': email,
      if (phone != null && phone.isNotEmpty) 'billing_details[phone]': phone,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/payment_methods'),
      headers: {
        'Authorization': 'Bearer ${StripeConfig.publishableKey}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    final data = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final errorMsg =
          (data['error'] as Map<String, dynamic>?)?['message'] ??
          'Unknown Stripe error';
      throw Exception(errorMsg);
    }

    return data['id'] as String; // pm_xxx
  }

  // ── Confirm payment ─────────────────────────────────────────────────────────

  /// Confirms a card payment via Stripe.js (Flutter Web).
  ///
  /// Raw card data is tokenised via the Stripe REST API first (using the
  /// publishable key), then the resulting PaymentMethod ID is passed to
  /// Stripe.js `confirmCardPayment`.  This avoids the "Please use Stripe
  /// Elements" error thrown when raw card data is passed directly to Stripe.js.
  static Future<void> confirmCardPayment({
    required String clientSecret,
    required String customerName,
    required String email,
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
    String? phone,
  }) async {
    try {
      // Step 1 – tokenise raw card data via REST API (publishable key allowed)
      final paymentMethodId = await _createPaymentMethod(
        cardNumber: cardNumber,
        expMonth: expMonth,
        expYear: expYear,
        cvc: cvc,
        name: customerName,
        email: email,
        phone: phone,
      );

      // Step 2 – confirm via Stripe.js using the PaymentMethod ID
      await _stripeConfirmPayment(clientSecret, paymentMethodId).toDart;
    } catch (e) {
      debugPrint('StripeService.confirmCardPayment error: $e');
      final msg = e.toString();
      throw Exception(
        msg.contains('Error:') ? msg.split('Error:').last.trim() : msg,
      );
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Converts a dollar amount (double) to Stripe cents (int).
  static int toCents(double dollars) => (dollars * 100).round();
}
