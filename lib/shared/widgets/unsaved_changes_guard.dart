import 'package:flutter/material.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';

/// Empêche de quitter un formulaire modifié sans confirmation.
///
/// [PopScope] couvre le geste retour iOS et le bouton retour Android. Il ne
/// couvre **pas** les boutons retour custom d'AppBar, qui appellent `pop()`
/// directement sans passer par `maybePop()` : ceux-là doivent appeler
/// [UnsavedChangesGuard.confirmLeave] avant de sortir.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    super.key,
    required this.isDirty,
    required this.child,
    this.title = _defaultTitle,
    this.message = _defaultMessage,
  });

  static const _defaultTitle = 'Abandonner les modifications ?';
  static const _defaultMessage = 'Les informations saisies seront perdues.';

  /// Le formulaire contient des saisies non enregistrées.
  final bool isDirty;
  final Widget child;
  final String title;
  final String message;

  /// Demande confirmation avant de quitter. Renvoie `true` si l'utilisateur
  /// accepte de perdre sa saisie.
  static Future<bool> confirmLeave(
    BuildContext context, {
    String title = _defaultTitle,
    String message = _defaultMessage,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Abandonner',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final leave = await confirmLeave(context, title: title, message: message);
        if (leave && navigator.mounted) navigator.pop();
      },
      child: child,
    );
  }
}
