import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../models/product.dart';
import '../../providers/product_providers.dart';
import '../../widgets/form_widgets.dart';

/// Add a product (product == null) or edit an existing one.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product});
  final Product? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _form;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _oldPrice;
  late final TextEditingController _quantity;
  late ProductCategory _category;
  late bool _requiresPrescription;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _brand = TextEditingController(text: p?.brand ?? '');
    _form = TextEditingController(text: p?.form ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _oldPrice = TextEditingController(text: p?.oldPrice?.toString() ?? '');
    _quantity = TextEditingController(text: p?.quantity.toString() ?? '');
    _category = p?.category ?? ProductCategory.painFever;
    _requiresPrescription = p?.requiresPrescription ?? false;
  }

  @override
  void dispose() {
    for (final c in [_name, _brand, _form, _description, _price, _oldPrice, _quantity]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final product = Product(
      id: widget.product?.id ?? '',
      name: _name.text.trim(),
      brand: _brand.text.trim(),
      form: _form.text.trim(),
      description: _description.text.trim(),
      price: int.parse(_price.text),
      oldPrice: _oldPrice.text.isEmpty ? null : int.parse(_oldPrice.text),
      quantity: int.parse(_quantity.text),
      category: _category,
      requiresPrescription: _requiresPrescription,
    );

    try {
      final repo = ref.read(productRepositoryProvider);
      if (_isEdit) {
        await repo.updateProduct(product);
      } else {
        await repo.createProduct(product);
      }
      ref.invalidate(productsProvider); // reload the list
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _requiredNumber(String? v, String label) {
    if (v == null || v.isEmpty) return 'Enter $label';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit product' : 'New product',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  ErrorBanner(_error!),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: appInputDecoration('Product name',
                      icon: Icons.medication_rounded),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter the product name' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _brand,
                        textInputAction: TextInputAction.next,
                        decoration: appInputDecoration('Laboratory / brand'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _form,
                        textInputAction: TextInputAction.next,
                        decoration: appInputDecoration('Presentation',
                            hint: 'Box of 20 tablets'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<ProductCategory>(
                  value: _category,
                  isExpanded: true,
                  decoration: appInputDecoration('Category'),
                  items: [
                    for (final c in ProductCategory.values)
                      DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon, size: 18, color: c.color),
                            const SizedBox(width: 10),
                            Text(c.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (c) => setState(() => _category = c ?? _category),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _description,
                  maxLines: 4,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: appInputDecoration('Description'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter a short description'
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _price,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textInputAction: TextInputAction.next,
                        decoration: appInputDecoration('Price', suffixText: 'DA'),
                        validator: (v) => _requiredNumber(v, 'the price'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _quantity,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textInputAction: TextInputAction.next,
                        decoration: appInputDecoration('Quantity in stock'),
                        validator: (v) => _requiredNumber(v, 'the quantity'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _oldPrice,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: appInputDecoration('Old price (optional, shows a discount)',
                      suffixText: 'DA'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final old = int.tryParse(v) ?? 0;
                    final price = int.tryParse(_price.text) ?? 0;
                    return old <= price ? 'Must be higher than the price' : null;
                  },
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SwitchListTile(
                    value: _requiresPrescription,
                    onChanged: (v) => setState(() => _requiresPrescription = v),
                    activeColor: AppColors.primary,
                    title: const Text('Prescription required',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                    subtitle: const Text('Shows an Rx badge to clients',
                        style: TextStyle(fontSize: 12.5)),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(_isEdit ? 'Save changes' : 'Add product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
