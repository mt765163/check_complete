import 'package:check_complete/pages/task_creation_sheet.dart';
import 'package:check_complete/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
// import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:check_complete/utils/reminder_utils.dart';

import '../services/hive_crud_service.dart';


class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.title});

  final String title;

  @override
  State<TasksPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TasksPage> {

  final HiveCrudService _hive = HiveCrudService();
  Map<String, Map<String, dynamic>> _tasks = {};

  @override
  void initState() {
    super.initState();
    _getTasks();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _getTasks() async {
    final tasks = await _hive.getAll('tasks');
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _toggleTask(String key, Map<String, dynamic> task) async {
    await _hive.put('tasks', key, {
      ...task,
      'completed': !(task['completed'] as bool? ?? false),
    });
    await _getTasks();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _tasks.isEmpty
            ? const Center(child: Text("No tasks yet. Tap + to create one."))
            : ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            final key = _tasks.keys.elementAt(index);
            final task = _tasks[key]!;
            final bool completed = task['completed'] as bool? ?? false;

            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: completed,
                      onChanged: (_) => _toggleTask(key, task),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'] ?? 'Untitled',
                            style: TextStyle(
                              fontSize: 18,
                              decoration: completed ? TextDecoration.lineThrough : null,
                              color: completed ? Colors.grey : null,
                            ),
                          ),
                          if (task['due'] != null)
                            Text(
                              _formatDate(task['due']),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (task['reminder_style'] != null)
                            Row(
                              children: [
                                const Icon(Icons.notifications_outlined, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${task['reminder_style']} — '
                                  '${formatReminderMinutes((task['reminder_time'] as num?)?.toInt() ?? 0)}',
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
                        await _hive.delete('tasks', key);
                        await _getTasks();
                      },
                    ),
                  ],
                ),
              ),
            );

          },
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => const TaskCreationSheet(),
          );
          await _getTasks();
        },
        child: const Icon(Icons.add_rounded),
      ),

    );
  }
}



