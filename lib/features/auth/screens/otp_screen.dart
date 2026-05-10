import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/features/auth/data/auth_repository.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/shared/widgets/app_snack_bar.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone, required this.role});
  final String phone;
  final String role;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _ctrlrs =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) => _nodes[0].requestFocus());
  }

  @override
  void dispose() {
    for (final c in _ctrlrs) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  void _startCountdown() async {
    while (_resendCountdown > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _resendCountdown--);
    }
  }

  String get _otp => _ctrlrs.map((c) => c.text).join();

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _nodes[index + 1].requestFocus();
    }
    if (_otp.length == 6) _verify();
    setState(() {});
  }

  void _onBackspace(int index) {
    if (_ctrlrs[index].text.isEmpty && index > 0) {
      _ctrlrs[index - 1].clear();
      _nodes[index - 1].requestFocus();
    }
  }

  void _onPaste(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 6) {
      for (var i = 0; i < 6; i++) {
        _ctrlrs[i].text = digits[i];
      }
      _nodes[5].requestFocus();
      setState(() {});
      _verify();
    }
  }

  Future<void> _verify() async {
    if (_otp.length < 6) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final auth = await repo.verifyOtp(phone: widget.phone, otp: _otp);
      if (auth.user.kycStatus == 'none') {
        if (mounted) {
          context.go('/auth/register', extra: {'phone': widget.phone});
        }
      } else {
        if (mounted) {
          context.go('/auth/set-pin', extra: {'phone': widget.phone});
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnack('Code incorrect. Réessayez.', type: SnackType.error);
        for (final c in _ctrlrs) c.clear();
        _nodes[0].requestFocus();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Symbols.sms, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Code de vérification',
                  style: AppTextStyles.screenTitle,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Entrez le code envoyé au ${widget.phone}',
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _OtpBox(
                  controller: _ctrlrs[i],
                  focusNode: _nodes[i],
                  onChanged: (v) => _onDigitEntered(i, v),
                  onBackspace: () => _onBackspace(i),
                  onPaste: _onPaste,
                )),
              ),
              const SizedBox(height: 32),
              if (_loading) const Center(child: CircularProgressIndicator()),
              const Spacer(),
              TextButton(
                onPressed: _resendCountdown == 0
                    ? () {
                        setState(() => _resendCountdown = 60);
                        _startCountdown();
                        ref.read(authRepositoryProvider)
                            .requestOtp(phone: widget.phone, role: widget.role);
                        context.showSnack('Code renvoyé', type: SnackType.info);
                      }
                    : null,
                child: Text(_resendCountdown > 0
                    ? 'Renvoyer dans ${_resendCountdown}s'
                    : 'Renvoyer le code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
    required this.onPaste,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  final ValueChanged<String> onPaste;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 44,
        height: 56,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          maxLength: 1,
          enableInteractiveSelection: true,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.sectionTitle,
          decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gray200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2)),
            filled: true,
            fillColor: AppColors.gray50,
          ),
          onChanged: (v) {
            if (v.length > 1) {
              onPaste(v);
            } else {
              onChanged(v);
            }
          },
          onSubmitted: (_) {},
        ),
      );
}
