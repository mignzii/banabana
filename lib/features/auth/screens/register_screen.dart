import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_input_decoration.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/auth/data/auth_repository.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _focusLast     = FocusNode();
  final _focusEmail    = FocusNode();
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _focusLast.dispose();
    _focusEmail.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).updateProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      );
      if (mounted) {
        context.go('/auth/set-pin', extra: {'phone': widget.phone});
      }
    } catch (e) {
      if (mounted) {
        context.showSnack('Erreur : $e', type: SnackType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 20 + bottom),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 64,
                    height: 64,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Créer votre compte', style: AppTextStyles.screenTitle),
                const SizedBox(height: 8),
                Text('Quelques informations pour commencer',
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
                  onFieldSubmitted: (_) => _focusEmail.requestFocus(),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Le nom est requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  focusNode: _focusEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: AppInputDecoration.standard(
                    label: 'Email (optionnel)',
                    prefixIcon: const Icon(Symbols.mail),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final ok = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
                    return ok.hasMatch(v) ? null : 'Email invalide';
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
