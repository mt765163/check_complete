import 'package:check_complete/services/hive_crud_service.dart';
import 'package:check_complete/utils/reminder_utils.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class TaskCreationSheet extends StatefulWidget {
  const TaskCreationSheet({super.key});

  @override
  State<TaskCreationSheet> createState() => _TaskCreationSheetState();
}

class _TaskCreationSheetState extends State<TaskCreationSheet> {
  final HiveCrudService _hive = HiveCrudService();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _reminderAmountController =
      TextEditingController(text: '15');

  DateTime? _selectedDate;

  String _reminderStyle = 'Notification';
  final List<String> _reminderStyles = ['Notification', 'Email', 'Text'];

  int _reminderAmount = 15;
  String _reminderUnit = 'Minutes';
  final List<String> _reminderUnits = ['Minutes', 'Hours', 'Days'];

  int _toMinutes() {
    switch (_reminderUnit) {
      case 'Hours':
        return _reminderAmount * 60;
      case 'Days':
        return _reminderAmount * 1440;
      default:
        return _reminderAmount;
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _saveTask() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task name.')),
      );
      return;
    }

    final key = 'task_${DateTime.now().millisecondsSinceEpoch}';
    await _hive.put('tasks', key, {
      'title': title,
      'completed': false,
      'due': _selectedDate != null
          ? _selectedDate!.toLocal().toString().split(' ')[0]
          : null,
      'reminder_style': _reminderStyle,
      'reminder_time': _toMinutes(),
    }, onlyIfAbsent: true);

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _taskController.dispose();
    _dateController.dispose();
    _reminderAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Create Task', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16.0),
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: 'Due Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Reminder Style',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              initialValue: _reminderStyle,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _reminderStyles
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) => setState(() => _reminderStyle = value!),
            ),
            const SizedBox(height: 16.0),
            const Text('Reminder Time',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _reminderAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Amount',
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed >= 0) {
                        setState(() => _reminderAmount = parsed);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _reminderUnit,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    items: _reminderUnits
                        .map((u) =>
                            DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _reminderUnit = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Remind ${formatReminderMinutes(_toMinutes())}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 12),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saveTask,
                icon: const Icon(FIcons.plus),
                label: const Text('Save Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}