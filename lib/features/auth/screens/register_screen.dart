import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_input_decoration.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';

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

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _focusLast.dispose();
    _focusEmail.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.go('/auth/set-pin', extra: {'phone': widget.phone});
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
                  onPressed: _submit,
                  child: const Text('Continuer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
