import 'package:flutter/material.dart';
import 'user_db.dart';
import 'register_page.dart';
import 'favorite_page.dart';
import 'load_recipes.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscure = true;

  final UserDB _userDB = UserDB();

  Future<bool> _validateUser(String email, String password) async {
    final user = await _userDB.getUser(email, password);
    return user != null;
  }

  void _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      bool isValid = await _validateUser(_emailController.text.trim().toLowerCase(), _passwordController.text.trim());
      if (isValid) {
        final user = await UserDB().getUser(_emailController.text.trim().toLowerCase(), _passwordController.text.trim());
        if (user != null) {
          await LoadRecipes.instance.loadRecipes();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Successful')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FavoritePage(currentUser: user)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not found')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Email or Password')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Prep App by Team Cook', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/background.webp',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 12.0,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: const Text("Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
                      decoration: const InputDecoration(hintText: "Email", border: OutlineInputBorder()),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordObscure,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
                      decoration: InputDecoration(
                        hintText: "Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordObscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isPasswordObscure = !_isPasswordObscure),
                        ),
                      ),
                    ),
                    // Center(
                    //   child: ElevatedButton(
                    //     onPressed: () { 
                    //       _login(context);
                    //     },
                    //     child: const Text('Login'),
                    //   ),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                          },
                          child: const Text("Don't have an account? Register"),
                        ),
                        ElevatedButton(
                        onPressed: () { 
                          _login(context);
                        },
                        child: const Text('Login'),
                      ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
