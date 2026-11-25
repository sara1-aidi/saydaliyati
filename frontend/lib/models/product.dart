import 'package:flutter/material.dart';

enum ProductCategory {
  painFever('Pain & Fever', Icons.medication_rounded, Color(0xFF0B7A63), Color(0xFFDDF1EA)),
  coldFlu('Cold & Flu', Icons.air_rounded, Color(0xFF2B7DE1), Color(0xFFE0EDFD)),
  digestive('Digestive', Icons.local_dining_rounded, Color(0xFFD9801A), Color(0xFFFCEBD3)),
  vitamins('Vitamins', Icons.eco_rounded, Color(0xFF5E9A22), Color(0xFFEAF4D9)),
  antibiotics('Antibiotics', Icons.science_rounded, Color(0xFF5B6B8C), Color(0xFFE6EAF3)),
  skinCare('Skin Care', Icons.water_drop_rounded, Color(0xFFD9577E), Color(0xFFFBE3EA)),
  babyCare('Baby & Mum', Icons.child_friendly_rounded, Color(0xFF8E63D6), Color(0xFFEDE4FA)),
  firstAid('First Aid', Icons.healing_rounded, Color(0xFFD64545), Color(0xFFFCE4E4)),
  devices('Devices', Icons.monitor_heart_rounded, Color(0xFF3A5A78), Color(0xFFE1E9F1));

  const ProductCategory(this.label, this.icon, this.color, this.tint);
  final String label;
  final IconData icon;
  final Color color;
  final Color tint;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.form,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    this.oldPrice,
    this.requiresPrescription = false,
  });

  final String id;
  final String name;
  final String brand; // laboratory / manufacturer
  final String form; // e.g. "Box of 8 tablets"
  final String description;
  final int price; // in DA
  final int? oldPrice;
  final int quantity; // stock available
  final ProductCategory category;
  final bool requiresPrescription;

  bool get inStock => quantity > 0;
  bool get lowStock => quantity > 0 && quantity <= 5;
  int? get discountPercent => (oldPrice != null && oldPrice! > price)
      ? (((oldPrice! - price) / oldPrice!) * 100).round()
      : null;

  Product withId(String newId) => Product(
        id: newId, name: name, brand: brand, form: form, description: description,
        price: price, oldPrice: oldPrice, quantity: quantity, category: category,
        requiresPrescription: requiresPrescription,
      );

  /// Body sent to the API when the pharmacist adds / edits a product.
  Map<String, dynamic> toJson() => {
        'name': name,
        'brand': brand,
        'form': form,
        'description': description,
        'price': price,
        'old_price': oldPrice,
        'quantity': quantity,
        'category': category.name,
        'requires_prescription': requiresPrescription,
      };

  /// Built from the REST API response. Adjust keys to match your backend.
  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'].toString(),
        name: json['name'] as String,
        brand: (json['brand'] ?? '') as String,
        form: (json['form'] ?? '') as String,
        description: (json['description'] ?? '') as String,
        price: (json['price'] as num).round(),
        oldPrice: (json['old_price'] as num?)?.round(),
        quantity: (json['quantity'] as num).toInt(),
        requiresPrescription: json['requires_prescription'] == true ||
            json['requires_prescription'] == 1,
        category: ProductCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => ProductCategory.painFever,
        ),
      );
}
