import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../manager.dart';

class Categories extends StatefulWidget {
  const Categories({
    super.key,
  });

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  TextEditingController catController = TextEditingController();

  void displayCategoryAddsUI(BuildContext context){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: catController,
                  decoration: const InputDecoration(
                    labelText: 'Category name',
                    border: OutlineInputBorder(),
                    hintText: "Enter name of new category",
                  ),
                  textCapitalization: TextCapitalization.words,
                )
              ]
            )
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel')
            ),
            TextButton(
              onPressed: () {
                context.read<Manager>().addCategory(catController.text);
                catController.clear();
                Navigator.pop(context);
              },
              child: Text('Add')
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> categoryList = Provider.of<Manager>(context, listen: true).categorySet.toList();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/CSIA_background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.deepOrangeAccent,
          title: Text(
            'Categories (${categoryList.length})',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: true,
          elevation: 2,
        ),
        body: categoryList.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No categories yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Tap the + button to add one',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: categoryList.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.category,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                ),
                title: Text(
                  categoryList[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    context.read<Manager>().deleteCategory(categoryList[index]);
                  },
                  icon: Icon(Icons.delete_outline),
                  color: Colors.grey[600],
                  splashRadius: 20,
                  tooltip: 'Delete category',
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => displayCategoryAddsUI(context),
          backgroundColor: Colors.blue,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}
