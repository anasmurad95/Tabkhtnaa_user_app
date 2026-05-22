import 'package:flutter/material.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_page_scaffold.dart';
import '../../../localization/presentation/extensions/translation_context.dart';

/// Figma 6. Chat (0:3779–0:3589) — UI shell; messages from API when endpoint exists
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.title});

  final String? title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _message = TextEditingController();
  final List<({bool me, String text})> _messages = [];

  void _send() {
    final text = _message.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add((me: true, text: text));
      _message.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPageScaffold(
      title: widget.title ?? context.tr('chat', fallback: 'الشات'),
      onBack: () => Navigator.pop(context),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(FigmaAssets.profileSettingsOrange, width: 40, height: 40),
                        const SizedBox(height: 12),
                        Text(
                          context.tr('start_chat', fallback: 'ابدأ المحادثة مع الدعم'),
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
                      return Align(
                        alignment: m.me ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
                          decoration: BoxDecoration(
                            color: m.me ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            border: m.me ? null : Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            m.text,
                            style: AppTypography.shamelBook(size: 12, color: m.me ? Colors.white : AppColors.textPrimary),
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
                  Expanded(
                    child: TextField(
                      controller: _message,
                      decoration: InputDecoration(
                        hintText: context.tr('type_message', fallback: 'اكتب رسالة...'),
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
