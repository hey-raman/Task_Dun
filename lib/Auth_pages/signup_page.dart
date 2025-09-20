import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _supabaseClient = Supabase.instance.client.auth;

  Future<void> _signUp() async {
    if (_nameController.text.isEmpty &
        _emailController.text.isEmpty &
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ple ase fill all the fields.")),
      );
    }
    try {
      final response = await _supabaseClient.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        data: {'display_name': _nameController.text},
        emailRedirectTo: "https://taskdun.netlify.app/",
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Signed up, Please check Email to confirm!"),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );

        await Supabase.instance.client.from('profiles').insert({
          'id': response.user?.id,
          'email_id': _emailController.text,
          'name': _nameController.text,
        });
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unexpected error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  SizedBox(height: 45),

                  Text(
                    'Task Dun',
                    style: GoogleFonts.sansita(
                      fontWeight: FontWeight.bold,
                      fontSize: 70,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 7,
                      color: Color(0xFF919191),
                    ),
                  ),
                  SizedBox(height: 60),
                  Form(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            labelText: 'Name',
                            hint: Text("Enter your Display name"),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),

                        SizedBox(height: 10),

                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            labelText: 'Email',
                            hint: Text("Please enter a valid email"),
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),

                        SizedBox(height: 10),

                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            hint: Text("Password must be 6+ characters"),
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),

                        SizedBox(height: 30),

                        ElevatedButton(
                          style: ButtonStyle(
                            minimumSize: WidgetStatePropertyAll(
                              Size(double.infinity, 40),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Color(0xFF2E3440),
                            ),
                          ),
                          onPressed: () {
                            _signUp();
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        SizedBox(height: 10),

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Already have an account? Login",
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
