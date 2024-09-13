import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:client/secureStorage.dart';
import 'package:http/http.dart' as http;


class Savedrecipes extends StatefulWidget {
  const Savedrecipes({super.key});
  @override
  State<Savedrecipes> createState() => _SavedrecipesState();
  void setState(Null Function() param0) {}
}

class _SavedrecipesState extends State<Savedrecipes> {
  List recipes = [];
  String userId = '';
  @override
  void initState() {
    super.initState();
    fetchSavedRecipes();
  }

  Future fetchSavedRecipes() async {
    try {
      this.userId = await getUserId();
      final token = await SecureStorage().readSecureDate("jwt_token");
      print("user id$userId");
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/recipes/savedRecipes/$userId'),
        headers: {'Authorization': '$token'},
      );

      final Recipes = jsonDecode(response.body);
      if (Recipes['status'] == "success") {
        print('Saved recipes fetched successfully');
        setState(() {
          recipes = Recipes["data"]["savedRecipes"];
        });
      }

      return recipes;
    } catch (error) {
      print('Error Getting recipes: $error');
    }
  }

  Future<String> getUserId() async {
    String id = await SecureStorage().readSecureDate('userId');
    return id;
  }

  Future<void> deleteRecipe(recipeId) async {
    try {
      final token = await SecureStorage().readSecureDate("jwt_token");

      final response = await http.delete(
          Uri.parse('http://10.0.2.2:3000/recipes/$recipeId/$userId'),
          headers: {'Authorization': '$token'});
      final res = jsonDecode(response.body);
      print(res);
      if (res['status'] == "success") {
        print('Recipe Deleted successfully');
        Navigator.pushNamed(context, '/');
      } else {
        print('Error deleting recipe');
      }
    } catch (error) {
      print('Error deleting recipe: $error');
    }
  }

  Future<void> unsaveRecipe(recipeId, userId) async {
    try {

      final token = await SecureStorage().readSecureDate("jwt_token");
      final response = await http.put(
          Uri.parse('http://10.0.2.2:3000/recipes/$recipeId/$userId'),
          headers: {
            'Authorization': '$token',
          });
      final res = jsonDecode(response.body);
      if (res['status'] == "success") {
        print('Recipe UnSaved successfully');
        Navigator.pushNamed(context, '/savedRecipe');
      } else {
        print('Error unSaving recipe');
      }
    } catch (error) {
      print('Error UnSaving recipe: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved recipes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown[700],
        centerTitle: true,
      ),
      body: ListView(children: [
        const SizedBox(height: 20),
        if (recipes.isEmpty) const Center(child: Text("No Saved Recipes")),
        for (int i = 0; i < recipes.length; i++)
          Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: const EdgeInsets.all(15),
              child: Column(children: [
                Text(recipes[i]['name']),
                const SizedBox(height: 10),
                Text("Cooking Time ${recipes[i]['cookingTime']}"),
                const SizedBox(height: 10),
                const Text('the instructions'),
                const SizedBox(height: 10),
                Text(recipes[i]['instructions']),
                const SizedBox(height: 10),
                SizedBox(
                  height: 350,
                  width: 350,
                  child: Image.network(
                    recipes[i]['recipeImage'],
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 80),
                    if (this.userId != '')
                      FilledButton(
                          onPressed: () async {
                            final recipeId = recipes[i]['_id'];
                            await unsaveRecipe(recipeId, this.userId);
                          },
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text("Un Save")),
                    const SizedBox(width: 20),
                    if ((recipes[i]['userOwner']) == this.userId)
                      FilledButton(
                          onPressed: () async {
                            Navigator.pushNamed(context, '/edit');
                            await SecureStorage()
                                .writeSecureDate('recipeId', recipes[i]['_id']);
                          },
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text("Edit")),
                    const SizedBox(width: 20),
                    if ((recipes[i]['userOwner']) == this.userId)
                      FilledButton(
                          onPressed: () {
                            deleteRecipe((recipes[i]['_id']));
                          },
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text("delete")),
                  ],
                )
              ])),
      ]),
    );
  }
}
