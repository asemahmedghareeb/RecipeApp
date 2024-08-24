import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:client/secureStorage.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Createrecipe extends StatefulWidget {
  const Createrecipe({super.key});

  @override
  _CreaterecipeState createState() => _CreaterecipeState();
}

class _CreaterecipeState extends State<Createrecipe> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  String imageUrl = "";
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
      final userOwner = await SecureStorage().readSecureDate("userId");
      final recipeData = {
        'name': _nameController.text,
        'instructions': _instructionsController.text,
        "cookingTime": _cookingTimeController.text,
        "userOwner": userOwner
      };

      try {
        final token = await SecureStorage().readSecureDate("jwt_token");
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/recipes/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$token'
          },
          body: jsonEncode(recipeData),
        );
        final jsonData = jsonDecode(response.body);
        print(jsonData);
        if (jsonData['status'] == "success") {
          print('Recipe Created Successful');
          _successMessage = "Recipe Created Successful";
        } else {
          _errorMessage = 'Creating Recipe failed. Please try again.';
        }

        Navigator.pushNamed(context, '/');
      } catch (error) {
        print('Error while Creating the Recipe: $error');
        _errorMessage = 'An error occurred. Please try again later.';
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  uploadImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);
    try {
      await referenceImageToUpload.putFile(File(file!.path));

      imageUrl = await referenceImageToUpload.getDownloadURL();
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe Page'),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(20, 100, 20, 20),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text("Please Enter Your Recipe Information"),
                SizedBox(height: 50),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Recipe Name',
                  ),
                ),
                TextFormField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(
                    labelText: 'instructions',
                  ),
                ),
                TextFormField(
                  controller: _cookingTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Cooking Time',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // FilledButton(
                //   onPressed: () async {
                //     await uploadImage();
                //   },
                //   child: const Text('upload Recipe Image'),
                // ),
                const SizedBox(
                  height: 20,
                ),
                FilledButton(
                  onPressed: _submitForm,
                  child: const Text('Create'),
                ),
                if (_isLoading) const CircularProgressIndicator(),
                if (_errorMessage != null) Text(_errorMessage!),
                if (_successMessage != null) Text(_successMessage!),
              ],
            )),
      ),
    );
  }
}
