import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/main_content.dart';
import '../widgets/player_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Stack(
              children: [
                MainContent(),
                Align(alignment: Alignment.bottomCenter, child: PlayerBar()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
