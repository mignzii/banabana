/// Nom à afficher pour le vendeur d'un produit ou le client d'une commande.
///
/// Le serveur génère un nom d'entreprise par défaut à partir du rôle et du
/// téléphone (« Producer +221… », « Wholesaler +221… ») quand l'utilisateur
/// n'en a pas saisi. Ce nom n'est jamais affiché : on lui préfère le nom de
/// la personne, sinon un libellé générique — jamais un numéro de téléphone.
String sellerDisplayName({
  String? displayName,
  String? businessName,
  String? firstName,
  String? lastName,
  String fallback = 'Vendeur',
}) {
  for (final candidate in [displayName, businessName]) {
    final value = candidate?.trim() ?? '';
    if (value.isNotEmpty && !isGeneratedSellerName(value)) return value;
  }
  final fullName = [firstName, lastName]
      .map((s) => s?.trim() ?? '')
      .where((s) => s.isNotEmpty)
      .join(' ');
  if (fullName.isNotEmpty && !isGeneratedSellerName(fullName)) return fullName;
  return _roleLabel(businessName) ?? fallback;
}

final _generatedName = RegExp(
  r'^(producer|wholesaler|vendor|producteur|grossiste|vendeur)?\s*\+?[\d\s().-]{6,}$',
  caseSensitive: false,
);

/// Vrai pour un nom généré par le serveur à partir du téléphone.
bool isGeneratedSellerName(String value) => _generatedName.hasMatch(value.trim());

String? _roleLabel(String? generated) {
  final value = generated?.trim().toLowerCase() ?? '';
  if (value.startsWith('producer') || value.startsWith('producteur')) {
    return 'Producteur';
  }
  if (value.startsWith('wholesaler') || value.startsWith('grossiste')) {
    return 'Grossiste';
  }
  return null;
}
