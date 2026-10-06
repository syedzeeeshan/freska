import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:freska_vendor/core/components/freska_vendor_button.dart';
import 'package:freska_vendor/core/components/freska_vendor_card.dart';
import 'package:freska_vendor/core/di/injection.dart';
import 'package:freska_vendor/core/theme/vendor_theme.dart';
import 'package:freska_vendor/features/menu/data/vendor_menu_repository.dart';
import '../bloc/vendor_menu_bloc.dart';

class VendorMenuItemFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialItem;
  const VendorMenuItemFormScreen({super.key, this.initialItem});

  @override
  State<VendorMenuItemFormScreen> createState() => _VendorMenuItemFormScreenState();
}

class _VendorMenuItemFormScreenState extends State<VendorMenuItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountPriceController;

  int _selectedCategoryId = 1;
  bool _isAvailable = true;
  bool _isColdChain = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _nameController = TextEditingController(text: item?['name'] as String? ?? '');
    _descController = TextEditingController(text: item?['description'] as String? ?? '');
    _priceController = TextEditingController(text: item?['price']?.toString() ?? '');
    _discountPriceController = TextEditingController(text: item?['discount_price']?.toString() ?? '');
    _selectedCategoryId = item?['category_id'] as int? ?? 1;
    _isAvailable = item?['is_available'] as bool? ?? true;
    _isColdChain = item?['is_cold_chain'] as bool? ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = sl<VendorMenuRepository>();
      final price = double.parse(_priceController.text.trim());
      final discText = _discountPriceController.text.trim();
      final discPrice = discText.isNotEmpty ? double.tryParse(discText) : null;

      await repo.saveMenuItem(
        id: widget.initialItem?['id'] as int?,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: price,
        discountPrice: discPrice,
        categoryId: _selectedCategoryId,
        isAvailable: _isAvailable,
        isColdChain: _isColdChain,
      );

      if (mounted) {
        context.read<VendorMenuBloc>().add(LoadVendorMenuItemsEvent());
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu item saved successfully!'),
            backgroundColor: FreskaVendorColors.statusSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: FreskaVendorColors.statusError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialItem != null;

    return Scaffold(
      backgroundColor: FreskaVendorColors.bgDarkest,
      appBar: AppBar(
        backgroundColor: FreskaVendorColors.bgDarkest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(isEdit ? 'Edit Item Details' : 'Add Item to Catalog'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: FreskaVendorColors.bgSurface,
          border: Border(top: BorderSide(color: FreskaVendorColors.bgSubtle, width: 1.5)),
        ),
        child: SafeArea(
          child: FreskaVendorButton(
            label: isEdit ? 'Save Changes ✓' : 'Add Item to Live Catalog →',
            isLoading: _isSaving,
            onPressed: _save,
            width: double.infinity,
            height: 52,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Basic Details Card
            FreskaVendorCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Item Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'e.g. Organic Farm Sourdough Bread',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Item name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  const Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descController,
                    hint: 'e.g. Naturally leavened sourdough bread baked daily using unbleached wheat flour',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pricing Card
            FreskaVendorCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Base Price (₹)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _priceController,
                              hint: '180.00',
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || double.tryParse(v.trim()) == null) ? 'Enter valid price' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Discount Price (₹)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _discountPriceController,
                              hint: 'Optional (150)',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('Department / Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: FreskaVendorColors.bgDarkest,
                      borderRadius: BorderRadius.circular(FreskaRadius.md),
                      border: Border.all(color: FreskaVendorColors.bgSubtle),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedCategoryId,
                        isExpanded: true,
                        dropdownColor: FreskaVendorColors.bgElevated,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Fresh Dairy & Milk')),
                          DropdownMenuItem(value: 2, child: Text('Farm Fruits & Berries')),
                          DropdownMenuItem(value: 3, child: Text('Artisan Bakery')),
                          DropdownMenuItem(value: 4, child: Text('Organic Vegetables')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategoryId = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cold Chain & Availability Card
            FreskaVendorCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FreskaVendorColors.coldChain.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(FreskaRadius.sm),
                        ),
                        child: const Icon(Icons.ac_unit_rounded, color: FreskaVendorColors.coldChain, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cold-Chain Control (4°C)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                            Text('Rider uses thermal insulated icebox', style: TextStyle(fontSize: 11, color: FreskaVendorColors.textSecondary)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isColdChain,
                        activeThumbColor: FreskaVendorColors.coldChain,
                        onChanged: (val) => setState(() => _isColdChain = val),
                      ),
                    ],
                  ),
                  const Divider(color: FreskaVendorColors.bgSubtle, height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FreskaVendorColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(FreskaRadius.sm),
                        ),
                        child: const Icon(Icons.inventory_2_outlined, color: FreskaVendorColors.secondary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Available in Stock', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                            Text('Visible to customers in ordering range', style: TextStyle(fontSize: 11, color: FreskaVendorColors.textSecondary)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isAvailable,
                        activeThumbColor: FreskaVendorColors.secondary,
                        onChanged: (val) => setState(() => _isAvailable = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: FreskaVendorColors.textMuted),
        filled: true,
        fillColor: FreskaVendorColors.bgDarkest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FreskaRadius.md),
          borderSide: const BorderSide(color: FreskaVendorColors.bgSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FreskaRadius.md),
          borderSide: const BorderSide(color: FreskaVendorColors.bgSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FreskaRadius.md),
          borderSide: const BorderSide(color: FreskaVendorColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
