import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pelanggan.dart';
import 'penjualan.dart';
import 'login.dart';
import 'riwayat.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    FoodMenuScreen(),
    PenjualanScreen(),
    PelangganScreen(),
    PurchaseHistoryScreen(), // Halaman riwayat pembelian
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'), // Ikon riwayat pembelian
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff215470), // Warna biru seperti AppBar
        unselectedItemColor: Colors.grey, // Warna ikon yang tidak dipilih
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class FoodMenuScreen extends StatefulWidget {
  @override
  _FoodMenuScreenState createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends State<FoodMenuScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> foodItems = [];

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  Future<void> _fetchFoodItems() async {
    try {
      final response = await supabase.from('produk').select();
      setState(() => foodItems = List<Map<String, dynamic>>.from(response));
    } catch (error) {
      _showSnackBar('Error fetching food items: $error');
    }
  }

  Future<void> _modifyFoodItem(Map<String, dynamic> data, {int? produkId}) async {
    try {
      if (produkId == null) {
        await supabase.from('produk').insert(data);
      } else {
        await supabase.from('produk').update(data).eq('produk_id', produkId);
      }
      _fetchFoodItems();
      _showSnackBar(produkId == null ? "Food item added successfully!" : "Food item updated successfully!");
    } catch (error) {
      _showSnackBar('Error saving food item: $error');
    }
  }

  Future<void> _deleteFoodItem(int produkId) async {
    try {
      await supabase.from('produk').delete().eq('produk_id', produkId);
      _fetchFoodItems();
      _showSnackBar('Food item deleted successfully!');
    } catch (error) {
      _showSnackBar('Error deleting food item: $error');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Menu'),
        backgroundColor: const Color(0xff215470),
        centerTitle: true,
        automaticallyImplyLeading: false, // Menghapus panah kiri
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color.fromARGB(255, 13, 13, 13)),
            onPressed: _showLogoutDialog, // Tampilkan dialog konfirmasi logout
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          final item = foodItems[index];
          return ListTile(
            title: Text(item['nama_produk']),
            subtitle: Text("Price: Rp. ${item['harga']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditDialog(item);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteFoodItem(item['produk_id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to add new food item
        },
        backgroundColor: const Color(0xff215470),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Dialog untuk mengedit makanan
  void _showEditDialog(Map<String, dynamic> item) {
    final TextEditingController nameController = TextEditingController(text: item['nama_produk']);
    final TextEditingController priceController = TextEditingController(text: item['harga'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Food Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Food Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedData = {
                'nama_produk': nameController.text,
                'harga': double.tryParse(priceController.text) ?? 0.0,
              };
              _modifyFoodItem(updatedData, produkId: item['produk_id']);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Dialog konfirmasi logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog tanpa logout
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _logout();
              Navigator.pop(context); // Tutup dialog setelah logout
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
  // Fungsi untuk melakukan logout
  void _logout() async {
    try {
      await supabase.auth.signOut();
      _showSnackBar('Logged out successfully');
      // Navigasi ke halaman login, bisa menggunakan Navigator.pushReplacement
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Ganti LoginScreen dengan widget login Anda
      );
    } catch (error) {
      _showSnackBar('Error logging out: $error');
    }
  }
}

// Halaman Riwayat Pembelian
class PurchaseHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase History')),
      body: Center(child: const Text('Halaman Riwayat Pembelian')),
    );
  }
}
