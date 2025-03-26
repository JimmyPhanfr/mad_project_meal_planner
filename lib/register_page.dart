import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'search_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  DateTime _date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final _formKey = GlobalKey<FormState>();

  final _textControllerName = TextEditingController();
  final _textControllerEmail = TextEditingController();
  final _textControllerDateOfBirth = TextEditingController();
  final _textControllerPassword = TextEditingController();
  final _textControllerReenterPassword = TextEditingController();

  bool _isPasswordObscure = true;

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _textControllerDateOfBirth.text = DateFormat('MM-dd-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.webp", 
              fit: BoxFit.cover,
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40.0, child: Text("Info Needed", style: TextStyle(fontWeight: FontWeight.bold))),
                    TextFormField(
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                      controller: _textControllerName,
                      decoration: const InputDecoration(hintText: "Name", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      validator: (value) {
                        RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        } else if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      controller: _textControllerEmail,
                      decoration: const InputDecoration(hintText: "Email", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      controller: _textControllerDateOfBirth,
                      readOnly: true,
                      validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
                      decoration: InputDecoration(
                        hintText: "Date of Birth",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _selectDate(context)),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      validator: (value) {
                        RegExp passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>])[A-Za-z\d!@#\$%^&*(),.?":{}|<>]{8,}$');
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        } else if (!passwordRegex.hasMatch(value)) {
                          return 'Password must include: \n- At least 8 characters \n- A letter \n- A number \n- A special character';
                        }
                        return null;
                      },
                      controller: _textControllerPassword,
                      obscureText: _isPasswordObscure,
                      decoration: InputDecoration(
                        hintText: "Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordObscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isPasswordObscure = !_isPasswordObscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Re-Enter password';
                        } else if (value != _textControllerPassword.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      controller: _textControllerReenterPassword,
                      obscureText: _isPasswordObscure,
                      decoration: InputDecoration(
                        hintText: "Re-Enter Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordObscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isPasswordObscure = !_isPasswordObscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing Data')));
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SearchPage()));
                        }
                      },
                      child: const Text('Submit'),
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
