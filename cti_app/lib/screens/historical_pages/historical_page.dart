import 'package:cti_app/models/activity.dart';
import 'package:cti_app/services/app_data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HistoricalPage extends StatefulWidget {
  const HistoricalPage({super.key});

  @override
  State<HistoricalPage> createState() => _HistoricalPageState();
}

class _HistoricalPageState extends State<HistoricalPage> {
  String _searchKeyword = "";
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy à HH:mm');

  @override
  Widget build(BuildContext context) {
    final activities = Provider.of<AppData>(context).activities;
    final filteredActivities = activities
        .where((a) => a.description.toLowerCase().contains(_searchKeyword.toLowerCase()))
        .toList()
        .toList();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("Historique des activités"),
      ),
      body: Column(
        children: [
          // Barre de recherche
          _buildSearchBar(),
          // Statistiques rapides
          _buildStatsHeader(filteredActivities.length),
          // Liste des activités
          Expanded(
            child: filteredActivities.isEmpty
                ? _buildEmptyState()
                : _buildActivitiesList(filteredActivities),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Rechercher une activité...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
        onChanged: (val) => setState(() => _searchKeyword = val),
      ),
    );
  }

  Widget _buildStatsHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$count activité${count > 1 ? 's' : ''}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (count > 0)
            TextButton(
              onPressed: () {
                Provider.of<AppData>(context, listen: false).deleteAllActivities();
                setState(() {});
              },
              child: const Text(
                "Tout effacer",
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            "Aucune activité enregistrée",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchKeyword.isEmpty
                ? "Vos actions apparaîtront ici"
                : "Aucun résultat pour '$_searchKeyword'",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(List<Activity> activities) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityItem(activity);
      },
    );
  }

  Widget _buildActivityItem(Activity activity) {
    final isStaff = Provider.of<AppData>(context).userData!['is_staff'] ?? false;
    
    return Dismissible(
      key: Key(activity.id.toString()),
      direction: isStaff ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirmer la suppression"),
            content: const Text("Voulez-vous vraiment supprimer cette activité ?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<AppData>(context, listen: false).deleteActivity(activity.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Activité supprimée"),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getActivityColor(activity),
            shape: BoxShape.circle,
          ),
          child: Icon(
            activity.icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          activity.description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          _dateFormat.format(activity.timestamp),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: isStaff
            ? IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: Colors.grey,
                onPressed: () {
                  Provider.of<AppData>(context, listen: false)
                      .deleteActivity(activity.id!);
                  setState(() {});
                },
              )
            : null,
      ),
    );
  }

  Color _getActivityColor(Activity activity) {
    switch (activity.iconName) {
      case 'add':
        return Colors.green;
      case 'edit':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}