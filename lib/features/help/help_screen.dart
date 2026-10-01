import 'package:flutter/material.dart';

/// In-app user guide: quick-start tutorials and frequently asked questions.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _tutorials = <(IconData, String, List<String>)>[
    (
      Icons.person_add_alt_1_outlined,
      'Create an account & sign in',
      [
        'Open the app and tap "Sign-up" on the login screen.',
        'Enter your name, email and a password, then tap "Register".',
        'Or tap "Continue with Google" to sign in with your Google account.',
        'Forgot your password? Tap "Forgot Password?" and follow the email link.',
      ],
    ),
    (
      Icons.search,
      'Find a book',
      [
        'Home shows Bestsellers, New Arrivals and the full catalog.',
        'Tap a category chip, or "Authors" to browse by writer.',
        'Use the Search tab to search by title, author or genre.',
        'On Home, tap the sort icon to order books by price, newest or popularity.',
      ],
    ),
    (
      Icons.shopping_cart_outlined,
      'Buy books',
      [
        'Open a book and tap "Add to Cart".',
        'In the Cart tab, use + and − to change quantities; the total updates live.',
        'Tap "Checkout", choose a shipping address and payment method.',
        'Tap "Place Order". You will see a confirmation with your order number.',
      ],
    ),
    (
      Icons.local_shipping_outlined,
      'Track an order',
      [
        'Go to Profile → My Orders.',
        'Tap an order to see its delivery timeline: Pending → Processing → Shipped → Delivered.',
        'The timeline updates automatically when the store updates your order.',
      ],
    ),
    (
      Icons.star_outline,
      'Rate & review',
      [
        'Open a book and tap the stars to rate it.',
        'Tap "Write a Review" to share your thoughts.',
        'Tap the heart next to any review you find helpful to like it.',
      ],
    ),
    (
      Icons.favorite_border,
      'Wishlist',
      [
        'Tap the heart on any book to save it for later.',
        'Open the Wishlist to view or remove books, or move them all to your cart.',
      ],
    ),
    (
      Icons.manage_accounts_outlined,
      'Manage your profile',
      [
        'Profile → Edit Profile to change your name or photo.',
        'Profile → Shipping Addresses to add, edit or set a default address.',
        'Profile → Payment Methods to save cards for faster checkout.',
        'Profile → Change Password to update your password.',
      ],
    ),
  ];

  static const _faqs = <(String, String)>[
    (
      'Do I need an account to browse?',
      'You need to sign in to use the store, so your cart, wishlist, orders and reviews are saved to your account and available on any device.',
    ),
    (
      'Which payment methods are accepted?',
      'Cash on Delivery is always available. You can also save a debit/credit card under Profile → Payment Methods and select it at checkout.',
    ),
    (
      'Is my card information safe?',
      'Only the card brand, last 4 digits, holder name and expiry date are saved, in a private area of your account that only you can read. The full card number and CVV are never stored.',
    ),
    (
      'How do I know where my order is?',
      'Open Profile → My Orders and tap the order. The tracking screen shows each delivery stage with the date it was reached.',
    ),
    (
      'Can I change the quantity of a book in my cart?',
      'Yes. Use the + and − buttons in the Cart. You cannot add more copies than are in stock.',
    ),
    (
      'Why can\'t I log in?',
      'Check your email and password, or use "Forgot Password?" to reset it. If you see "account has been blocked", contact the store administrator.',
    ),
    (
      'Does the app work offline?',
      'Book covers you have already viewed are cached and still show offline. An offline banner appears when there is no connection; placing orders and syncing require internet.',
    ),
    (
      'How do I switch to dark mode?',
      'Open Profile and toggle the Light/Dark Mode switch.',
    ),
    (
      'How do I delete my account?',
      'Profile → Delete Account. This permanently removes your profile, cart, wishlist, saved addresses and cards. Past orders are kept anonymously for store records.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('User Guide', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text(
            'Step-by-step tutorials for everything you can do in BooksBound.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          for (final (icon, title, steps) in _tutorials)
            Card(
              child: ExpansionTile(
                leading: Icon(icon),
                title: Text(title),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                children: [
                  for (var i = 0; i < steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 11,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(steps[i])),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Text('Frequently Asked Questions', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final (question, answer) in _faqs)
            Card(
              child: ExpansionTile(
                leading: const Icon(Icons.help_outline),
                title: Text(question),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(answer)],
              ),
            ),
        ],
      ),
    );
  }
}
