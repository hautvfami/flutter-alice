import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart'; // Add url_launcher dependency if needed

class AliceAbout extends StatefulWidget {
  const AliceAbout({super.key});

  @override
  State<AliceAbout> createState() => _AliceAboutState();
}

class _AliceAboutState extends State<AliceAbout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('About Alice'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Introduction
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alice - HTTP Inspector for Flutter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Alice is a powerful HTTP Inspector tool for Flutter developers. It captures, stores, and displays HTTP requests and responses in a user-friendly interface.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Contact Information
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.green),
                    title: const Text('Email'),
                    subtitle: const SelectableText('hautv.fami@gmail.com'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.green),
                    title: const Text('Phone'),
                    subtitle: const SelectableText('+84 888 866 930'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Feel free to contact us for support, guidance, or any questions about Alice.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Support Us
          const Text(
            'Support Us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // PayPal
                  ElevatedButton.icon(
                    onPressed: () => _launchUrl('https://paypal.me/hautvfami'),
                    icon: const Icon(Icons.payment),
                    label: const Text('Donate via PayPal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Support our development with a donation.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const Divider(height: 20),

                  // Rate Our Apps
                  const Text(
                    'Rate Our Apps on Google Play\n(5 stars appreciated!)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildAppButton(
                        'Drunk Deck',
                        'https://play.google.com/store/apps/details?id=com.stark.drunk_deck&hl=en&gl=us',
                      ),
                      _buildAppButton(
                        'QR Scan',
                        'https://play.google.com/store/apps/details?id=com.stark.qr_scan&hl=en&gl=us',
                      ),
                      _buildAppButton(
                        'Drinking Games',
                        'https://play.google.com/store/apps/details?id=com.stark.drinking&hl=en&gl=us',
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Star the Repo
                  ElevatedButton.icon(
                    onPressed: () => _launchUrl(
                        'https://github.com/hautvfami/flutter-alice'),
                    icon: const Icon(Icons.star),
                    label: const Text('Star on GitHub'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Give us a star to show your support!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Closing
          SafeArea(
            child: Center(
              child: Text(
                'We appreciate any support! 🎉',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppButton(String appName, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: () => _launchUrl(url),
        child: Text('Rate $appName'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    _showLinkDialog(context, url, 'Open Link');
  }

  void _showLinkDialog(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    Icon(Icons.qr_code, size: 150, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              SelectableText(
                url,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Text(
                'Scan the QR code or copy the link above and paste it into your browser.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied to clipboard: $url')),
                );
                Navigator.of(context).pop();
              },
              child: Text('Copy'),
            ),
          ],
        );
      },
    );
  }
}
