// ignore_for_file: use_build_context_synchronously
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cti_app/controller/login_controller.dart';
import 'package:cti_app/screens/chat_assistant_page/chat_assistant.dart';
import 'package:cti_app/screens/historical_pages/historical_page.dart';
import 'package:cti_app/screens/settings_pages/profile_screen.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:cti_app/models/sale_record.dart';
import 'produits_pages/product_managment_screen.dart';
import 'transactions_pages/transactions_screen.dart';
import 'client_pages/client_management_screen.dart';
import 'plus_pages/more_options_screen.dart';
import 'settings_pages/settings_screen.dart';
import '../models/internal_order.dart';
import '/models/external_order.dart';
import '../widgets/order_stats_charts.dart';
import 'package:provider/provider.dart';
import '../services/app_data_service.dart';
//import 'notification_pages/notification_screen.dart';
import '/services/activity_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 2;
  late final List<Widget> _pages;
  List<InternalOrder> internalOrders = [];
  List<ExternalOrder> externalOrders = [];
  Map<String, dynamic>? userData;
   late List<ExternalOrderRecord> externalOrderRecords;
   late List<InternalOrderRecord> internalOrderRecords;
  late List<SaleRecord> _allRecords;
  // int _unreadNotificationsCount = 3;

  @override
  void initState() {
  
    super.initState();
    _pages = [
      const TransactionsScreen(),
      const ClientManagementScreen(),
      _buildHomePage(),
      const ProductManagementScreen(),
      const MoreOptionsScreen(),
    ];
    didChangeDependencies();

  }

  Future<void> _refreshOption() async {
    final appData = Provider.of<AppData>(context, listen: false);
    await appData.fetchUserData();
    Future.microtask(() async {
      //appData.refreshDataService(context);
      final activityService = Provider.of<ActivityService>(context, listen: false);
      await activityService.fetchActivities();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshOption();
  }

  Widget _buildHomePage() {
    return Consumer<AppData>(
      
      builder: (context, appData, child) {
        userData = appData.userData;
        if (userData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitFadingCircle(
                  color: Theme.of(context).primaryColor,
                  size: 50.0,
                ),
                const SizedBox(height: 20),
                Text(
                  'Chargement des données...',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
          
        final theme = Provider.of<ThemeProvider>(context);
        internalOrders = appData.internalOrders;
        externalOrders = appData.externalOrders;
        // Vérification si les données sont en cours de chargement
        if (appData.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpinKitDoubleBounce(
                  color: theme.textColor,
                  size: 50.0,
                ),
                const SizedBox(height: 20),
                Text(
                  'Mise à jour des données...',
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        final int totalExternalOrders = appData.externalOrders.length;
        final int totalSuppliers = appData.suppliers.length;
        final int totalClients = appData.clients.length;
        final double chiffreAffairePaid = appData.externalOrders.fold(
          0,
          (sum, order) => sum + order.paidPrice
        );
        _allRecords = [
          ...internalOrders.map((o) => InternalOrderRecord(o)),
          ...externalOrders.map((o) => ExternalOrderRecord(o)),
        ];
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Statistiques",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.titleColor,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDashboardCard(
                    icon: Icons.show_chart,
                    label: "Chiffre d'affaire",
                    value: userData!['is_admin'] == true ? chiffreAffairePaid.toStringAsFixed(2) : "******",
                    valueColor: Color.fromARGB(255, 36, 89, 71),
                    backgroundColor: const Color.fromARGB(128, 98, 241, 193),
                  ),
                  _buildDashboardCard(
                    icon: Icons.attach_money,
                    label: "Achat",
                    value: totalExternalOrders.toString(),
                    valueColor: Color.fromARGB(255, 108, 176, 224),
                    backgroundColor: const Color.fromARGB(128, 136, 195, 237),
                  ),
                  _buildDashboardCard(
                    icon: Icons.inventory,
                    label: "Fournisseurs",
                    value: totalSuppliers.toString(),
                    valueColor: Color.fromARGB(255, 87, 189, 184),
                    backgroundColor: const Color.fromARGB(128, 96, 220, 212),
                  ),
                  _buildDashboardCard(
                    icon: Icons.group,
                    label: "Clients",
                    value: totalClients.toString(),
                    valueColor: Color.fromARGB(255, 115, 223, 147),
                    backgroundColor: const Color.fromARGB(128, 125, 240, 159),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                "Graphiques",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.titleColor,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: MonthlySalesChart(records: _allRecords,),
              ),
              const SizedBox(height: 32),
              Text(
                "Activités récentes",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.titleColor,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<ActivityService>(
                builder: (context, activityService, _) {
                  final activities = activityService.recentActivities;

                  if (activities.isEmpty) {
                    return const Text("Aucune activité récente.");
                  }

                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Icon(activity.icon, color: theme.iconColor),
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
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HistoricalPage()),
                            );
                          },
                          icon: Icon(Icons.arrow_forward, color: theme.textColor),
                          label: Text("Afficher plus", 
                            style: TextStyle(fontSize: 16, color: theme.textColor),
                          ),
                        ),
                      ),
                    ]
                  );
                   
                },
              )

            ],
          ),
        );
      }
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    required Color backgroundColor,
  }) {
    final theme = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: theme.iconColor),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: theme.titleColor,
              fontSize: 16,
              fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 22),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 30),
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 10),
            const Text(
              'CTI Technologie',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
            ),
          ],
        ),
       /* actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationScreen()),
                  ).then((_) {
                    // Quand on revient de la page de notifications, on peut mettre à jour le compteur
                    setState(() {
                      _unreadNotificationsCount = 0;
                    });
                  });
                },
              ), 
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      _unreadNotificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ], */
      ),
      drawer: Drawer(
        backgroundColor: theme.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 145, 193, 214),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/image/welcome.png',
                    width: 130,
                    height: 130,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            //Historique des transactions
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoricalPage()),
                );
              },
            ),
           
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('CTI Assistant'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatAssistantScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                AuthController.logout().then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Déconnexion réussie'), backgroundColor: Colors.green,),
                  );
                });
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.barNavColor,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: theme.iconColor,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Color(0xFF003366),
              child: Icon(Icons.home, color: Colors.white),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Plus',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}