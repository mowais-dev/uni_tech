// ─────────────────────────────────────────────────────────────────────────────
// Stripe Configuration
//
// ⚠️  DEVELOPMENT ONLY
//     The secret key below must NEVER be shipped to production.
//     In production, move createPaymentIntent() to a secure server
//     (Firebase Cloud Function, Node.js backend, etc.) and only keep the
//     publishable key on the client.
// ─────────────────────────────────────────────────────────────────────────────

class StripeConfig {
  /// Your Stripe publishable key (safe to expose on client)
  static const String publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY_HERE';

  /// ⚠️  DEV ONLY – move to your backend for production
  static const String secretKey = 'YOUR_STRIPE_SECRET_KEY';

  /// Currency – lowercase ISO 4217 code
  static const String currency = 'usd';
}
