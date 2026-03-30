String formatReminderMinutes(int totalMinutes) {
  if (totalMinutes == 0) return 'On time';
  final days = totalMinutes ~/ 1440;
  final hours = (totalMinutes % 1440) ~/ 60;
  final minutes = totalMinutes % 60;

  final parts = <String>[];
  if (days > 0) parts.add('$days ${days == 1 ? 'day' : 'days'}');
  if (hours > 0) parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
  if (minutes > 0) parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
  return '${parts.join(' ')} before';
}