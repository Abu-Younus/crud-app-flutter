import 'dart:convert';
import 'package:crud_app/widgets/custom_text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class UpdateProductScreen extends StatefulWidget {
  final String? productId; // Add productId to handle edit scenario

  const UpdateProductScreen({super.key, required this.productId}); // Optional productId for update

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  // TextEditingControllers for form fields
  final TextEditingController _productNameTEController = TextEditingController();
  final TextEditingController _unitPriceTEController = TextEditingController();
  final TextEditingController _totalPriceTEController = TextEditingController();
  final TextEditingController _imageTEController = TextEditingController();
  final TextEditingController _codeTEController = TextEditingController();
  final TextEditingController _quantityTEController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _fetchProductDetails(widget.productId!); // Fetch existing product details if editing
    }
  }

  // Fetch product details from the API
  Future<void> _fetchProductDetails(String productId) async {
    setState(() => _inProgress = true);
    Uri uri = Uri.parse('http://164.68.107.70:6060/api/v1/ReadProductById/$productId');

    try {
      Response response = await get(uri);

      if (response.statusCode == 200) {
        Map<String, dynamic> productData = jsonDecode(response.body);
        print(productData); // Debug: Print the fetched product data

        setState(() {
          // Set text only if the keys exist in productData
          _productNameTEController.text = productData['ProductName'] ?? '';
          _unitPriceTEController.text = productData['UnitPrice']?.toString() ?? '0';
          _totalPriceTEController.text = productData['TotalPrice']?.toString() ?? '0';
          _imageTEController.text = productData['Img'] ?? '';
          _codeTEController.text = productData['ProductCode'] ?? '';
          _quantityTEController.text = productData['Qty']?.toString() ?? '0';
        });
      } else {
        _showErrorSnackbar('Failed to load product data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorSnackbar('An error occurred: ${error.toString()}');
    } finally {
      setState(() => _inProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildUpdateProductForm(),
      ),
    );
  }

  // Form widget to build input fields
  Widget _buildUpdateProductForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextInputField(
            controller: _productNameTEController,
            label: 'Product Name',
            hint: 'Enter product name',
            validator: (value) => _validateNotEmpty(value, 'Product name'),
          ),
          CustomTextInputField(
            controller: _unitPriceTEController,
            label: 'Unit Price',
            hint: 'Enter unit price',
            validator: (value) => _validateIsNumeric(value, 'Unit price'),
            keyboardType: TextInputType.number,
          ),
          CustomTextInputField(
            controller: _totalPriceTEController,
            label: 'Total Price',
            hint: 'Enter total price',
            validator: (value) => _validateIsNumeric(value, 'Total price'),
            keyboardType: TextInputType.number,
          ),
          CustomTextInputField(
            controller: _imageTEController,
            label: 'Product Image',
            hint: 'Enter image URL',
            validator: (value) => _validateNotEmpty(value, 'Image URL'),
          ),
          CustomTextInputField(
            controller: _codeTEController,
            label: 'Product Code',
            hint: 'Enter product code',
            validator: (value) => _validateNotEmpty(value, 'Product code'),
          ),
          CustomTextInputField(
            controller: _quantityTEController,
            label: 'Quantity',
            hint: 'Enter quantity',
            validator: (value) => _validateIsNumeric(value, 'Quantity'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _inProgress
              ? const CircularProgressIndicator()
              : ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size.fromWidth(double.maxFinite),
            ),
            onPressed: _onTapUpdateProductButton,
            child: const Text('Update Product'),
          ),
        ],
      ),
    );
  }

  // Validator to check if the field is not empty
  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter a valid $fieldName';
    }
    return null;
  }

  // Validator to check if the field contains a numeric value
  String? _validateIsNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter a valid $fieldName';
    } else if (double.tryParse(value) == null) {
      return 'Please enter a valid number for $fieldName';
    }
    return null;
  }

  // Triggered when the "Save Product" button is tapped
  void _onTapUpdateProductButton() {
    if (_formKey.currentState!.validate()) {
      updateProduct();
    }
  }

  // Method to update existing product data
  Future<void> updateProduct() async {
    setState(() => _inProgress = true);

    Uri uri = Uri.parse('http://164.68.107.70:6060/api/v1/UpdateProduct/${widget.productId}');
    Map<String, dynamic> requestBody = {
      "Img": _imageTEController.text,
      "ProductCode": _codeTEController.text,
      "ProductName": _productNameTEController.text,
      "Qty": _quantityTEController.text,
      "TotalPrice": _totalPriceTEController.text,
      "UnitPrice": _unitPriceTEController.text
    };

    try {
      Response response = await post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        _clearTextFields();
        _showSuccessSnackbar('Product updated successfully');
        _fetchProductDetails(widget.productId!); // Refetch product details
      } else {
        _showErrorSnackbar('Failed to update product. Try again.');
      }
    } catch (error) {
      _showErrorSnackbar('An error occurred. Please try again later.');
    } finally {
      setState(() => _inProgress = false);
    }
  }

  // Clears all text fields after successful addition or update
  void _clearTextFields() {
    _productNameTEController.clear();
    _quantityTEController.clear();
    _totalPriceTEController.clear();
    _unitPriceTEController.clear();
    _imageTEController.clear();
    _codeTEController.clear();
  }

  // Helper method to show success SnackBar
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Helper method to show error SnackBar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _productNameTEController.dispose();
    _quantityTEController.dispose();
    _totalPriceTEController.dispose();
    _unitPriceTEController.dispose();
    _imageTEController.dispose();
    _codeTEController.dispose();
    super.dispose();
  }
}
