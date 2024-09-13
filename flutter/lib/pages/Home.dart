import 'dart:convert';
import 'package:client/Styled_button.dart';
import 'package:flutter/material.dart';
import 'package:client/secureStorage.dart';
import 'package:http/http.dart' as http;


class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
  void setState(Null Function() param0) {}
}

class _HomeState extends State<Home> {
  List recipes = [];
  String userId = '';
  @override
  void initState() {
    super.initState();
    fetchAllRecipes();
  }

  Future fetchAllRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/recipes/'),
      );

      final Recipes = jsonDecode(response.body);
      if (Recipes['status'] == "success") {
        print('Recipe getting is succeseded');
      }
      setState(() {
        recipes = Recipes["data"]["recipes"];
      });

      this.userId = await getUserId();
      return recipes;
    } catch (error) {
      print('Error Getting recipes: $error');
    } finally {}
  }

  Future<String> getUserId() async {
    String id = await SecureStorage().readSecureDate('userId');
    return id;
  }

  void Logout() async {
    await SecureStorage().deleteSecureData('jwt_token');
    await SecureStorage().deleteSecureData('userId');
    this.userId = "";
    Navigator.pushNamed(context, '/login');
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

  Future<void> saveRecipe(recipeId, userId) async {
    try {
      final body = {
        'recipeId': recipeId,
        'userId': userId,
      };
      final token = await SecureStorage().readSecureDate("jwt_token");
      final response = await http.put(
          Uri.parse('http://10.0.2.2:3000/recipes/'),
          headers: {
            'Authorization': '$token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode(body));
      final res = jsonDecode(response.body);
      print("______________$res");
      if (res['status'] == "success") {
        print('Recipe saved successfully');
        Navigator.pushNamed(context, '/savedRecipe');
      } else {
        print('Error saving recipe');
      }
    } catch (error) {
      print('Error saving recipe: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipes App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown[700],
        centerTitle: true,
        actions: [
          StyledButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Login')),
          StyledButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Register')),
          StyledButton(onPressed: Logout, child: const Text('Logout')),
        ],
      ),
      body: ListView(children: [
        Row(
          children: [
            if (this.userId != '')
              FilledButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/savedRecipe');
                  },
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("saved Recipes")),
            const SizedBox(width: 20),
            if (this.userId != '')
              FilledButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/CreateRecipe');
                  },
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Create Recipe")),
          ],
        ),
        const SizedBox(height: 20),
        for (int i = 0; i < recipes.length; i++)
          Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: EdgeInsets.all(15),
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
                          onPressed: () {
                            final recipeId = recipes[i]['_id'];
                            saveRecipe(recipeId, this.userId);
                          },
                          child: Text("save"),
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.green)),
                    const SizedBox(width: 20),
                    if ((recipes[i]['userOwner']) == this.userId)
                      FilledButton(
                          onPressed: () async {
                            Navigator.pushNamed(context, '/edit');
                            await SecureStorage()
                                .writeSecureDate('recipeId', recipes[i]['_id']);
                          },
                          child: Text("Edit"),
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.blue)),
                    const SizedBox(width: 20),
                    if ((recipes[i]['userOwner']) == this.userId)
                      FilledButton(
                          onPressed: () async {
                            await deleteRecipe((recipes[i]['_id']));
                          },
                          child: Text("delete"),
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red)),
                  ],
                )
              ])),
      ]),
    );
  }
}
