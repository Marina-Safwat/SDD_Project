import 'package:flutter/material.dart';
import 'package:smp/services/category_operations.dart';
import 'package:smp/models/category.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  Widget createCategory(Category category) {
    return Container(
      color: Color.fromARGB(255, 243, 196, 215),
      child: Row(
        children: [
          Image.network(
            category.imageURL,
            fit: BoxFit.cover,
          ), // Added missing comma
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              category.name, // Fixed: removed .style
              style: TextStyle(
                  color: Colors.white), // Fixed: added style parameter
            ),
          )
        ],
      ),
    ); // Added missing semicolon
  }

  List<Widget> createListOfCategories() {
    List<Category> categoryList = CategoryOperations.getCategories();
    //convert data to widget using map functions
    List<Widget> categories = categoryList
        .map((Category category) => createCategory(category))
        .toList();
    return categories;
  }
  // Widget createMusic (String label){}

  Widget createGrid() {
    return Container(
      padding: EdgeInsets.all(10),
      height: 400,
      child: GridView.count(
        childAspectRatio: 5 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: createListOfCategories(),
      ),
    );
  }

  Widget createAppBar(String message) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      title: Text(message),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(Icons.person),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: Column(
        children: [
          createAppBar('Good Morning'),
          SizedBox(
            height: 5,
          ),
          createGrid(),
        ],
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blueGrey.shade100, Color(0xFFC34B7C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.1, 0.3])),
      // color: Colors.red,
    ));
  }
}
