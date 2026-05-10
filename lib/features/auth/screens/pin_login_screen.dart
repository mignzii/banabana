import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/features/auth/data/auth_repository.dart';
import 'package:banabana_b2b/features/auth/providers/auth_provider.dart';
import 'package:banabana_b2b/features/auth/providers/biometric_provider.dart';
import 'package:banabana_b2b/features/auth/screens/pin_widgets.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';

export 'package:banabana_b2b/features/auth/screens/pin_widgets.dart' show PinDot;

class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key, required this.phone});
  final String phone;

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  String _pin = '';
  int _attempts = 0;
  bool _blocked = false;
  int _blockCountdown = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(biometricProvider.notifier).initialize();
    });
  }

  void _onDigit(String d) {
    if (_blocked) return;
    HapticFeedback.lightImpact();
    setState(() {
      if (_pin.length < 4) {
        _pin += d;
        if (_pin.length == 4) _verify();
      }
    });
  }

  void _onDelete() {
    if (_blocked) return;
    HapticFeedback.lightImpact();
    setState(() {
      if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  void _startBlock() {
    setState(() { _blocked = true; _blockCountdown = 30; });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _blockCountdown--);
      if (_blockCountdown <= 0) {
        setState(() { _blocked = false; _attempts = 0; });
        return false;
      }
      return true;
    });
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final auth = await repo.verifyPin(phone: widget.phone, pin: _pin);
      await ref.read(authProvider.notifier).login(auth);
    } catch (_) {
      _attempts++;
      setState(() => _pin = '');
      if (_attempts >= 3) {
        _startBlock();
        if (mounted) {
          context.showSnack(
            'Trop de tentatives. Réessayez dans 30s.',
            type: SnackType.error,
            duration: const Duration(seconds: 5),
          );
        }
      } else {
        if (mounted) {
          context.showSnack(
            'PIN incorrect (${3 - _attempts} essai(s) restant(s))',
            type: SnackType.error,
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _biometricLogin() async {
    final success = await ref.read(biometricProvider.notifier).authenticate();
    if (!success) {
      if (mounted) context.showSnack('Authentification biométrique annulée', type: SnackType.warning);
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).initialize();
    } catch (e) {
      if (mounted) context.showSnack('Erreur de connexion', type: SnackType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometric = ref.watch(biometricProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Symbols.lock_open, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Entrez votre PIN',
                  style: AppTextStyles.screenTitle, textAlign: TextAlign.center),
              if (_blocked)
                Text('Réessayez dans ${_blockCountdown}s',
                    style: AppTextStyles.bodySecondary.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => PinDot(filled: i < _pin.length)),
              ),
              const SizedBox(height: 32),
              if (_loading)
                const CircularProgressIndicator()
              else ...[
                PinPad(onDigit: _onDigit, onDelete: _onDelete, disabled: _blocked),
                if (biometric.isAvailable && biometric.isEnabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Semantics(
                      label: 'Se connecter avec biométrie',
                      button: true,
                      child: IconButton(
                        key: const Key('biometric_button'),
                        tooltip: 'Se connecter avec Face ID / Empreinte',
                        icon: const Icon(Symbols.fingerprint, size: 36),
                        color: AppColors.primary,
                        onPressed: _biometricLogin,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
