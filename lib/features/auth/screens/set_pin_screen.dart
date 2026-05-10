import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/features/auth/data/auth_repository.dart';
import 'package:banabana_b2b/features/auth/screens/pin_widgets.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';

class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _confirming = false;
  bool _loading = false;

  void _onDigit(String d) {
    HapticFeedback.lightImpact();
    if (!_confirming) {
      if (_pin.length < 4) {
        setState(() => _pin += d);
        if (_pin.length == 4) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) setState(() => _confirming = true);
          });
        }
      }
    } else {
      if (_confirmPin.length < 4) {
        setState(() => _confirmPin += d);
        if (_confirmPin.length == 4) _setPin();
      }
    }
  }

  void _onDelete() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_confirming) {
        if (_confirmPin.isNotEmpty) _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _setPin() async {
    if (_pin != _confirmPin) {
      if (mounted) {
        context.showSnack('Les codes PIN ne correspondent pas', type: SnackType.error);
        setState(() { _confirmPin = ''; _confirming = false; _pin = ''; });
      }
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.setPin(phone: widget.phone, pin: _pin);
      if (mounted) context.go('/auth/pin', extra: {'phone': widget.phone});
    } catch (e) {
      if (mounted) context.showSnack('Erreur : $e', type: SnackType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _confirming ? _confirmPin : _pin;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Symbols.lock, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                _confirming ? 'Confirmez votre PIN' : 'Créez votre PIN',
                style: AppTextStyles.screenTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('4 chiffres pour sécuriser votre accès',
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    4, (i) => PinDot(filled: i < current.length)),
              ),
              const Spacer(),
              if (_loading)
                const CircularProgressIndicator()
              else
                PinPad(onDigit: _onDigit, onDelete: _onDelete),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
