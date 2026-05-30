import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_asset_image.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../data/chat_repository.dart';

/// Figma chat detail — bubbles L/R, send field with plane icon.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.conversationId,
    this.title,
    this.peerUserId,
    this.peerType = 'chef',
  });

  final int? conversationId;
  final String? title;
  final int? peerUserId;
  final String peerType;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _message = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  int? _conversationId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  ChatRepository get _repo => ChatRepository(context.read<ApiClient>());

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_conversationId != null) {
        final data = await _repo.getConversation(_conversationId!);
        _messages
          ..clear()
          ..addAll(data.messages.reversed);
      } else if (widget.peerUserId != null) {
        final created = await _repo.createConversation(
          user2Id: widget.peerUserId!,
          user2Type: widget.peerType,
        );
        _conversationId = created['conversation_id'] as int? ?? created['id'] as int?;
        if (_conversationId != null) {
          final data = await _repo.getConversation(_conversationId!);
          _messages
            ..clear()
            ..addAll(data.messages.reversed);
        }
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _send() async {
    final text = _message.text.trim();
    if (text.isEmpty || _conversationId == null) return;
    _message.clear();
    final me = context.read<AuthProvider>().user?.id;
    setState(() {
      _messages.add({'message': text, 'user_id': me});
    });
    try {
      await _repo.sendMessage(conversationId: _conversationId!, message: text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.read<AuthProvider>().user?.id;

    return AppPageScaffold(
      title: widget.title ?? context.tr('chat', fallback: 'الشات'),
      body: _loading
          ? const LoadingView()
          : Column(
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(_error!, style: AppTypography.shamelBook(size: 10, color: AppColors.error)),
                  ),
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FigmaAssetImage(FigmaAssets.profileSettingsOrange, width: 40, height: 40),
                              const SizedBox(height: 12),
                              Text(
                                context.tr('start_chat', fallback: 'ابدأ المحادثة'),
                                style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) {
                            final m = _messages[i];
                            final mine = m['user_id'] == me;
                            return Align(
                              alignment: mine ? Alignment.centerLeft : Alignment.centerRight,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
                                decoration: BoxDecoration(
                                  color: mine ? AppColors.primary : AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppRadii.md),
                                  border: mine ? null : Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  m['message']?.toString() ?? '',
                                  style: AppTypography.shamelBook(
                                    size: 12,
                                    color: mine ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.attach_file, color: AppColors.textMuted),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _message,
                            decoration: InputDecoration(
                              hintText: context.tr('type_message', fallback: 'اكتب رسالة...'),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: ElevatedButton(
                            onPressed: _send,
                            style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                            child: const Icon(Icons.send_rounded, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
