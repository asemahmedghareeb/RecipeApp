import 'dart:convert';
import 'package:client/secureStorage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Editrecipe extends StatefulWidget {
  const Editrecipe({super.key});
  
  @override
  _EditrecipeeState createState() => _EditrecipeeState();
}

class _EditrecipeeState extends State<Editrecipe> {
  @override
  void initState() {
    super.initState();
    getRecipeData();
  }

  String recipeId = '';
  Map oldRecipe = {};
  final _formKey = GlobalKey<FormState>();
  dynamic _nameController;
  dynamic _instructionsController;
  dynamic _cookingTimeController;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  Future<String> getRecipeId() async {
    String id = await SecureStorage().readSecureDate("recipeId");

    return id;
  }

  getRecipeData() async {
    try {
      final token = await SecureStorage().readSecureDate("jwt_token");
      this.recipeId = await getRecipeId();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/recipes/$recipeId'),
        headers: {'Authorization': '$token'},
      );
      final jsonData = jsonDecode(response.body);

      if (jsonData['status'] == "success") {
        print('getting the recipe succeeded');
        print("${this.oldRecipe}");
        setState(() {
          this.oldRecipe = jsonData['data']['recipe'];
        });
        _nameController = TextEditingController(text: this.oldRecipe['name']);
        _instructionsController =
            TextEditingController(text: this.oldRecipe['instructions']);
        _cookingTimeController =
            TextEditingController(text: "${this.oldRecipe['cookingTime']}");
      } else {
        print('Recipe getting Failed');
      }
    } catch (error) {
      print('Error while getting the Recipe: $error');
      _errorMessage = 'An error occurred. Please try again later.';
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });
      final recipeData = {
        'name': _nameController.text,
        'instructions': _instructionsController.text,
        "cookingTime": int.parse(_cookingTimeController.text),
      };
      try {
        final userId = await SecureStorage().readSecureDate("userId");
        final token = await SecureStorage().readSecureDate("jwt_token");
        this.recipeId = await getRecipeId();
        final response = await http.patch(
          Uri.parse('http://10.0.2.2:3000/recipes/$recipeId/$userId/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$token'
          },
          body: jsonEncode(recipeData),
        );
        final jsonData = jsonDecode(response.body);

        if (jsonData['status'] == "success") {
          print('Recipe updated Successful');
          _successMessage = "Recipe updated Successful";
          await SecureStorage().deleteSecureData("recipeId");
        } else {
          _errorMessage = 'updating Recipe failed. Please try again.';
        }

        Navigator.pushNamed(context, '/');
      } catch (error) {
        print('Error while updating the Recipe: $error');
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
        title: const Text('Edit Recipe Page'),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(20, 100, 20, 20),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text("Please Enter the new Changes"),
                SizedBox(height:50),
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
                FilledButton(
                  onPressed: _submitForm,
                  child: const Text('Update'),
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
