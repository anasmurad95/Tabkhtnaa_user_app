import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/image_url.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

/// Figma chat list — RTL rows with avatar, online dot, time, swipe actions.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ChatProvider>().loadConversations());
  }

  String _peerName(Map<String, dynamic> c) {
    final u1 = c['user1'] as Map<String, dynamic>?;
    final u2 = c['user2'] as Map<String, dynamic>?;
    return u2?['name']?.toString() ?? u1?['name']?.toString() ?? '—';
  }

  String? _peerImage(Map<String, dynamic> c) {
    final u2 = c['user2'] as Map<String, dynamic>?;
    final u1 = c['user1'] as Map<String, dynamic>?;
    return u2?['profile_image']?.toString() ?? u1?['profile_image']?.toString();
  }

  String _lastMessage(Map<String, dynamic> c) {
    final last = c['last_message'] as Map<String, dynamic>?;
    return last?['message']?.toString() ?? '';
  }

  String _timeLabel(Map<String, dynamic> c) {
    final last = c['last_message'] as Map<String, dynamic>?;
    final raw = last?['created_at']?.toString() ?? c['updated_at']?.toString();
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return AppPageScaffold(
      title: context.tr('chat', fallback: 'الشات'),
      body: chat.loading
          ? const LoadingView()
          : chat.conversations.isEmpty
              ? Center(
                  child: Text(
                    chat.error ?? context.tr('no_conversations', fallback: 'لا توجد محادثات'),
                    style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: chat.conversations.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final c = chat.conversations[i];
                    final id = c['id'] as int;
                    return Dismissible(
                      key: ValueKey(id),
                      background: _swipeBg(Icons.phone, AppColors.success, Alignment.centerRight),
                      secondaryBackground: _swipeBg(Icons.delete_outline, AppColors.error, Alignment.centerLeft),
                      confirmDismiss: (dir) async {
                        if (dir == DismissDirection.endToStart) {
                          return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(context.tr('delete_chat', fallback: 'حذف المحادثة؟')),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
                                  ],
                                ),
                              ) ??
                              false;
                        }
                        return false;
                      },
                      onDismissed: (_) => chat.loadConversations(),
                      child: Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                conversationId: id,
                                title: _peerName(c),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundImage: _peerImage(c) != null
                                          ? CachedNetworkImageProvider(resolveMediaUrl(_peerImage(c)))
                                          : null,
                                      child: _peerImage(c) == null
                                          ? const Icon(Icons.person, color: AppColors.textMuted)
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.surface, width: 1.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _peerName(c),
                                        style: AppTypography.shamelBold(size: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _lastMessage(c),
                                        style: AppTypography.shamelBook(size: 11, color: AppColors.textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _timeLabel(c),
                                  style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _swipeBg(IconData icon, Color color, Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Icon(icon, color: color),
    );
  }
}
