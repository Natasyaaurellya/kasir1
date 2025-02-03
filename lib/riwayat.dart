import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  @override
  _PurchaseHistoryScreenState createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> with SingleTickerProviderStateMixin {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> purchaseHistory = [];
  late TabController _tabController; // Controller untuk TabBar

  @override
  void initState() {
    super.initState();
    _fetchPurchaseHistory();
    _tabController = TabController(length: 4, vsync: this); // 4 Tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mengambil data dari tabel detail_penjualan
  Future<void> _fetchPurchaseHistory() async {
    try {
      final response = await supabase
          .from('detail_penjualan')
          .select('*, penjualan(order_id, tanggal, total_harga, metode_pembayaran)')
          .order('created_at', ascending: false);

      setState(() {
        purchaseHistory = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      _showSnackBar('Error fetching purchase history: $error');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase History'),
        backgroundColor: const Color(0xff215470),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Transactions'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
          onTap: (index) {
            // Navigasi antar halaman bisa ditambahkan di sini
          },
        ),
      ),
      body: purchaseHistory.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: purchaseHistory.length,
              itemBuilder: (context, index) {
                final purchase = purchaseHistory[index];
                return ListTile(
                  title: Text('Order ID: ${purchase['penjualan']['order_id']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${purchase['penjualan']['tanggal']}'),
                      Text('Total: Rp. ${purchase['penjualan']['total_harga']}'),
                      Text('Payment Method: ${purchase['penjualan']['metode_pembayaran']}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info, color: Colors.blue),
                    onPressed: () {
                      _showOrderDetails(purchase);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> purchase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order ID: ${purchase['penjualan']['order_id']}'),
            Text('Date: ${purchase['penjualan']['tanggal']}'),
            Text('Total: Rp. ${purchase['penjualan']['total_harga']}'),
            Text('Payment Method: ${purchase['penjualan']['metode_pembayaran']}'),
            const SizedBox(height: 10),
            const Text('Ordered Items:'),
            Text('Product ID: ${purchase['produk_id']}'),
            Text('Quantity: ${purchase['jumlah_produk']}'),
            Text('Subtotal: Rp. ${purchase['subtotal']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
