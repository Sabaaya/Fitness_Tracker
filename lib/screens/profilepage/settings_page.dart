import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconRow(
              text: 'Units of Measure',
              onTap: () {
                Navigator.pushNamed(context, '/unit');
              },
            ),
            
          
            _buildDivider(),
            IconRow(
              text: 'Contact Us',
              onTap: () {
                Navigator.pushNamed(context, '/contact');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200.withOpacity(0.15),
      thickness: 1,
      height: 20,
    );
  }
}

class IconRow extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const IconRow({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
