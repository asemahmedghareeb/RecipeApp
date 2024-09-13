import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  // final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
        ;
      });

      final registerData = {
        'username': _nameController.text,
        'password': _passwordController.text,
      };
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(registerData),
        );
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "success") {
          print('Registration successful');
          _successMessage = "Registration successful";
        } else {
          _errorMessage = 'Registration failed. Please try again.';
        }
        print(response.body);
      } catch (error) {
        print('Error registering: $error');
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
        title: const Text('Register Page'),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(20,100,20,20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Please Enter Your New Account Information"),
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
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty || value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20,),
              FilledButton(
                onPressed: _submitForm,
                child: const Text('Register'),
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
