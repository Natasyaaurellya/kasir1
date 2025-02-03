import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'riwayat.dart';

class PenjualanScreen extends StatefulWidget {
  @override
  _PenjualanScreenState createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> foodItems = [];
  List<Map<String, dynamic>> pelanggan = [];
  Map<String, dynamic>? selectedFoodItem;
  Map<String, dynamic>? selectedMember;
  List<Map<String, dynamic>> cart = [];
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
    _fetchpelanggan();
  }

  Future<void> _fetchFoodItems() async {
    try {
      final response = await supabase.from('produk').select();
      setState(() => foodItems = List<Map<String, dynamic>>.from(response));
    } catch (error) {
      _showSnackBar('Error fetching food items: $error');
    }
  }

  Future<void> _fetchpelanggan() async {
    try {
      final response = await supabase.from('pelanggan').select();
      setState(() => pelanggan = List<Map<String, dynamic>>.from(response));
    } catch (error) {
      _showSnackBar('Error fetching pelanggan: $error');
    }
  }

  void _addToCart() {
    if (selectedFoodItem != null) {
      setState(() {
        cart.add({...selectedFoodItem!, 'quantity': 1});
        totalPrice += selectedFoodItem!['harga'];
      });
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      totalPrice -= cart[index]['harga'] * cart[index]['quantity'];
      cart.removeAt(index);
    });
  }

  void _incrementQuantity(int index) {
    setState(() {
      cart[index]['quantity']++;
      totalPrice += cart[index]['harga'];
    });
  }

  void _decrementQuantity(int index) {
    if (cart[index]['quantity'] > 1) {
      setState(() {
        cart[index]['quantity']--;
        totalPrice -= cart[index]['harga'];
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _logout() async {
    try {
      await supabase.auth.signOut();
      _showSnackBar('Logged out successfully');
    } catch (error) {
      _showSnackBar('Error logging out: $error');
    }
  }

  Future<void> _addTransaction() async {
    try {
      final response = await supabase.from('penjualan').insert({
        'pelanggan_id': selectedMember!['pelanggan_id'],
        'total_harga': totalPrice,
        'tanggal_penjualan': DateTime.now().toIso8601String(),
      });
      _showSnackBar('Transaction added successfully!');
      setState(() {
        cart.clear();
        totalPrice = 0.0;
      });
    } catch (error) {
      _showSnackBar('Error completing transaction: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Penjualan"),
        backgroundColor: const Color(0xff215470),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color.fromARGB(255, 9, 9, 9)),
            onPressed: _logout, // Logout ketika tombol ditekan
          
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Food Item'),
            DropdownButton<Map<String, dynamic>>(
              value: selectedFoodItem,
              hint: const Text('Select Food Item'),
              isExpanded: true,
              onChanged: (item) {
                setState(() {
                  selectedFoodItem = item;
                });
              },
              items: foodItems.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item['nama_produk']),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Select Member'),
            DropdownButton<Map<String, dynamic>>(
              value: selectedMember,
              hint: const Text('Select Member'),
              isExpanded: true,
              onChanged: (item) {
                setState(() {
                  selectedMember = item;
                });
              },
              items: pelanggan.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item['nama_pelanggan']),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addToCart,
              child: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff215470)),
            ),
            const SizedBox(height: 16),
            const Text('Cart:'),
            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return ListTile(
                    title: Text(item['nama_produk']),
                    subtitle: Text("Price: ${item['harga']} x ${item['quantity']} = ${item['harga'] * item['quantity']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () => _decrementQuantity(index),
                        ),
                        Text(item['quantity'].toString()),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () => _incrementQuantity(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeFromCart(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp. ${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (cart.isNotEmpty) {
                  _showSnackBar('Transaction completed!');
                  _addTransaction();
                } else {
                  _showSnackBar('Please select a member and add items to the cart.');
                }
              },
              child: const Text('Complete Transaction'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff215470)),
            ),
          ],
        ),
      ),
    );
  }
}
