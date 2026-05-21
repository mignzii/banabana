# Cahier de tests E2E — BanaBana B2B

Tests automatisés Maestro couvrant tous les flows de l'application pour les profils **Producteur** et **Grossiste**, ainsi que leur relation via le cycle de commande.

## Installation Maestro

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
```

Vérifier l'installation :
```bash
maestro --version
```

## Structure

```
tests/maestro/
├── .env                          # Variables partagées (phones, PIN, données test)
├── flows/                        # Flows réutilisables (login, logout, création produit)
│   ├── _login_producer.yaml
│   ├── _login_wholesaler.yaml
│   ├── _logout.yaml
│   └── _create_product.yaml
├── 01_auth/                      # Authentification
│   ├── signup_producer.yaml
│   ├── signup_wholesaler.yaml
│   ├── login_producer.yaml
│   └── login_wholesaler.yaml
├── 02_producer/                  # Tous les flows Producteur
│   ├── home.yaml
│   ├── dashboard.yaml
│   ├── products_crud.yaml
│   ├── products_search_filter.yaml
│   ├── orders.yaml
│   ├── inventory.yaml
│   ├── analytics.yaml
│   ├── categories.yaml
│   └── profile.yaml
├── 03_wholesaler/                # Tous les flows Grossiste
│   ├── home.yaml
│   ├── dashboard.yaml
│   ├── catalog.yaml
│   ├── search.yaml
│   ├── product_detail.yaml
│   ├── cart.yaml
│   ├── checkout.yaml
│   ├── orders.yaml
│   └── profile.yaml
└── 04_cross_role/                # Flows inter-rôles
    ├── order_flow_complete.yaml  # Commande de A à Z
    └── order_rejection.yaml     # Rejet de commande
```

## Lancer les tests

### Un test individuel

```bash
maestro test tests/maestro/02_producer/products_crud.yaml
```

### Tous les tests d'un dossier

```bash
maestro test tests/maestro/01_auth/
maestro test tests/maestro/02_producer/
maestro test tests/maestro/03_wholesaler/
maestro test tests/maestro/04_cross_role/
```

### Suite complète

```bash
maestro test tests/maestro/
```

### Avec variables d'environnement personnalisées

```bash
maestro test --env PRODUCER_PHONE=+2250700000099 tests/maestro/02_producer/products_crud.yaml
```

### Mode interactif (debug)

```bash
maestro studio
```

## Prérequis

| Condition | Description |
|-----------|-------------|
| Simulateur iOS actif | iPhone 16 Pro, iOS 18+ |
| App installée | `com.banabana.pro` en debug |
| Backend accessible | `http://3.227.108.30/v1` |
| Comptes de test | Voir `.env` — créer via `signup_producer.yaml` et `signup_wholesaler.yaml` si nécessaire |
| Produit actif | Pour les tests grossiste, au moins un produit actif avec variante doit exister dans le catalogue |

## Couverture

### 01 — Authentification (4 tests)
| Test | Description |
|------|-------------|
| signup_producer | Inscription Producteur sans OTP, PIN custom |
| signup_wholesaler | Inscription Grossiste sans OTP, PIN 0000 |
| login_producer | Connexion PIN, mauvais PIN, déconnexion |
| login_wholesaler | Connexion PIN, déconnexion |

### 02 — Producteur (9 tests)
| Test | Description |
|------|-------------|
| home | Actions rapides, liens, navigation tabs |
| dashboard | Stats, actions, commandes récentes |
| products_crud | Créer, Lire, Activer, Désactiver, Modifier, Supprimer |
| products_search_filter | Filtre Actifs/Inactifs/Tous, recherche, état vide |
| orders | Filtres, détail, Accepter, Refuser, Expédier |
| inventory | 4 onglets, Réapprovisionner, Ajuster, alertes, mouvements, stats |
| analytics | Affichage stats et graphiques |
| categories | Sélecteur de catégories dans formulaire |
| profile | Édition email, mode sombre, KYC, déconnexion |

### 03 — Grossiste (9 tests)
| Test | Description |
|------|-------------|
| home | Bannières, swipe, catégories, produits vedette, tabs |
| dashboard | Stats, Explorer catalogue, commandes récentes |
| catalog | Recherche inline, filtres, navigation produit |
| search | Recherche pleine page, résultats, état vide |
| product_detail | Images, description, variante, quantité, ajout panier |
| cart | Ajouter, quantité +/-, supprimer article, vider, checkout |
| checkout | Validation champs, modes de paiement, confirmation |
| orders | Filtres, détail commande, suivi statut |
| profile | Affichage, mode sombre, KYC, déconnexion |

### 04 — Cross-role (2 tests)
| Test | Description |
|------|-------------|
| order_flow_complete | Producteur crée produit → Grossiste commande → Producteur accepte & expédie → Grossiste vérifie statut |
| order_rejection | Grossiste commande → Producteur refuse → Grossiste voit "Annulée" |

## Conventions

- `optional: true` — l'élément peut être absent (cas dépendant de données backend)
- `anyOf` — plusieurs labels possibles selon l'état du backend
- Les flows `_*.yaml` sont des helpers, pas des tests indépendants
- Chaque test est autonome : se connecte, teste, ne suppose pas d'état préalable

## Numéros de test recommandés

Pour éviter les conflits entre environnements, utiliser des plages dédiées :
- Producteur : `+225070000000X`
- Grossiste  : `+225070000000X` (X différent)
- Les comptes doivent être créés via `01_auth/signup_*.yaml` avant d'exécuter les autres tests
