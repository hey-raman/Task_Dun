// File: pages_main/search_view.dart

import 'package:card_wiper/pages_main/task_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task.dart'; // Make sure this path is correct

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _supabaseClient = Supabase.instance.client;
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _fetchTasks();
  }

  Future<List<Task>> _fetchTasks() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      // Return an empty list or handle the case where the user is not logged in.
      return [];
    }

    // Fetch data from the 'tasks' table where 'user_id' matches the current user.
    final List<dynamic> response = await _supabaseClient
        .from('tasks')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    // Map the raw data to a list of Task objects.
    return response.map((taskMap) => Task.fromMap(taskMap)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loading indicator while data is being fetched.
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Display an error message if something went wrong.
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Display a message if no tasks are found.
          return const Center(child: Text('No tasks found.'));
        } else {
          // Display the list of tasks.
          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ListTile(
                  title: Text(task.title, style: TextStyle(fontSize: 20)),
                  subtitle: Text(
                    task.description,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text("₹${task.reward}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailView(task: task),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget ybuild(BuildContext context) {
    // TODO: implement ybuild
    throw UnimplementedError();
  }
}
