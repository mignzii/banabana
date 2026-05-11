import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';
import 'package:banabana_b2b/features/producer/data/models/message_mock.dart';
import 'package:intl/intl.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  final String conversationId;
  final MockConversation? conversation;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late List<MockMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.from(
      mockMessages[widget.conversationId] ?? [],
    );
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(MockMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        timestamp: DateTime.now(),
        isMine: true,
      ));
    });
    _inputCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conv = widget.conversation;
    final contactName = conv?.contactName ?? 'Conversation';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.white,
        leading: IconButton(
          icon: Icon(
            Symbols.arrow_back,
            color: isDark ? AppColors.gray100 : AppColors.gray900,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                conv?.initials ?? contactName[0].toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contactName,
                  style: AppTextStyles.label.copyWith(
                    color: isDark ? AppColors.white : AppColors.gray900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (conv?.isOnline == true)
                  Text(
                    'En ligne',
                    style: AppTextStyles.caption.copyWith(color: AppColors.success),
                  ),
              ],
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Commencez la conversation',
                      style: AppTextStyles.bodySecondary.copyWith(
                        color: isDark ? AppColors.gray500 : AppColors.gray400,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s12,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _MessageBubble(
                      message: _messages[i],
                      isDark: isDark,
                    ),
                  ),
          ),
          // Input bar
          _InputBar(
            controller: _inputCtrl,
            isDark: isDark,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isDark});
  final MockMessage message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final timeStr = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                '?',
                style: AppTextStyles.badge.copyWith(color: AppColors.primary, fontSize: 10),
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s10,
                  ),
                  decoration: BoxDecoration(
                    color: isMine
                        ? AppColors.primary
                        : (isDark ? AppColors.darkSurface2 : AppColors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppSpacing.radiusLarge),
                      topRight: const Radius.circular(AppSpacing.radiusLarge),
                      bottomLeft: Radius.circular(isMine ? AppSpacing.radiusLarge : AppSpacing.s4),
                      bottomRight: Radius.circular(isMine ? AppSpacing.s4 : AppSpacing.radiusLarge),
                    ),
                    boxShadow: isMine
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                              blurRadius: 4,
                            ),
                          ],
                    border: (!isMine && !isDark)
                        ? Border.all(color: AppColors.gray100)
                        : null,
                  ),
                  child: Text(
                    message.content,
                    style: AppTextStyles.body.copyWith(
                      color: isMine
                          ? AppColors.white
                          : (isDark ? AppColors.gray100 : AppColors.gray900),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.gray600 : AppColors.gray400,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isMine) const SizedBox(width: AppSpacing.s8),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isDark,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16, AppSpacing.s8,
        AppSpacing.s16, MediaQuery.of(context).padding.bottom + AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.gray100,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface2 : AppColors.gray100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
              ),
              child: TextField(
                controller: controller,
                style: AppTextStyles.body.copyWith(
                  color: isDark ? AppColors.gray100 : AppColors.gray900,
                ),
                decoration: InputDecoration(
                  hintText: 'Écrire un message...',
                  hintStyle: AppTextStyles.bodySecondary.copyWith(
                    color: isDark ? AppColors.gray600 : AppColors.gray400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s12,
                  ),
                  isDense: true,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          // Bouton envoyer
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Symbols.send,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
