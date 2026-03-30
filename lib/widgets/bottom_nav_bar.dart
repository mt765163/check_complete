import 'package:check_complete/pages/routines_page.dart';
import 'package:check_complete/pages/tasks_page.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  void _onTap(BuildContext context, int index) {
    if (index == selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TasksPage(title: 'Tasks')),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoutinesPage(title: 'Routines')),
        );
        break;
      case 2:
        //add this settings page at some point
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _onTap(context, index),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.task_alt_rounded), label: 'Tasks'),
            NavigationDestination(
                icon: Icon(Icons.refresh_rounded), label: 'Routines'),
            NavigationDestination(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}