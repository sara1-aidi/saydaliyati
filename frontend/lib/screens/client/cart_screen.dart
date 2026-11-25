import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../core/format.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/ui_providers.dart';
import '../../widgets/product_image.dart';
import '../../widgets/quantity_stepper.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final count = ref.watch(cartCountProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('My cart',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(width: 10),
              if (count > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('$count ${count == 1 ? 'item' : 'items'}',
                      style: const TextStyle(color: AppColors.muted)),
                ),
              const Spacer(),
              if (items.isNotEmpty)
                TextButton(
                  onPressed: () => _confirmClear(context, ref),
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  child: const Text('Clear all'),
                ),
            ],
          ),
        ),
        if (items.isEmpty)
          Expanded(child: _EmptyCart(
            onBrowse: () => ref.read(clientTabProvider.notifier).state = 0,
          ))
        else ...[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              children: [
                const _DeliveryProgress(),
                const SizedBox(height: 14),
                for (final item in items) ...[
                  _CartItemTile(item: item),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const _OrderSummary(),
        ],
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear your cart?',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: const Text('All products will be removed from your cart.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep items')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Clear cart'),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(cartProvider.notifier).clear();
  }
}

class _DeliveryProgress extends ConsumerWidget {
  const _DeliveryProgress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(cartSubtotalProvider);
    final unlocked = subtotal >= kFreeDeliveryThreshold;
    final missing = kFreeDeliveryThreshold - subtotal;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_rounded,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  unlocked
                      ? 'Your order qualifies for free delivery'
                      : 'Add ${formatDA(missing)} more for free delivery',
                  style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5),
                ),
              ),
            ],
          ),
          if (!unlocked) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (subtotal / kFreeDeliveryThreshold).clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: Colors.white,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);
    final p = item.product;
    final atMax = item.quantity >= p.quantity;

    return Dismissible(
      key: ValueKey(p.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => notifier.remove(p.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.danger),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 76,
              height: 76,
              child: ProductImage(product: p, height: 76, iconSize: 24, radius: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14, height: 1.25),
                        ),
                      ),
                      InkWell(
                        onTap: () => notifier.remove(p.id),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.delete_outline_rounded,
                              size: 20, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${p.form} · ${formatDA(p.price)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      QuantityStepper(
                        size: 34,
                        value: item.quantity,
                        onDecrement:
                            item.quantity > 1 ? () => notifier.decrement(p.id) : null,
                        onIncrement: atMax ? null : () => notifier.increment(p.id),
                      ),
                      const Spacer(),
                      Text(
                        formatDA(item.lineTotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (atMax)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('Maximum available quantity',
                          style: TextStyle(color: AppColors.amber, fontSize: 11.5)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummary extends ConsumerWidget {
  const _OrderSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(cartSubtotalProvider);
    final delivery = ref.watch(deliveryFeeProvider);
    final total = ref.watch(cartTotalProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.bar,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(label: 'Subtotal', value: formatDA(subtotal)),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Delivery',
            value: delivery == 0 ? 'Free' : formatDA(delivery),
            valueColor: delivery == 0 ? AppColors.primary : null,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _SummaryRow(label: 'Total', value: formatDA(total), emphasized: true),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payments_outlined, size: 15, color: AppColors.muted),
                SizedBox(width: 6),
                Text('Payment in cash on delivery',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => _placeOrder(context, ref, total),
            child: Text('Place order · ${formatDA(total)}'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, WidgetRef ref, int total) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm your order',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: Text(
            'You will pay ${formatDA(total)} in cash when your order is delivered.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 42)),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    // TODO (Exercise 4): POST the cart items to your REST API here,
    // and only clear the cart once the server confirms the order.
    ref.read(cartProvider.notifier).clear();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF7FE0C3), size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('Order placed. We will prepare it right away.')),
            ],
          ),
        ),
      );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.valueColor,
  });
  final String label;
  final String value;
  final bool emphasized;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              color: emphasized ? AppColors.ink : AppColors.muted,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
              fontSize: emphasized ? 16 : 14,
            )),
        Text(value,
            style: TextStyle(
              color: valueColor ?? AppColors.ink,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
              fontSize: emphasized ? 20 : 14,
            )),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  size: 42, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('Your cart is empty',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'Add medicines and health products from the store to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: onBrowse,
              style: FilledButton.styleFrom(
                  minimumSize: const Size(200, 50)),
              child: const Text('Browse the store'),
            ),
          ],
        ),
      ),
    );
  }
}
