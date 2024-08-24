import 'dart:convert';
import 'package:client/secureStorage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });

      final registerData = {
        'username': _nameController.text,
        'password': _passwordController.text,
      };
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(registerData),
        );
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "success") {
          _successMessage = "You LogedIn Successful";
        } else {
          _errorMessage = 'Login failed. Please try again.';
        }
        final token = jsonData['token'];
        final userId = jsonData['data']['userId'];

        await SecureStorage().writeSecureDate("jwt_token", "$token");
        await await SecureStorage().writeSecureDate("userId", userId);

        Navigator.pushNamed(context, '/');
      } catch (error) {
        _errorMessage = 'An error occurred. Please try again later.';
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(20, 100, 20, 20),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Please Enter your Account Information"),
              const SizedBox(height:50),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20,),
              FilledButton(
                onPressed: _submitForm,
                child: const Text('Login'),
              ),
              if (_isLoading) const CircularProgressIndicator(),
              if (_errorMessage != null) Text(_errorMessage!),
              if (_successMessage != null) Text(_successMessage!),
            ],
          ),
        ),
      ),
    );
  }

}
