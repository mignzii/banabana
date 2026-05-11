import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/producer/data/models/message_mock.dart';
import 'package:intl/intl.dart';

class MessagesStubScreen extends StatelessWidget {
  const MessagesStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        title: Text(
          'Messages',
          style: AppTextStyles.sectionTitle.copyWith(
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Symbols.edit_square,
              color: AppColors.primary,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        itemCount: mockConversations.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: AppSpacing.s16 + 56 + AppSpacing.s12,
          color: isDark ? AppColors.darkBorder : AppColors.gray100,
        ),
        itemBuilder: (_, i) => _ConversationTile(
          conversation: mockConversations[i],
          isDark: isDark,
          onTap: () => context.push(
            '/producer/messages/${mockConversations[i].id}',
            extra: mockConversations[i],
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.isDark,
    required this.onTap,
  });
  final MockConversation conversation;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    final timeStr = _formatTime(conversation.timestamp);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      conversation.initials,
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (conversation.isOnline)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkBg : AppColors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.s12),
              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.contactName,
                            style: AppTextStyles.label.copyWith(
                              color: isDark ? AppColors.gray100 : AppColors.gray900,
                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          timeStr,
                          style: AppTextStyles.caption.copyWith(
                            color: hasUnread ? AppColors.primary : (isDark ? AppColors.gray600 : AppColors.gray400),
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            style: AppTextStyles.bodySecondary.copyWith(
                              color: hasUnread
                                  ? (isDark ? AppColors.gray200 : AppColors.gray700)
                                  : (isDark ? AppColors.gray500 : AppColors.gray400),
                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: AppSpacing.s8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${conversation.unreadCount}',
                              style: AppTextStyles.badge.copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return DateFormat('dd/MM').format(dt);
  }
}
