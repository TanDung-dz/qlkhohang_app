import 'dart:async';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/SanPham.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  List<SanPham> products = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        // Gọi API để lấy thông tin sản phẩm theo ID
        final productId = result.rawContent; // Giả sử mã vạch chính là ID
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/SanPham/GetById/$productId'),
        );

        if (response.statusCode == 200) {
          final productData = json.decode(response.body);
          SanPham product = SanPham.fromJson(productData);

          // Hiển thị chi tiết sản phẩm và cho phép sửa
          _showEditProductDialog(product);
        } else {
          showError('Không tìm thấy sản phẩm với mã vạch: ${result.rawContent}');
        }
      }
    } catch (e) {
      showError("Lỗi khi quét mã vạch: $e");
    }
  }


  Future<void> searchAndAddProduct(String barcode) async {
    try {
      setState(() => isLoading = true);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/SanPham/Search/$barcode'),
      );

      if (response.statusCode == 200) {
        final productData = json.decode(response.body);
        SanPham newProduct = SanPham.fromJson(productData);

        // Hiển thị chi tiết sản phẩm
        _showProductDetails(newProduct);

        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      showError('Lỗi khi tìm kiếm sản phẩm');
    }
  }



  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/SanPham/Get'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          products = data.map((json) => SanPham.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      showError('Không thể tải danh sách sản phẩm');
    }
  }

  Future<void> searchProducts(String keyword) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (keyword.isEmpty) {
        fetchProducts();
        return;
      }

      try {
        setState(() => isLoading = true);
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/SanPham/Search/$keyword'),
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            products = data.map((json) => SanPham.fromJson(json)).toList();
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() => isLoading = false);
        showError('Lỗi khi tìm kiếm sản phẩm');
      }
    });
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Icon(Icons.image_not_supported, size: 50);
    }

    if (imageUrl.startsWith('data:image')) {
      // Handle base64 image
      final String base64Image = imageUrl.split(',')[1];
      return Image.memory(
        base64Decode(base64Image),
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      );
    } else {
      // Handle URL image
      return Image.network(
        '${ApiConfig.baseUrl}$imageUrl',
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.error, size: 50),
      );
    }
  }

  void _showProductDetails(SanPham product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết sản phẩm: ${product.tenSanPham}'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // _buildImage(product.imageUrl),
              Text('Mô tả: ${product.mota}'),
              Text('Số lượng: ${product.soLuong}'),
              Text('Đơn giá: ${product.donGia} VND'),
              Text('Khối lượng: ${product.khoiLuong} kg'),
              Text('Kích thước: ${product.kichThuoc}'),
              Text('Xuất xứ: ${product.xuatXu}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }


  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final weightController = TextEditingController();  // Thêm trường khối lượng
    final sizeController = TextEditingController();  // Thêm trường kích thước
    final originController = TextEditingController();  // Thêm trường xuất xứ

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm sản phẩm mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Số lượng'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Đơn giá'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Khối lượng'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: sizeController,
                decoration: const InputDecoration(labelText: 'Kích thước'),
              ),
              TextField(
                controller: originController,
                decoration: const InputDecoration(labelText: 'Xuất xứ'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Xử lý thêm sản phẩm với các trường bổ sung
              _addProduct(
                nameController.text,
                descriptionController.text,
                int.tryParse(quantityController.text) ?? 0,
                double.tryParse(priceController.text) ?? 0.0,
                double.tryParse(weightController.text) ?? 0.0,
                sizeController.text,
                originController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }


// Phương thức thêm sản phẩm
  Future<void> _addProduct(String name, String description, int quantity, double price, double weight, String size, String origin) async {
    try {
      setState(() => isLoading = true);
      var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/api/SanPham/CreateProduct/uploadfile'),
      );

      request.fields['tenSanPham'] = name;
      request.fields['mota'] = description;
      request.fields['soLuong'] = quantity.toString();
      request.fields['donGia'] = price.toString();

      request.fields['maLoaiSanPham'] = '1'; // Adjust as needed
      request.fields['maHangSanXuat'] = '1'; // Adjust as needed

      request.fields['khoiLuong'] = weight.toString();
      request.fields['kichThuoc'] = size;
      request.fields['xuatXu'] = origin;

      var response = await request.send();

      if (response.statusCode == 201) {
        await fetchProducts();  // Tải lại danh sách sản phẩm
        showSuccess('Thêm sản phẩm thành công');
      } else {
        showError('Thêm sản phẩm thất bại');
      }
    } catch (e) {
      showError('Lỗi kết nối: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }


// Phương thức sửa sản phẩm
  void _showEditProductDialog(SanPham product) {
    final nameController = TextEditingController(text: product.tenSanPham);
    final descriptionController = TextEditingController(text: product.mota);
    final quantityController = TextEditingController(text: product.soLuong.toString());
    final priceController = TextEditingController(text: product.donGia.toString());
    final weightController = TextEditingController(text: product.khoiLuong.toString());
    final sizeController = TextEditingController(text: product.kichThuoc ?? "");
    final originController = TextEditingController(text: product.xuatXu ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa sản phẩm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Số lượng'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Đơn giá'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Khối lượng'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: sizeController,
                decoration: const InputDecoration(labelText: 'Kích thước'),
              ),
              TextField(
                controller: originController,
                decoration: const InputDecoration(labelText: 'Xuất xứ'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateProduct(
                product.maSanPham,
                nameController.text,
                descriptionController.text,
                int.tryParse(quantityController.text) ?? 0,
                double.tryParse(priceController.text) ?? 0.0,
                double.tryParse(weightController.text) ?? 0.0,
                sizeController.text,
                originController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }


  Future<void> _updateProduct(int id, String name, String description, int quantity, double price, double weight, String size, String origin) async {
    try {
      setState(() => isLoading = true);
      var request = http.MultipartRequest('PUT', Uri.parse('${ApiConfig.baseUrl}/api/SanPham/UpdateProduct/$id')

      );

      request.fields['tenSanPham'] = name;
      request.fields['mota'] = description;
      request.fields['soLuong'] = quantity.toString();
      request.fields['donGia'] = price.toString();
      request.fields['maLoaiSanPham'] = '1'; // Adjust as needed
      request.fields['maHangSanXuat'] = '1'; // Adjust as needed
      request.fields['khoiLuong'] = weight.toString();
      request.fields['kichThuoc'] = size;
      request.fields['xuatXu'] = origin;

      var response = await request.send();

      if (response.statusCode == 204) {
        await fetchProducts();
        showSuccess('Cập nhật sản phẩm thành công');
      } else {
        showError('Cập nhật sản phẩm thất bại');
      }
    } catch (e) {
      showError('Lỗi kết nối: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

// Phương thức xóa sản phẩm
  void _confirmDeleteProduct(SanPham product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa sản phẩm "${product.tenSanPham}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              deleteProduct(product.maSanPham);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteProduct(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/SanPham/DeleteProduct/$id');

    try {
      final response = await http.delete(uri);
      if (response.statusCode == 200) {
        showSuccess('Xóa sản phẩm thành công');
        fetchProducts();  // Tải lại danh sách sản phẩm
      } else {
        showError('Xóa sản phẩm thất bại');
      }
    } catch (e) {
      showError('Lỗi kết nối: $e');
    }
  }


// Thêm phương thức hiển thị thông báo thành công
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void showProductDetails(SanPham product) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.image != null)
                  Center(
                    child: _buildImage(product.image),
                  ),
                const SizedBox(height: 16),
                if (product.maVach != null)
                  Center(
                    child: Column(
                      children: [
                        _buildImage(product.maVach),
                        const Text('Mã vạch', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                _detailRow('Tên sản phẩm', product.tenSanPham),
                _detailRow('Loại sản phẩm', product.tenLoaiSanPham),
                _detailRow('Hãng sản xuất', product.tenHangSanXuat),
                _detailRow('Mô tả', product.mota),
                _detailRow('Số lượng', '${product.soLuong ?? 0}'),
                _detailRow('Đơn giá', '${product.donGia ?? 0} VNĐ'),
                _detailRow('Khối lượng', '${product.khoiLuong ?? 0} kg'),
                _detailRow('Kích thước', product.kichThuoc),
                _detailRow('Xuất xứ', product.xuatXu),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'Không có'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProductDialog, // Gọi phương thức thêm sản phẩm mới
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner), // Icon quét mã vạch
            onPressed: scanBarcode, // Gọi phương thức quét mã vạch
            tooltip: 'Quét mã vạch', // Gợi ý khi giữ icon
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: searchProducts,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? const Center(child: Text('Không tìm thấy sản phẩm'))
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: ListTile(
              leading: SizedBox(
                width: 60,
                height: 60,
                child: _buildImage(product.image),
              ),
              title: Text(product.tenSanPham ?? 'Không có tên'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loại: ${product.tenLoaiSanPham ?? 'N/A'}'),
                  Text(
                    'SL: ${product.soLuong ?? 0} - Giá: ${product.donGia ?? 0} VNĐ',
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () => showProductDetails(product),
                    tooltip: 'Xem chi tiết',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditProductDialog(product),
                    tooltip: 'Sửa sản phẩm',
                  ),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteProduct(product),
                      tooltip: 'Xóa sản phẩm'
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}