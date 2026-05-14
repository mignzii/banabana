import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/features/auth/data/auth_repository.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_input_decoration.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';

class QuickRegisterScreen extends ConsumerStatefulWidget {
  const QuickRegisterScreen({super.key});

  @override
  ConsumerState<QuickRegisterScreen> createState() => _QuickRegisterScreenState();
}

class _QuickRegisterScreenState extends ConsumerState<QuickRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _phoneCtrl     = TextEditingController(text: '+221');
  final _focusLast     = FocusNode();
  final _focusPhone    = FocusNode();
  String _role = 'producer';
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _focusLast.dispose();
    _focusPhone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo    = ref.read(authRepositoryProvider);
      final storage = ref.read(storageServiceProvider);
      final phone   = _phoneCtrl.text.trim();

      final hasPin = await repo.requestPin(phone: phone, role: _role);
      if (hasPin) {
        if (mounted) {
          context.showSnack(
            'Ce numéro est déjà enregistré — connectez-vous avec votre PIN',
            type: SnackType.warning,
          );
        }
        return;
      }
      final auth = await repo.verifyPin(phone: phone, pin: '0000');
      await storage.setAccessToken(auth.accessToken);
      await storage.setRefreshToken(auth.refreshToken);
      await storage.setUserJson(jsonEncode(auth.user.toJson()));
      await repo.updateProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
      );

      if (mounted) context.go('/auth/set-pin', extra: {'phone': phone});
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
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Inscription (sans SMS)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 20 + bottom),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Créer votre compte', style: AppTextStyles.screenTitle),
                const SizedBox(height: 8),
                Text('Sans code SMS — PIN par défaut : 0000',
                    style: AppTextStyles.bodySecondary),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _firstNameCtrl,
                  autofocus: true,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: AppInputDecoration.standard(
                    label: 'Prénom',
                    prefixIcon: const Icon(Symbols.person),
                  ),
                  onFieldSubmitted: (_) => _focusLast.requestFocus(),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Le prénom est requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameCtrl,
                  focusNode: _focusLast,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: AppInputDecoration.standard(
                    label: 'Nom',
                    prefixIcon: const Icon(Symbols.badge),
                  ),
                  onFieldSubmitted: (_) => _focusPhone.requestFocus(),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Le nom est requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl,
                  focusNode: _focusPhone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[+\d]')),
                  ],
                  decoration: AppInputDecoration.standard(
                    label: 'Numéro de téléphone',
                    hint: '+221 77 123 45 67',
                    prefixIcon: const Icon(Symbols.phone, color: AppColors.primary),
                  ),
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) {
                    if (v == null || v.replaceAll(RegExp(r'\D'), '').length < 9) {
                      return 'Numéro invalide — ex: +221 77 123 45 67';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text('Votre profil', style: AppTextStyles.label),
                const SizedBox(height: 8),
                _QuickRoleSelector(
                  selected: _role,
                  onChanged: (r) => setState(() => _role = r),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.white))
                      : const Text('Créer le compte'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickRoleSelector extends StatelessWidget {
  const _QuickRoleSelector({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _QuickRoleChip(
              value: 'producer', label: 'Producteur',
              icon: Symbols.eco, selected: selected, onTap: onChanged),
          const SizedBox(width: 8),
          _QuickRoleChip(
              value: 'wholesaler', label: 'Grossiste',
              icon: Symbols.store, selected: selected, onTap: onChanged),
          const SizedBox(width: 8),
          _QuickRoleChip(
              value: 'vendor', label: 'Vendeur',
              icon: Symbols.sell, selected: selected, onTap: onChanged),
        ],
      );
}

class _QuickRoleChip extends StatelessWidget {
  const _QuickRoleChip({
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
