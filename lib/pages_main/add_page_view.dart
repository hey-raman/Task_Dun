import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final rewardController = TextEditingController();
  final _supabaseClient = Supabase.instance.client;
  bool isLoading = false;
  DateTime? deadline;

  Future<void> _addTask() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    if (deadline == null ||
        descController == null ||
        rewardController == null ||
        titleController == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      await _supabaseClient.from('tasks').insert({
        'user_id': user.id,
        'title': titleController.text,
        'description': descController.text,
        'reward': rewardController.text,
        'deadline': deadline!.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Task added successfully!")));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Task",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 50),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Task Title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Task description
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Task Description",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Reward
                  TextField(
                    controller: rewardController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Reward",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Deadline picker
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deadline == null
                              ? "Pick Deadline"
                              : "${deadline!.day}/${deadline!.month}/${deadline!.year}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.calendar_month_rounded),

                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => deadline = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Add task button
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _addTask,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: const Color(0xFF5E81AC),
                          ),
                          child: const Text(
                            "Add Task",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget ybuild(BuildContext context) {
    // TODO: implement ybuild
    throw UnimplementedError();
  }
}
