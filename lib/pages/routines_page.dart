import 'package:check_complete/pages/routine_creation_sheet.dart';
import 'package:check_complete/services/hive_crud_service.dart';
import 'package:check_complete/utils/reminder_utils.dart';
import 'package:check_complete/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key, required this.title});
  final String title;

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  final HiveCrudService _hive = HiveCrudService();
  String _formatFrequency(String frequency, String detail) {
    switch (frequency) {
      case 'Every Day':
        return 'Daily at $detail';
      case 'Every Weekday':
        return 'Weekdays at $detail';
      case 'Every Week':
        return 'Weekly on $detail';
      default:
        return '$frequency — $detail';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: _hive.getAll('routines'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final routines = snapshot.data ?? {};

          if (routines.isEmpty) {
            return const Center(child: Text('No routines yet. Tap + to create one.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: routines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8.0),
            itemBuilder: (context, index) {
              final entry = routines.entries.elementAt(index);
              final routine = Map<String, dynamic>.from(entry.value);
              final reminderMinutes =
                  (routine['reminder_time'] as num?)?.toInt() ?? 0;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routine['title'] ?? '',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                const Icon(Icons.repeat, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _formatFrequency(
                                    routine['frequency'] ?? '',
                                    routine['frequency_detail'] ?? '',
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                const Icon(Icons.notifications_outlined, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${routine['reminder_style']} — '
                                      '${formatReminderMinutes(reminderMinutes)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await _hive.delete('routines', entry.key);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              );

            },
          );
        },
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (_) => const RoutineCreationSheet(),
            );
            setState(() {});
          },
          child: const Icon(Icons.add_rounded),
        ),
        bottomNavigationBar: const BottomNavBar(selectedIndex: 1)
    );
  }
}