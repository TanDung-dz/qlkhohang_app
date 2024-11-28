import 'package:flutter/material.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _initializeProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeProducts() {
    // Tạo dữ liệu mẫu cho danh sách sản phẩm
    _products = List.generate(
      10,
          (index) => {
        'id': index + 1,
        'name': 'Sản phẩm ${index + 1}',
        'quantity': (index + 1) * 10,
      },
    );
    _filteredProducts = List.from(_products);
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products
          .where((product) =>
      product['name'].toLowerCase().contains(query) ||
          product['id'].toString().contains(query))
          .toList();
    });
  }

  void _showAddEditDialog({Map<String, dynamic>? product}) {
    final TextEditingController nameController = TextEditingController(
        text: product != null ? product['name'] : '');
    final TextEditingController quantityController = TextEditingController(
        text: product != null ? product['quantity'].toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Số lượng'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text;
                final int quantity = int.tryParse(quantityController.text) ?? 0;

                if (name.isEmpty || quantity <= 0) {
                  return;
                }

                setState(() {
                  if (product == null) {
                    // Thêm sản phẩm mới
                    _products.add({
                      'id': _products.length + 1,
                      'name': name,
                      'quantity': quantity,
                    });
                  } else {
                    // Sửa sản phẩm
                    product['name'] = name;
                    product['quantity'] = quantity;
                  }
                  _filterProducts();
                });

                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(Map<String, dynamic> product) {
    setState(() {
      _products.remove(product);
      _filterProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory),
                  ),
                  title: Text(product['name']),
                  subtitle: Text('Số lượng: ${product['quantity']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddEditDialog(product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProduct(product),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
