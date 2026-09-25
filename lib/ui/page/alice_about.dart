import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alice/theme/theme.dart';

class AliceAbout extends StatelessWidget {
  const AliceAbout({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: aliceTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('About Alice'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              color: AliceColors.primaryLight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alice - HTTP Inspector for Flutter',
                      style: AliceStyles.titleLarge.primaryDark,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Alice is a powerful HTTP Inspector tool for Flutter developers. It captures, stores, and displays HTTP requests and responses in a user-friendly interface.',
                      style: AliceStyles.body,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Contact Information',
              style: AliceStyles.titleMedium,
            ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.email, color: Colors.green),
                    title: Text('Email'),
                      subtitle: SelectableText('hi@navist.uk'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.phone, color: Colors.green),
                    title: Text('Phone'),
                    subtitle: SelectableText('+84 888 866 930'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Feel free to contact us for support, guidance, or any questions about Alice.',
                      style: AliceStyles.body.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Support Us',
              style: AliceStyles.titleMedium,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                    AliceButton(
                      text: 'Donate via PayPal',
                      icon: Icons.payment,
                      onPressed: () =>
                          _launchUrl(context, 'https://paypal.me/hautvfami'),
                  ),
                  const SizedBox(height: 10),
                    const Text(
                    'Support our development with a donation.',
                      style: AliceStyles.caption,
                  ),
                  const Divider(height: 20),
                  const Text(
                    'Rate Our Apps on Google Play\n(5 stars appreciated!)',
                      style: AliceStyles.bodyBold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildAppButton(
                        context,
                        'Drunk Deck',
                        'https://play.google.com/store/apps/details?id=com.stark.drunk_deck&hl=en&gl=us',
                      ),
                      _buildAppButton(
                        context,
                        'QR Scan',
                        'https://play.google.com/store/apps/details?id=com.stark.qr_scan&hl=en&gl=us',
                      ),
                      _buildAppButton(
                        context,
                        'Drinking Games',
                        'https://play.google.com/store/apps/details?id=com.stark.drinking&hl=en&gl=us',
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                    AliceButton(
                      text: 'Star on GitHub',
                      icon: Icons.star,
                    onPressed: () => _launchUrl(
                        context,
                          'https://github.com/hautvfami/flutter-alice'),
                  ),
                  const SizedBox(height: 10),
                    const Text(
                    'Give us a star to show your support!',
                      style: AliceStyles.caption,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SafeArea(
            child: Center(
              child: Text(
                'We appreciate any support! 🎉',
                  style: AliceStyles.titleMedium.copyWith(
                    color: AliceColors.primaryDark,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildAppButton(BuildContext context, String appName, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: () => _launchUrl(context, url),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text('Rate $appName'),
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) {
    _showLinkDialog(context, url, 'Open Link');
  }

  void _showLinkDialog(BuildContext context, String url, String title) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title, textAlign: TextAlign.center),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent(url)}',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.qr_code, size: 150, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              SelectableText(
                url,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              const Text(
                'Scan the QR code or copy the link above and paste it into your browser.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied to clipboard: $url')),
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Copy'),
            ),
          ],
        );
      },
    );
  }
}
