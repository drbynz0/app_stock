import 'package:flutter/material.dart';
import '/controller/category_controller.dart';
import '/models/category.dart';
import 'add_categorie_screen.dart';
import 'edit_categorie_screen.dart';
import 'categorie_detail_screen.dart';
import 'delete_confirmation_dialog.dart';

class CategorieScreen extends StatefulWidget {
  const CategorieScreen({super.key});

  @override
  State<CategorieScreen> createState() => _CategorieScreenState();
}

class _CategorieScreenState extends State<CategorieScreen> {
  late Future<List<Category>> _futureCategories;
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _allCategories
          .where((cat) => cat.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void _loadCategories() {
    setState(() {
      _futureCategories = CategoryController.fetchCategories();
    });

    _futureCategories.then((cats) {
      setState(() {
        _allCategories = cats;
        _filteredCategories = cats;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Catégories',
         style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Color(0xFF003366),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Category>>(
        future: _futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une catégorie...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => showAddCategorieDialog(context, _loadCategories),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Ajouter",
                       style: TextStyle(color: Colors.white),
                       ),
                  
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF004A99),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final categorie = _filteredCategories[index];
                    return Card(
                      color: const Color.fromARGB(255, 194, 224, 240),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: const  Color(0xFF004A99),
                          
                          child: Text(categorie.name[0].toUpperCase(),
                           style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),),
                          
                        ),
                        title: Text(
                          categorie.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        
                        subtitle: Text(categorie.description ?? ''),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategorieDetailScreen(categorie: categorie),
                            ),
                          );
                        },              
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => showEditCategorieDialog(context, categorie, _loadCategories),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDeleteConfirmationDialog(context, categorie, _loadCategories),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }


}
