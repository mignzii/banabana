import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/features/auth/data/auth_repository.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_input_decoration.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController(text: '+221');
  String _role = 'producer';
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _phoneCtrl.text.replaceAll(RegExp(r'\D'), '').length >= 9;

  String? _validatePhone(String? v) {
    if (v == null || v.replaceAll(RegExp(r'\D'), '').length < 9) {
      return 'Numéro invalide — ex: +221 77 123 45 67';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.requestOtp(phone: _phoneCtrl.text.trim(), role: _role);
      if (mounted) {
        context.push('/auth/otp',
            extra: {'phone': _phoneCtrl.text.trim(), 'role': _role});
      }
    } catch (e) {
      if (mounted) context.showSnack('Erreur : $e', type: SnackType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 40, 20, 20 + bottom),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Symbols.storefront, size: 56, color: AppColors.primary),
                const SizedBox(height: 16),
                Text('BanaBana Business',
                    style: AppTextStyles.screenTitle,
                    textAlign: TextAlign.center),
                Text('Connectez-vous pour continuer',
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center),
                const SizedBox(height: 40),
                Semantics(
                  label: 'Numéro de téléphone',
                  child: TextFormField(
                    controller: _phoneCtrl,
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[+\d]')),
                    ],
                    decoration: AppInputDecoration.standard(
                      label: 'Numéro de téléphone',
                      hint: '+221 77 123 45 67',
                      prefixIcon: const Icon(Symbols.phone, color: AppColors.primary),
                    ),
                    validator: _validatePhone,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Votre profil', style: AppTextStyles.label),
                const SizedBox(height: 8),
                _RoleSelector(
                  selected: _role,
                  onChanged: (r) => setState(() => _role = r),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _canSubmit && !_loading ? _submit : null,
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.white))
                      : const Text('Continuer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _RoleChip(
              value: 'producer', label: 'Producteur',
              icon: Symbols.eco, selected: selected, onTap: onChanged),
          const SizedBox(width: 8),
          _RoleChip(
              value: 'wholesaler', label: 'Grossiste',
              icon: Symbols.store, selected: selected, onTap: onChanged),
          const SizedBox(width: 8),
          _RoleChip(
              value: 'vendor', label: 'Vendeur',
              icon: Symbols.sell, selected: selected, onTap: onChanged),
        ],
      );
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.value, required this.label,
    required this.icon, required this.selected, required this.onTap,
  });
  final String value, label;
  final IconData icon;
  final String selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return Expanded(
      child: Semantics(
        label: '$label, ${isSelected ? "sélectionné" : "non sélectionné"}',
        button: true,
        child: GestureDetector(
          onTap: () => onTap(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.gray200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon,
                    size: 22,
                    color: isSelected ? AppColors.white : AppColors.gray500),
                const SizedBox(height: 4),
                Text(label,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? AppColors.white : AppColors.gray600,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
