import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../core/format.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/ui_providers.dart';
import '../../widgets/availability_pill.dart';
import '../../widgets/cart_snackbar.dart';
import '../../widgets/circle_icon_button.dart';
import '../../widgets/product_image.dart';
import '../../widgets/quantity_stepper.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});
  final Product product;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _qty = 1;

  void _addToCart() {
    final p = widget.product;
    ref.read(cartProvider.notifier).add(p, quantity: _qty);
    showAddedToCart(context, ref, p);
    setState(() => _qty = 1);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cartCount = ref.watch(cartCountProvider);
    final inCart = ref.watch(cartProvider.select((items) {
      final match = items.where((i) => i.product.id == p.id);
      return match.isEmpty ? 0 : match.first.quantity;
    }));
    final remaining = p.quantity - inCart; // what can still be added
    final canAdd = p.inStock && remaining > 0;
    final qty = _qty > remaining && remaining > 0 ? remaining : _qty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 290,
            backgroundColor: p.category.tint,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            leadingWidth: 62,
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Center(
                child: CircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              CircleIconButton(
                icon: Icons.shopping_bag_outlined,
                badge: cartCount,
                onTap: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  ref.read(clientTabProvider.notifier).state = 1;
                },
              ),
              const SizedBox(width: 20),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Hero(
                tag: 'product-image-${p.id}',
                child: ProductImage(
                  product: p,
                  radius: 0,
                  iconSize: 76,
                  showBrand: true,
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(26),
              child: Container(
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Tag(
                        icon: p.category.icon,
                        label: p.category.label,
                        color: p.category.color,
                        background: p.category.tint,
                      ),
                      if (p.requiresPrescription) ...[
                        const SizedBox(width: 8),
                        const _Tag(
                          icon: Icons.description_rounded,
                          label: 'Prescription required',
                          color: AppColors.amber,
                          background: AppColors.amberSoft,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(p.brand,
                      style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    p.name,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(p.form,
                      style: const TextStyle(color: AppColors.muted, fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatDA(p.price),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (p.oldPrice != null) ...[
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            formatDA(p.oldPrice!),
                            style: const TextStyle(
                              color: AppColors.muted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.dangerSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${p.discountPercent}%',
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),
                  _AvailabilityCard(product: p, inCart: inCart),
                  if (canAdd) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Quantity',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                        QuantityStepper(
                          value: qty,
                          onDecrement:
                              qty > 1 ? () => setState(() => _qty = qty - 1) : null,
                          onIncrement: qty < remaining
                              ? () => setState(() => _qty = qty + 1)
                              : null,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 22),
                  const Text('Description',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    p.description,
                    style: const TextStyle(
                        color: Color(0xFF3E5650), height: 1.55, fontSize: 14.5),
                  ),
                  const SizedBox(height: 22),
                  const Text('Product information',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Laboratory', value: p.brand),
                        _InfoRow(label: 'Presentation', value: p.form),
                        _InfoRow(label: 'Category', value: p.category.label),
                        _InfoRow(
                          label: 'Prescription',
                          value: p.requiresPrescription ? 'Required' : 'Not required',
                          last: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (p.requiresPrescription)
                    const _Notice(
                      icon: Icons.description_rounded,
                      text:
                          'This medicine requires a valid prescription. Please have it ready when your order is delivered.',
                      color: AppColors.amber,
                      background: AppColors.amberSoft,
                    ),
                  if (p.requiresPrescription) const SizedBox(height: 10),
                  const _Notice(
                    icon: Icons.info_outline_rounded,
                    text:
                        'Read the leaflet before use. If symptoms persist, ask your doctor or pharmacist.',
                    color: AppColors.primary,
                    background: AppColors.primarySoft,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: AppShadows.bar,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total',
                    style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 2),
                Text(
                  formatDA(p.price * qty),
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: FilledButton.icon(
                onPressed: canAdd ? _addToCart : null,
                icon: Icon(
                  canAdd ? Icons.shopping_bag_rounded : Icons.block_rounded,
                  size: 20,
                ),
                label: Text(
                  !p.inStock
                      ? 'Out of stock'
                      : (remaining <= 0 ? 'Maximum in cart' : 'Add to cart'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.product, required this.inCart});
  final Product product;
  final int inCart;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final detail = !p.inStock
        ? 'This product is currently unavailable.'
        : '${p.quantity} ${p.quantity == 1 ? 'unit' : 'units'} available'
            '${inCart > 0 ? ' · $inCart in your cart' : ''}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.inStock ? AppColors.primarySoft : AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              p.inStock ? Icons.inventory_2_rounded : Icons.remove_shopping_cart_rounded,
              size: 20,
              color: p.inStock ? AppColors.primary : AppColors.danger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvailabilityPill(product: p),
                const SizedBox(height: 3),
                Text(detail,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.last = false});
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13.5)),
            ),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13.5)),
            ),
          ],
        ),
      );
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.text,
    required this.color,
    required this.background,
  });
  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: TextStyle(color: color, fontSize: 13, height: 1.45)),
            ),
          ],
        ),
      );
}
