import 'package:card_wiper/pages_main/profile_view.dart';
import 'package:card_wiper/pages_main/search_view.dart';
import 'package:card_wiper/pages_main/task_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Auth_pages/login_page.dart';
import '../models/task.dart';
import 'add_page_view.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  int _currentIndex = 1;
  final _supabaseClient = Supabase.instance.client;
  List<Task> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => isLoading = true);
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
        return;
      }

      final data = await _supabaseClient
          .from('tasks')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (data is List) {
        setState(() {
          tasks = data
              .map((e) => Task.fromMap(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching tasks: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Task Dun",
          style: GoogleFonts.sansita(fontWeight: FontWeight.w600, fontSize: 30),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _supabaseClient.auth.signOut();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User Signed Out")),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Reload tasks if the user navigates back to the task view
            if (index == 1) {
              _loadTasks();
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.paste), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF5E81AC),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddTaskPage()),
                );
                if (result == true) {
                  // Reload tasks after a new one is added
                  _loadTasks();
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: _currentIndex == 0
          ? const SearchView()
          : _currentIndex == 1
          ? _TaskViewSwipeWidget()
          : const ProfileView(),
    );
  }

  Widget _TaskViewSwipeWidget() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tasks.isEmpty) {
      return const Center(child: Text("No tasks available"));
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 400,
                child: CardSwiper(
                  cardsCount: tasks.length,
                  numberOfCardsDisplayed: tasks.length > 0 ? 2 : 0,
                  onSwipe: (previousIndex, currentIndex, direction) {
                    if (direction == CardSwiperDirection.right) {
                      // Navigate to a new page with the task details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskDetailView(task: tasks[previousIndex]),
                        ),
                      );
                    }
                    // The function returns a boolean. Returning `true` allows the swipe to complete.
                    return true;
                  },
                  cardBuilder:
                      (context, index, percentThresholdX, percentThresholdY) {
                        final task = tasks[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                SingleChildScrollView(
                                  child: Text(
                                    task.description,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                const Spacer(),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Reward: ₹${task.reward}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Deadline: ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                ),
              ),
            ),
          ],
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
