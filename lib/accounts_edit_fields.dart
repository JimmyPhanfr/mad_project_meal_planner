import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'user_db.dart';
import 'user.dart';

void _selectDate(BuildContext context, User user, TextEditingController textControllerDateOfBirth) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.tryParse(user.dateOfBirth),
    firstDate: DateTime(1900, 1, 1),
    lastDate: DateTime.now(),
  );
  if (picked != null && picked != DateTime.tryParse(user.dateOfBirth)) {
    // setState(() {
      textControllerDateOfBirth.text = DateFormat('MM-dd-yyyy').format(picked);
    // });
  }
}

Future<bool> _validateUser(String email, String password) async {
  final UserDB userDb = UserDB();
  final user = await userDb.getUser(email, password);
  return user != null;
}

Future<void> editNameField(BuildContext context, User user) async {
  final textControllerName = TextEditingController();
  final UserDB userDb = UserDB();

  await showDialog(
    barrierDismissible: false,
    context: context,
    builder:
      (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Edit Name", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: textControllerName,
          style: TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter new name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          // cancel button
          TextButton(
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          // save button
          TextButton(
            child: Text("Save", style: TextStyle(color: Colors.white)),
            // update using db functions
            onPressed: () async {
              if (textControllerName.text.isNotEmpty) {
                userDb.updateName(user, textControllerName.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name change successful.')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please try again.')),
                );
              }
            },
          ),
        ],
      ),
  );
}

Future<void> editEmailField(BuildContext context, User user) async {
  final textControllerEmail = TextEditingController();
  final UserDB userDb = UserDB();

  await showDialog(
    barrierDismissible: false,
    context: context,
    builder:
      (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Edit Email", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: textControllerEmail,
          style: TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter new email",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          // cancel button
          TextButton(
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          // save button
          TextButton(
            child: Text("Save", style: TextStyle(color: Colors.white)),
            // update using db functions
            onPressed: () async {
              if (RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(textControllerEmail.text)) {
                userDb.updateEmail(user, textControllerEmail.text.trim().toLowerCase());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email change successful.')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please try again.')),
                );
              }
            },
          ),
        ],
      ),
  );
}

Future<void> editDOBField(BuildContext context, User user) async {
  final textControllerDOB = TextEditingController();
  final UserDB userDb = UserDB();

  await showDialog(
    barrierDismissible: false,
    context: context,
    builder:
      (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Edit date of birth", style: const TextStyle(color: Colors.white)),
        content: TextField(
          readOnly: true,
          controller: textControllerDOB,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Select new date",
            border: OutlineInputBorder(),
            suffixIcon: IconButton(icon: Icon(Icons.calendar_today, color: Colors.white), 
            onPressed: () => _selectDate(context, user, textControllerDOB)),
          ),
        ),
        actions: [
          // cancel button
          TextButton(
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          // save button
          TextButton(
            child: Text("Save", style: TextStyle(color: Colors.white)),
            // update using db functions
            onPressed: () async {
              if (textControllerDOB.text.isNotEmpty) {
                userDb.updateDOB(user, textControllerDOB.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Date of birth change successful.')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please try again.')),
                );
              }
            },
          ),
        ],
      ),
  );
}

Future<void> editPasswordField(BuildContext context, User user) async {
  final textControllerOldPassword = TextEditingController();
  final textControllerPassword = TextEditingController();
  final textControllerReenterPassword = TextEditingController();
  final UserDB userDb = UserDB();

  await showDialog(
    barrierDismissible: false,
    context: context,
    builder:
      (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Edit Password", style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          height: 195.0,
          child: Column(
            spacing: 12,
            children: [
              TextField(
                controller: textControllerOldPassword,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter old password",
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: textControllerPassword,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter new password",
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: textControllerReenterPassword,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Reenter new password",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // cancel button
          TextButton(
            child: Text("Cancel", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          // save button
          TextButton(
            child: Text("Save", style: TextStyle(color: Colors.white)),
            // update using db functions
            onPressed: () async {
              // confirm old pass
              bool isValid = await _validateUser(user.email, textControllerOldPassword.text);
              if (isValid) {
                // check new pass and reenter are same
                if (textControllerPassword.text != "" && textControllerPassword.text == textControllerReenterPassword.text) {
                  // check password strength
                  if (RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>])[A-Za-z\d!@#\$%^&*(),.?":{}|<>]{8,}$').hasMatch(textControllerPassword.text)) {
                    // update
                    userDb.updatePassword(user, textControllerPassword.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password change successful.')),
                    );
                    Navigator.pop(context);
                  // else new password too weak 
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password must include: \n- At least 8 characters \n- A letter \n- A number \n- A special character'),
                      ),
                    );
                  }
                // else new and reenter dont match
                } else { 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New password is empty or does not match Reentered'),
                    ),
                  );
                }
              // else old pass not right
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Old Password is not correct'),
                  ),
                );
              }
            },
          ),
        ],
      ),
  );
}
