import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/wholesaler/providers/cart_providers.dart';
import 'package:banabana_b2b/features/wholesaler/providers/wholesaler_order_providers.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';
import 'package:intl/intl.dart';

enum _PaymentMethod { mobileMoney, cash, card }

extension _PaymentMethodX on _PaymentMethod {
  String get label => switch (this) {
        _PaymentMethod.mobileMoney => 'Mobile Money',
        _PaymentMethod.cash => 'Paiement à la livraison',
        _PaymentMethod.card => 'Carte bancaire',
      };

  IconData get icon => switch (this) {
        _PaymentMethod.mobileMoney => Symbols.smartphone,
        _PaymentMethod.cash => Symbols.payments,
        _PaymentMethod.card => Symbols.credit_card,
      };

  String get apiKey => switch (this) {
        _PaymentMethod.mobileMoney => 'mobile',
        _PaymentMethod.cash => 'cash',
        _PaymentMethod.card => 'card',
      };
}

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  _PaymentMethod _paymentMethod = _PaymentMethod.mobileMoney;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    setState(() => _loading = true);
    try {
      final items = cartItems
          .map((i) => {'variantId': i.variantId, 'quantity': i.quantity})
          .toList();

      final order = await ref
          .read(wholesalerOrdersProvider.notifier)
          .placeOrder(items);

      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        context.showSnack('Commande passée avec succès !',
            type: SnackType.success);
        context.pushReplacement('/shop/orders/${order.id}');
      }
    } catch (e) {
      if (mounted) {
        context.showSnack(e.toString(), type: SnackType.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final fmt = NumberFormat('#,###', 'fr_FR');

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        elevation: 0,
        title: Text(
          'Finaliser la commande',
          style: AppTextStyles.sectionTitle.copyWith(
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            // Order summary card
            _SectionCard(
              isDark: isDark,
              title: 'Récapitulatif',
              icon: Symbols.shopping_bag,
              child: Column(
                children: [
                  ...cartItems.map(
                    (item) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.s8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productTitle,
                                  style: AppTextStyles.label.copyWith(
                                    color: isDark
                                        ? AppColors.gray100
                                        : AppColors.gray900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${item.variantLabel} × ${item.quantity}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: isDark
                                        ? AppColors.gray400
                                        : AppColors.gray500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${fmt.format((item.unitPrice * item.quantity).toInt())} F',
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.gray100
                                  : AppColors.gray900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: AppSpacing.s16,
                    color:
                        isDark ? AppColors.darkBorder : AppColors.gray200,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.gray100
                              : AppColors.gray900,
                        ),
                      ),
                      Text(
                        '${fmt.format(total.toInt())} FCFA',
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),

            // Delivery address
            _SectionCard(
              isDark: isDark,
              title: 'Adresse de livraison',
              icon: Symbols.location_on,
              child: Column(
                children: [
                  _Field(
                    controller: _nameCtrl,
                    label: 'Nom complet *',
                    hint: 'Jean Dupont',
                    isDark: isDark,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Champ requis'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _Field(
                    controller: _phoneCtrl,
                    label: 'Téléphone *',
                    hint: '+225 07 00 00 00 00',
                    isDark: isDark,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9+\s\-]'))
                    ],
                    validator: (v) =>
                        (v == null || v.trim().length < 8)
                            ? 'Numéro invalide'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _Field(
                    controller: _addressCtrl,
                    label: 'Adresse *',
                    hint: 'Rue, quartier, numéro...',
                    isDark: isDark,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Champ requis'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _Field(
                    controller: _cityCtrl,
                    label: 'Ville *',
                    hint: 'Abidjan',
                    isDark: isDark,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Champ requis'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _Field(
                    controller: _notesCtrl,
                    label: 'Notes (optionnel)',
                    hint: 'Instructions particulières...',
                    isDark: isDark,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),

            // Payment method
            _SectionCard(
              isDark: isDark,
              title: 'Mode de paiement',
              icon: Symbols.payments,
              child: Column(
                children: _PaymentMethod.values.map((method) {
                  final selected = _paymentMethod == method;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _paymentMethod = method),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(
                        bottom: method != _PaymentMethod.values.last
                            ? AppSpacing.s8
                            : 0,
                      ),
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : (isDark
                                ? AppColors.darkSurface2
                                : AppColors.gray50),
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMedium),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.gray200),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                      .withValues(alpha: 0.15)
                                  : (isDark
                                      ? AppColors.darkSurface
                                      : AppColors.gray100),
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSmall),
                            ),
                            child: Icon(
                              method.icon,
                              size: 18,
                              color: selected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.gray400
                                      : AppColors.gray500),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Text(
                              method.label,
                              style: AppTextStyles.label.copyWith(
                                color: selected
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.gray100
                                        : AppColors.gray900),
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            selected
                                ? Symbols.radio_button_checked
                                : Symbols.radio_button_unchecked,
                            size: 20,
                            color: selected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.gray500
                                    : AppColors.gray400),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.s32),

            // Place order button
            FilledButton.icon(
              onPressed: _loading ? null : _placeOrder,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Symbols.check_circle, size: 20),
              label: Text(
                _loading
                    ? 'En cours...'
                    : 'Confirmer — ${fmt.format(total.toInt())} F',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
                textStyle: AppTextStyles.button,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLarge),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.child,
  });

  final bool isDark;
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                title,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.gray300 : AppColors.gray600,
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.gray100 : AppColors.gray900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySecondary.copyWith(
              color: isDark ? AppColors.gray600 : AppColors.gray400,
            ),
            filled: true,
            fillColor:
                isDark ? AppColors.darkSurface2 : AppColors.gray50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s14,
              vertical: AppSpacing.s12,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.gray200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.gray200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
