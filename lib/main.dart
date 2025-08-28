import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6200EE),
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF1E1E1E),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6200EE),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF6200EE)),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class Task {
  String title;
  String description;
  bool completed;

  Task({required this.title, required this.description, this.completed = false});

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'completed': completed,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        description: json['description'],
        completed: json['completed'],
      );
}

List<Task> tasks = [];

class CustomRadioIcon extends StatelessWidget {
  final bool isActive;
  final IconData iconData;
  final VoidCallback onPressed;

  const CustomRadioIcon({
    Key? key,
    required this.isActive,
    required this.iconData,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6200EE) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.transparent : const Color(0xFF6200EE),
            width: 1,
          ),
        ),
        child: Icon(
          iconData,
          color: isActive ? Colors.white : const Color(0xFF6200EE),
          size: 28,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> taskList = jsonDecode(tasksJson);
      setState(() {
        tasks = taskList.map((e) => Task.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          top: 100,
          left: MediaQuery.of(context).size.width - 250,
          right: 16.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'assets/images/activityTrackerlogo.png',
          height: 30,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomRadioIcon(
                  isActive: true,
                  iconData: Icons.add_box,
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                CustomRadioIcon(
                  isActive: false,
                  iconData: Icons.checklist,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TaskListPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Título da tarefa',
                        hintText: 'Digite o título aqui',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Fazer compras no mercado, assistir a série no Netflix...',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        String title = _titleController.text.trim();
                        String description = _descriptionController.text.trim();

                        if (title.isEmpty) {
                          _showSnackBar('O título da tarefa não pode estar vazio!', const Color.fromARGB(255, 255, 255, 255));
                        }
                        if (description.isEmpty){
                          _showSnackBar('A descrição da tarefa não pode estar vazia!', const Color.fromARGB(255, 255, 255, 255));
                        }
                         else {
                          tasks.add(Task(
                            title: title,
                            description: description,
                          ));
                          _saveTasks();
                          _titleController.clear();
                          _descriptionController.clear();
                          _showSnackBar('Tarefa salva com sucesso!', const Color(0xFF1E88E5));
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '© 2025 Activity Tracker\nFeito por Nicholas Rangel',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<dynamic> apiTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    fetchApiTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> taskList = jsonDecode(tasksJson);
      setState(() {
        tasks = taskList.map((e) => Task.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  Future<void> fetchApiTasks() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));
    if (response.statusCode == 200) {
      setState(() {
        apiTasks = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'assets/images/activityTrackerlogo.png',
          height: 30,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomRadioIcon(
                  isActive: false,
                  iconData: Icons.add_box,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8),
                CustomRadioIcon(
                  isActive: true,
                  iconData: Icons.checklist,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double screenWidth = constraints.maxWidth;
                  final bool isMobile = screenWidth < 600;

                  Widget localTasksColumn = Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tarefas Locais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          const Divider(color: Colors.white54),
                          Expanded(
                            child: ListView.builder(
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return ListTile(
                                  title: Text(task.title, style: TextStyle(color: Colors.white, decoration: task.completed ? TextDecoration.lineThrough : null)),
                                  subtitle: Text(task.description, style: TextStyle(color: Colors.white70, decoration: task.completed ? TextDecoration.lineThrough : null)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: task.completed,
                                        onChanged: (val) {
                                          setState(() {
                                            task.completed = val ?? false;
                                            _saveTasks();
                                          });
                                        },
                                        activeColor: const Color(0xFF6200EE),
                                        checkColor: Colors.white,
                                        side: const BorderSide(color: Color(0xFF6200EE)),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            tasks.removeAt(index);
                                            _saveTasks();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  Widget apiTasksColumn = Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tarefas da API', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          const Divider(color: Colors.white54),
                          Expanded(
                            child: ListView.builder(
                              itemCount: apiTasks.length,
                              itemBuilder: (context, index) {
                                final task = apiTasks[index];
                                return ListTile(
                                  title: Text(task['title'], style: TextStyle(color: Colors.white, decoration: task['completed'] ? TextDecoration.lineThrough : null)),
                                  trailing: Icon(
                                    task['completed'] ? Icons.check_circle : Icons.pending,
                                    color: task['completed'] ? Colors.green : Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  return isMobile
                      ? Column(
                          children: [
                            localTasksColumn,
                            const SizedBox(height: 16),
                            apiTasksColumn,
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            localTasksColumn,
                            const SizedBox(width: 16),
                            apiTasksColumn,
                          ],
                        );
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '© 2025 Activity Tracker\nFeito por Nicholas Rangel',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}