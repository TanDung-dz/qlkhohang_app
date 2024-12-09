import 'dart:async';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../../config/api_config.dart';
import '../../models/SanPham.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


XFile? selectedImage;
class InventoryTab extends StatefulWidget {
  const InventoryTab({Key? key}) : super(key: key);

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  // Các biến dropdown
  String? selectedLoaiSanPham; // Lựa chọn loại sản phẩm
  String? selectedHangSanXuat; // Lựa chọn hãng sản xuất
  String? selectedNhaCungCap; // Lựa chọn nhà cung cấp

  List<Map<String, String>> loaiSanPhamList = []; // Danh sách loại sản phẩm
  List<Map<String, String>> hangSanXuatList = []; // Danh sách hãng sản xuất
  List<Map<String, String>> nhaCungCapList = []; // Danh sách nhà cung cấp



  List<SanPham> products = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchDropdownData();
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
        final productId = result.rawContent;
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/SanPham/GetById/$productId'),
        );

        if (response.statusCode == 200) {
          final productData = json.decode(response.body);
          SanPham product = SanPham.fromJson(productData);
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
        final List<dynamic>? data = json.decode(response.body);
        setState(() {
          products = data != null
              ? data.map((json) => SanPham.fromJson(json)).toList()
              : [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        showError('Không thể tải danh sách sản phẩm');
      }
    } catch (e) {
      setState(() => isLoading = false);
      showError('Không thể tải danh sách sản phẩm: $e');
    }
  }
  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      showError('Ứng dụng cần quyền truy cập camera để sử dụng chức năng này.');
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
      final String base64Image = imageUrl.split(',')[1];
      return Image.memory(
        base64Decode(base64Image),
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        '$imageUrl',
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, size: 50, color: Colors.red);
        },
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

  XFile? selectedImage;

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    // Hiển thị trạng thái loading nếu cần (không bắt buộc)
    setState(() {
      selectedImage = null; // Đặt về null trước khi xử lý ảnh mới
    });

    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        selectedImage = image; // Cập nhật ngay lập tức khi ảnh được chọn
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Chụp ảnh bằng camera'),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Chọn ảnh từ thư viện'),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.gallery);
            },
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
    final weightController = TextEditingController();
    final sizeController = TextEditingController();
    final originController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm sản phẩm mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nút chọn ảnh
              ElevatedButton.icon(
                onPressed: _showImagePickerOptions,
                icon: const Icon(Icons.image),
                label: const Text('Chọn ảnh'),
              ),
              if (selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(
                        File(selectedImage!.path),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            selectedImage = null; // Xóa ảnh đã chọn
                          });
                        },
                      ),
                    ],
                  ),
                ),
              // Dropdown Loại sản phẩm
              DropdownButtonFormField<String>(
                value: selectedLoaiSanPham,
                decoration: const InputDecoration(labelText: 'Loại sản phẩm'),
                items: loaiSanPhamList.isNotEmpty
                    ? loaiSanPhamList.map((loai) {
                  return DropdownMenuItem<String>(
                    value: loai['id'],
                    child: Text(loai['name'] ?? ''),
                  );
                }).toList()
                    : [DropdownMenuItem<String>(value: null, child: Text('Đang tải...'))],
                onChanged: loaiSanPhamList.isNotEmpty
                    ? (value) {
                  setState(() {
                    selectedLoaiSanPham = value;
                  });
                }
                    : null,
              ),
              const SizedBox(height: 16),
              // Dropdown Hãng sản xuất
              DropdownButtonFormField<String>(
                value: selectedHangSanXuat,
                decoration: const InputDecoration(labelText: 'Hãng sản xuất'),
                items: hangSanXuatList.isNotEmpty
                    ? hangSanXuatList.map((hang) {
                  return DropdownMenuItem<String>(
                    value: hang['id'],
                    child: Text(hang['name'] ?? ''),
                  );
                }).toList()
                    : [DropdownMenuItem<String>(value: null, child: Text('Đang tải...'))],
                onChanged: hangSanXuatList.isNotEmpty
                    ? (value) {
                  setState(() {
                    selectedHangSanXuat = value;
                  });
                }
                    : null,
              ),
              const SizedBox(height: 16),
              // Dropdown Nhà cung cấp
              DropdownButtonFormField<String>(
                value: selectedNhaCungCap,
                decoration: const InputDecoration(labelText: 'Nhà cung cấp'),
                items: nhaCungCapList.isNotEmpty
                    ? nhaCungCapList.map((ncc) {
                  return DropdownMenuItem<String>(
                    value: ncc['id'],
                    child: Text(ncc['name'] ?? ''),
                  );
                }).toList()
                    : [DropdownMenuItem<String>(value: null, child: Text('Đang tải...'))],
                onChanged: nhaCungCapList.isNotEmpty
                    ? (value) {
                  setState(() {
                    selectedNhaCungCap = value;
                  });
                }
                    : null,
              ),
              const SizedBox(height: 16),
              // Các trường nhập liệu khác
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên sản phẩm')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Mô tả')),
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
              TextField(controller: sizeController, decoration: const InputDecoration(labelText: 'Kích thước')),
              TextField(controller: originController, decoration: const InputDecoration(labelText: 'Xuất xứ')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Xử lý gửi dữ liệu
              var request = http.MultipartRequest(
                'POST',
                Uri.parse('${ApiConfig.baseUrl}/api/SanPham/CreateProduct/uploadfile'),
              );
              request.fields['TenSanPham'] = nameController.text;
              request.fields['Mota'] = descriptionController.text;
              request.fields['SoLuong'] = quantityController.text;
              request.fields['DonGia'] = priceController.text;
              request.fields['KhoiLuong'] = weightController.text;
              request.fields['KichThuoc'] = sizeController.text;
              request.fields['XuatXu'] = originController.text;
              request.fields['MaLoaiSanPham'] = selectedLoaiSanPham ?? '1';
              request.fields['MaHangSanXuat'] = selectedHangSanXuat ?? '1';
              request.fields['MaNhaCungCap'] = selectedNhaCungCap ?? '1';

              // Thêm ảnh vào request
              if (selectedImage != null) {
                request.files.add(await http.MultipartFile.fromPath(
                  'Images',
                  selectedImage!.path,
                ));
              }

              var response = await request.send();
              if (response.statusCode == 201) {
                fetchProducts(); // Load lại danh sách sản phẩm

                // Reset tất cả các trường nhập liệu và dropdown
                setState(() {
                  nameController.clear();
                  descriptionController.clear();
                  quantityController.clear();
                  priceController.clear();
                  weightController.clear();
                  sizeController.clear();
                  originController.clear();
                  selectedLoaiSanPham = null;
                  selectedHangSanXuat = null;
                  selectedNhaCungCap = null;
                  selectedImage = null;
                });

                // Đóng dialog hoặc hiển thị thông báo thành công
                showSuccess('Thêm sản phẩm thành công');
                Navigator.pop(context);
              } else {
                showError('Thêm sản phẩm thất bại');
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

// Phương thức thêm sản phẩm
  Future<void> _addProduct(
      String name,
      String description,
      int quantity,
      double price,
      double weight,
      String size,
      String origin,
      List<XFile>? selectedImages,
      ) async {
    try {
      setState(() => isLoading = true);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/SanPham/CreateProduct/uploadfile'),
      );

      request.fields['tenSanPham'] = name;
      request.fields['mota'] = description;
      request.fields['soLuong'] = quantity.toString();
      request.fields['donGia'] = price.toString();
      request.fields['khoiLuong'] = weight.toString();
      request.fields['kichThuoc'] = size;
      request.fields['xuatXu'] = origin;

      // Thêm danh sách ảnh vào yêu cầu
      if (selectedImages != null) {
        for (var image in selectedImages) {
          request.files.add(await http.MultipartFile.fromPath(
            'Images',
            image.path,
          ));
        }
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        await fetchProducts();
        showSuccess('Thêm sản phẩm thành công');
      } else {
        showError('Thêm sản phẩm thất bại: ${response.reasonPhrase}');
      }
    } catch (e) {
      showError('Lỗi khi thêm sản phẩm: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

// Phương thức sửa sản phẩm
  void _showEditProductDialog(SanPham product) {
    final nameController = TextEditingController(text: product.tenSanPham);
    final descriptionController = TextEditingController(text: product.mota);
    final quantityController = TextEditingController(text: product.soLuong?.toString());
    final priceController = TextEditingController(text: product.donGia?.toString());
    final weightController = TextEditingController(text: product.khoiLuong?.toString());
    final sizeController = TextEditingController(text: product.kichThuoc);
    final originController = TextEditingController(text: product.xuatXu);

    // Gán giá trị ban đầu cho dropdown
    String? currentLoaiSanPham = product.maLoaiSanPham.toString();
    String? currentHangSanXuat = product.maHangSanXuat.toString();
    String? currentNhaCungCap = product.maNhaCungCap.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa sản phẩm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hiển thị ảnh hiện tại nếu có
              if (product.image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.network(
                    product.image!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ElevatedButton.icon(
                onPressed: _showImagePickerOptions,
                icon: const Icon(Icons.image),
                label: const Text('Thay đổi ảnh'),
              ),
              const SizedBox(height: 16),

              // Dropdown Loại sản phẩm
              DropdownButtonFormField<String>(
                value: currentLoaiSanPham,
                decoration: const InputDecoration(labelText: 'Loại sản phẩm'),
                items: loaiSanPhamList.map((loai) {
                  return DropdownMenuItem<String>(
                    value: loai['id'],
                    child: Text(loai['name'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    currentLoaiSanPham = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Hãng sản xuất
              DropdownButtonFormField<String>(
                value: currentHangSanXuat,
                decoration: const InputDecoration(labelText: 'Hãng sản xuất'),
                items: hangSanXuatList.map((hang) {
                  return DropdownMenuItem<String>(
                    value: hang['id'],
                    child: Text(hang['name'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    currentHangSanXuat = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Nhà cung cấp
              DropdownButtonFormField<String>(
                value: currentNhaCungCap,
                decoration: const InputDecoration(labelText: 'Nhà cung cấp'),
                items: nhaCungCapList.map((ncc) {
                  return DropdownMenuItem<String>(
                    value: ncc['id'],
                    child: Text(ncc['name'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    currentNhaCungCap = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Các trường nhập liệu khác
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên sản phẩm')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Mô tả')),
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
              TextField(controller: sizeController, decoration: const InputDecoration(labelText: 'Kích thước')),
              TextField(controller: originController, decoration: const InputDecoration(labelText: 'Xuất xứ')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Kiểm tra nếu các dropdown null
              if (currentLoaiSanPham == null || currentHangSanXuat == null || currentNhaCungCap == null) {
                showError('Vui lòng chọn đầy đủ thông tin.');
                return;
              }

              // Cập nhật sản phẩm
              var request = http.MultipartRequest(
                'PUT',
                Uri.parse('${ApiConfig.baseUrl}/api/SanPham/UpdateProduct/${product.maSanPham}'),
              );

              request.fields['TenSanPham'] = nameController.text;
              request.fields['Mota'] = descriptionController.text;
              request.fields['SoLuong'] = quantityController.text;
              request.fields['DonGia'] = priceController.text;
              request.fields['KhoiLuong'] = weightController.text;
              request.fields['KichThuoc'] = sizeController.text;
              request.fields['XuatXu'] = originController.text;
              request.fields['MaLoaiSanPham'] = currentLoaiSanPham!;
              request.fields['MaHangSanXuat'] = currentHangSanXuat!;
              request.fields['MaNhaCungCap'] = currentNhaCungCap!;

              // Nếu có ảnh mới được chọn
              if (selectedImage != null) {
                request.files.add(await http.MultipartFile.fromPath(
                  'Images',
                  selectedImage!.path,
                ));
              }

              var response = await request.send();
              if (response.statusCode == 204) {
                await fetchProducts();
                showSuccess('Cập nhật sản phẩm thành công');
                Navigator.pop(context);
              } else {
                final error = await response.stream.bytesToString();
                showError('Cập nhật thất bại: $error');
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }
  Future<void> _updateProduct(
      int id,
      String name,
      String description,
      int quantity,
      double price,
      double weight,
      String size,
      String origin,
      List<XFile>? selectedImages,
      ) async {
    try {
      setState(() => isLoading = true);

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}/api/SanPham/UpdateProduct/$id'),
      );

      request.fields['tenSanPham'] = name;
      request.fields['mota'] = description;
      request.fields['soLuong'] = quantity.toString();
      request.fields['donGia'] = price.toString();
      request.fields['khoiLuong'] = weight.toString();
      request.fields['kichThuoc'] = size;
      request.fields['xuatXu'] = origin;

      // Thêm danh sách ảnh vào yêu cầu
      if (selectedImages != null) {
        for (var image in selectedImages) {
          request.files.add(await http.MultipartFile.fromPath(
            'Images',
            image.path,
          ));
        }
      }

      var response = await request.send();
      if (response.statusCode == 204) {
        await fetchProducts();
        showSuccess('Cập nhật sản phẩm thành công');
      } else {
        showError('Cập nhật sản phẩm thất bại: ${response.reasonPhrase}');
      }
    } catch (e) {
      showError('Lỗi khi cập nhật sản phẩm: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }
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
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN', // Thay bằng token nếu cần
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        showSuccess('Xóa sản phẩm thành công');
        fetchProducts(); // Tải lại danh sách sản phẩm
      } else {
        final error = json.decode(response.body);
        showError('Xóa sản phẩm thất bại: ${error['message'] ?? 'Unknown error'}');
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
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('Đóng'),
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
            onPressed:
            _showAddProductDialog, // Gọi phương thức thêm sản phẩm mới
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
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Đang tải, vui lòng chờ...', style: TextStyle(fontSize: 16)),
          ],
        ),
      )
          : products.isEmpty
          ? const Center(child: Text('Không tìm thấy sản phẩm'))
          :
      ListView.builder(
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
              onTap: () => showProductDetails(product), // Sự kiện khi nhấn vào sản phẩm
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditProductDialog(product),
                    tooltip: 'Sửa sản phẩm',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteProduct(product),
                    tooltip: 'Xóa sản phẩm',
                  ),
                ],
              ),
            ),
          );
        },
      ),

    );
  }
  Future<void> fetchDropdownData() async {
    try {
      final loaiResponse = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/LoaiSanPham/Get'));
      final hangResponse = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/HangSanXuat/Get'));
      final nccResponse = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/NhaCungCap/Get'));

      if (loaiResponse.statusCode == 200 &&
          hangResponse.statusCode == 200 &&
          nccResponse.statusCode == 200) {
        setState(() {
          loaiSanPhamList = (json.decode(loaiResponse.body) as List<dynamic>).map((item) {
            return {
              'id': item['maLoaiSanPham'].toString(),
              'name': item['tenLoaiSanPham'].toString(),
            };
          }).toList();
          hangSanXuatList = (json.decode(hangResponse.body) as List<dynamic>).map((item) {
            return {
              'id': item['maHangSanXuat'].toString(),
              'name': item['tenHangSanXuat'].toString(),
            };
          }).toList();
          nhaCungCapList = (json.decode(nccResponse.body) as List<dynamic>).map((item) {
            return {
              'id': item['maNhaCungCap'].toString(),
              'name': item['tenNhaCungCap'].toString(),
            };
          }).toList();
        });
      } else {
        showError('Lỗi khi tải dữ liệu dropdown');
      }
    } catch (e) {
      showError('Lỗi khi tải dữ liệu dropdown: $e');
    }
  }
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
