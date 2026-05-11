class MockConversation {
  const MockConversation({
    required this.id,
    required this.contactName,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  final String id;
  final String contactName;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool isOnline;

  String get initials {
    final parts = contactName.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return contactName[0].toUpperCase();
  }
}

class MockMessage {
  const MockMessage({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isMine,
  });

  final String id;
  final String content;
  final DateTime timestamp;
  final bool isMine;
}

// Données mockées
final mockConversations = [
  MockConversation(
    id: '1',
    contactName: 'Grossiste Diallo',
    lastMessage: 'Je voudrais commander 50 kg de tomates',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    unreadCount: 2,
    isOnline: true,
  ),
  MockConversation(
    id: '2',
    contactName: 'Boutique Koné',
    lastMessage: 'Merci pour la livraison rapide !',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    unreadCount: 0,
  ),
  MockConversation(
    id: '3',
    contactName: 'Marché Central',
    lastMessage: 'Avez-vous des bananes plantain ?',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 1,
  ),
  MockConversation(
    id: '4',
    contactName: 'Resto La Saveur',
    lastMessage: 'Commande passée pour demain',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    unreadCount: 0,
  ),
];

final mockMessages = {
  '1': [
    MockMessage(id: '1', content: 'Bonjour, je suis intéressé par vos tomates', timestamp: DateTime.now().subtract(const Duration(hours: 1)), isMine: false),
    MockMessage(id: '2', content: 'Bonjour ! Bien sûr, quelle quantité vous intéresse ?', timestamp: DateTime.now().subtract(const Duration(minutes: 55)), isMine: true),
    MockMessage(id: '3', content: 'Je voudrais commander 50 kg de tomates', timestamp: DateTime.now().subtract(const Duration(minutes: 5)), isMine: false),
  ],
  '2': [
    MockMessage(id: '1', content: 'La livraison est arrivée !', timestamp: DateTime.now().subtract(const Duration(hours: 3)), isMine: false),
    MockMessage(id: '2', content: 'Merci pour la livraison rapide !', timestamp: DateTime.now().subtract(const Duration(hours: 2)), isMine: false),
    MockMessage(id: '3', content: 'Avec plaisir, bonne journée !', timestamp: DateTime.now().subtract(const Duration(hours: 2)), isMine: true),
  ],
};
