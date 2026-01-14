import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../signals/settings_signal.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                if (MediaQuery.of(context).size.width < 600)
                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFFFCE7AC)),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFCE7AC),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Customize your experience',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Text Scale Setting
            Watch((context) {
              final scale = settingsSignal.textScaleFactor.value;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(170, 17, 23, 28),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromARGB(38, 255, 239, 175),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Text Scale',
                      style: TextStyle(
                        color: Color(0xFFFCE7AC),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adjust the size of text throughout the app',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Decrement button
                        IconButton(
                          onPressed: scale > 0.5
                              ? () =>
                                    settingsSignal.updateTextScale(scale - 0.1)
                              : null,
                          icon: const Icon(Icons.remove),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF1E222B),
                            foregroundColor: Colors.white70,
                            disabledForegroundColor: Colors.white24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Current value display
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E222B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${(scale * 100).round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Increment button
                        IconButton(
                          onPressed: scale < 2.0
                              ? () =>
                                    settingsSignal.updateTextScale(scale + 0.1)
                              : null,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF1E222B),
                            foregroundColor: Colors.white70,
                            disabledForegroundColor: Colors.white24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Preview text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E222B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'The quick brown fox jumps over the lazy dog',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
