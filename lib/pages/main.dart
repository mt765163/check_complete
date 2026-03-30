import 'package:check_complete/pages/routines_page.dart';
import 'package:check_complete/pages/tasks_page.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../services/hive_crud_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveCrudService.init();
  // final hive = HiveCrudService();

  // await hive.put('tasks', 'task_1', {'title': 'Buy groceries', 'completed': false, 'due': '2026-03-29'}, onlyIfAbsent: false);
  // await hive.put('tasks', 'task_2', {'title': 'Walk the dog', 'completed': false}, onlyIfAbsent: true);
  // await hive.put('tasks', 'task_3', {'title': 'Finish Flutter project', 'completed': true}, onlyIfAbsent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Check Complete'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _goToTasksPage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TasksPage(title: "Tasks"))
    );
  }

  void _goToRoutinePage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RoutinesPage(title: "Routines"))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Press to go to Tasks page!"),
            TextButton(onPressed: _goToTasksPage, child: Text("PRESS ME")),

            Text("Press to go to Routines page!"),
            TextButton(onPressed: _goToRoutinePage, child: Text("PRESS ME"))
          ],
        ),
      ),
    );
  }
}

class LabeledSelect extends StatelessWidget {
  final String label_string;
  final String hint_string;
  final List<String> select_Array;

  const LabeledSelect({super.key, required this.label_string, required this.select_Array, required this.hint_string});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label_string),
        FSelect<String>.rich(
          hint: hint_string,
          format: (s) => s,
          children: [
            for (final item in select_Array)
              FSelectItem(title: Text(item), value: item),
          ],
        ),
      ],
    );
  }
}


