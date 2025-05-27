class Client {
  final int? id;
  final String? ice;
  final String name;
  final String email;
  final String phone;
  final String address;
  final bool isCompagny;

    static final List<Client> _clients = [

  ];

  Client({
    this.id,
    required this.ice,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.isCompagny,
  });

  get fax => null;

  get fullName => null;

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      ice: json['ice'],
      name: json['name'],
      email: json['email'],
      phone: json['phone_number'],
      address: json['address'],
      isCompagny: json['is_company'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ice': ice,
      'name': name,
      'email': email,
      'phone_number': phone,
      'address': address,
      'is_company': isCompagny,
    };
  }

  static List<Client> getClients() {
    return _clients;
  }

  static Client getClientById(int? id) {
    return _clients.firstWhere((client) => client.id == id, orElse: () => Client.empty());
  }

  static void addClient(Client client) {
    _clients.insert(0, client);
  }

  static void removeClient(client) {
    _clients.remove(client);
  }


    static Client empty() {
    return Client(
      id: 0,
      ice: '',
      name: '',
      email: '',
      phone: '',
      address: '',
      isCompagny: false,

      // Initialize other required fields with default values
    );
  }
}