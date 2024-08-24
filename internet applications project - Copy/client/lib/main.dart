import 'package:client/pages/Home.dart';
import 'package:client/pages/CreateRecipe.dart';
import 'package:client/pages/EditRecipe.dart';
import 'package:client/pages/login.dart';
import 'package:client/pages/Register.dart';
import 'package:client/pages/SavedRecipes.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/CreateRecipe': (context) => Createrecipe(),
        '/edit': (context) => Editrecipe(),
        '/savedRecipe': (context) => Savedrecipes()
      },
    ),
  );
}
