import 'package:cti_app/services/activity_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoricalPage extends StatefulWidget {
  const HistoricalPage({super.key});

  @override
  State<HistoricalPage> createState() => _HistoricalPageState();
}

class _HistoricalPageState extends State<HistoricalPage> {
  String _searchKeyword = "";

  @override
  Widget build(BuildContext context) {
    final activities = Provider.of<ActivityService>(context).allActivities;
    final filtered = activities.where((a) =>
      a.description.toLowerCase().contains(_searchKeyword.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Toutes les activités")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Filtrer par description...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _searchKeyword = val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final activity = filtered[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: Icon(activity.icon),
                    title: Text(activity.description),
                    subtitle: Text(
                      '${activity.timestamp.day}/${activity.timestamp.month}/${activity.timestamp.year} - '
                      '${activity.timestamp.hour}:${activity.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
