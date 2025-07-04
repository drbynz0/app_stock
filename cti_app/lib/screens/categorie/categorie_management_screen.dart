import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cti_app/services/app_data_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
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
  final TextEditingController _searchController = TextEditingController();
  List<Category> _filteredCategories = [];
  Map<String, dynamic>? myPrivileges = {};
  Map<String, dynamic>? userData = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOption());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadOption();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final appData = Provider.of<AppData>(context, listen: false);
    setState(() {
      _filteredCategories = appData.categories
          .where((cat) => (cat.name).toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _loadOption() async {
    final appData = Provider.of<AppData>(context, listen: false);
    appData.refreshData();

    if (mounted) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        myPrivileges = appData.myPrivileges;
        userData = appData.userData;
        _filteredCategories = query.isEmpty
            ? appData.categories
            : appData.categories
                .where((cat) => (cat.name).toLowerCase().contains(query))
                .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des Catégories',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher une catégorie...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if ((userData?['is_staff'] ?? false) ||
                    (myPrivileges?['add_category'] ?? false))
                  ElevatedButton.icon(
                    onPressed: () async {
                      await showAddCategorieDialog(context, _loadOption);
                      await _loadOption();
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Ajouter",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.buttonColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AppData>(
              builder: (context, appData, child) {
                final query = _searchController.text.toLowerCase();
                _filteredCategories = query.isEmpty
                    ? appData.categories
                    : appData.categories
                        .where((cat) =>
                            (cat.name).toLowerCase().contains(query))
                        .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final categorie = _filteredCategories[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF004A99),
                          child: Text(
                            (categorie.name.isNotEmpty
                                    ? categorie.name[0]
                                    : '?')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          categorie.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(categorie.description ?? ''),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategorieDetailScreen(
                                categorie: categorie,
                              ),
                            ),
                          );
                          await _loadOption();
                        },
                        trailing: ((userData?['is_staff'] ?? false) ||
                                (myPrivileges?['edit_category'] ?? false) ||
                                (myPrivileges?['delete_category'] ?? false))
                            ? Wrap(
                                spacing: 8,
                                children: [
                                  if ((userData?['is_staff'] ?? false) ||
                                      (myPrivileges?['edit_category'] ??
                                          false))
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        await showEditCategorieDialog(
                                            context, categorie, _loadOption);
                                        await _loadOption();
                                      },
                                    ),
                                  if ((userData?['is_staff'] ?? false) ||
                                      (myPrivileges?['delete_category'] ??
                                          false))
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        await showDeleteConfirmationDialog(
                                            context, categorie, _loadOption);
                                        await _loadOption();
                                      },
                                    ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
