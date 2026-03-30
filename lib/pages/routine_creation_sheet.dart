import 'package:check_complete/services/hive_crud_service.dart';
  import 'package:check_complete/utils/reminder_utils.dart';
  import 'package:flutter/material.dart';
  import 'package:forui/forui.dart';

  class RoutineCreationSheet extends StatefulWidget {
    const RoutineCreationSheet({super.key});

    @override
    State<RoutineCreationSheet> createState() => _RoutineCreationSheetState();
  }

  class _RoutineCreationSheetState extends State<RoutineCreationSheet> {
    final HiveCrudService _hive = HiveCrudService();
    final TextEditingController _titleController = TextEditingController();

    String _frequency = 'Every Day';
    final List<String> _frequencies = ['Every Day', 'Every Week', 'Every Weekday'];

    TimeOfDay _selectedTime = TimeOfDay.now();

    String _selectedDay = 'Monday';
    final List<String> _daysOfWeek = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    String _reminderStyle = 'Notification';
    final List<String> _reminderStyles = ['Notification', 'Email', 'Text'];

    int _reminderAmount = 15;
    String _reminderUnit = 'Minutes';
    final List<String> _reminderUnits = ['Minutes', 'Hours', 'Days'];
    final TextEditingController _reminderAmountController =
        TextEditingController(text: '15');

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

    Future<void> _pickTime() async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      if (picked != null) setState(() => _selectedTime = picked);
    }

    String _formatTime(TimeOfDay time) {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }

    Future<void> _saveRoutine() async {
      final title = _titleController.text.trim();
      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a routine name.')),
        );
        return;
      }

      final frequencyDetail =
          (_frequency == 'Every Day' || _frequency == 'Every Weekday')
              ? _formatTime(_selectedTime)
              : _selectedDay;

      final key = 'routine_${DateTime.now().millisecondsSinceEpoch}';
      await _hive.put('routines', key, {
        'title': title,
        'frequency': _frequency,
        'frequency_detail': frequencyDetail,
        'reminder_style': _reminderStyle,
        'reminder_time': _toMinutes(),
      });

      if (mounted) Navigator.pop(context);
    }

    @override
    void dispose() {
      _titleController.dispose();
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
              Text('Create Routine', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16.0),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Routine Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('Frequency',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                initialValue: _frequency,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _frequencies
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (value) => setState(() => _frequency = value!),
              ),
              const SizedBox(height: 16.0),
              if (_frequency == 'Every Day' || _frequency == 'Every Weekday') ...[
                const Text('Time',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8.0),
                OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time),
                  label: Text(_formatTime(_selectedTime)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ] else ...[
                const Text('Day of Week',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8.0),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDay,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  items: _daysOfWeek
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedDay = value!),
                ),
              ],
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
                  onPressed: _saveRoutine,
                  icon: const Icon(FIcons.plus),
                  label: const Text('Save Routine'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }