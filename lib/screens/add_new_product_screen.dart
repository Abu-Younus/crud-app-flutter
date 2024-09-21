import 'dart:convert';
import 'package:crud_app/widgets/custom_text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class AddNewProductScreen extends StatefulWidget {
  const AddNewProductScreen({super.key});

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildNewProductForm(),
      ),
    );
  }

  // Form widget to build input fields
  Widget _buildNewProductForm() {
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
            onPressed: _onTapAddProductButton,
            child: const Text('Add Product'),
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

  // Triggered when the "Add Product" button is tapped
  void _onTapAddProductButton() {
    if (_formKey.currentState!.validate()) {
      addNewProduct();
    }
  }

  // Method to send product data to API
  Future<void> addNewProduct() async {
    setState(() => _inProgress = true);

    Uri uri = Uri.parse('http://164.68.107.70:6060/api/v1/CreateProduct');
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
        _showSuccessSnackbar('New product added successfully');
      } else {
        _showErrorSnackbar('Failed to add product. Try again.');
      }
    } catch (error) {
      _showErrorSnackbar('An error occurred. Please try again later.');
    } finally {
      setState(() => _inProgress = false);
    }
  }

  // Clears all text fields after a successful product addition
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