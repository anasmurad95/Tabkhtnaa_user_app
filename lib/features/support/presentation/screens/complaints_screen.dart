import 'package:flutter/material.dart';

import '../../../../core/constants/figma_assets.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_page_scaffold.dart';
import '../../../localization/presentation/extensions/translation_context.dart';

/// Figma 5. Complaint (0:4014–0:3923)
class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final _subject = TextEditingController();
  final _body = TextEditingController();
  String _type = 'order';

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('complaint_sent', fallback: 'تم إرسال الشكوى'))),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPageScaffold(
      title: context.tr('complaints', fallback: 'شكاوى'),
      onBack: () => Navigator.pop(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(FigmaAssets.profileNotification, width: 40, height: 40),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('send_complaint', fallback: 'إرسال شكوى'),
              textAlign: TextAlign.center,
              style: AppTypography.shamelBold(size: 14),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: InputDecoration(labelText: context.tr('issue_type', fallback: 'نوع المشكلة')),
              items: [
                DropdownMenuItem(value: 'order', child: Text(context.tr('order_issue', fallback: 'مشكلة طلب'))),
                DropdownMenuItem(value: 'delivery', child: Text(context.tr('delivery', fallback: 'توصيل'))),
                DropdownMenuItem(value: 'payment', child: Text(context.tr('payment', fallback: 'دفع'))),
                DropdownMenuItem(value: 'other', child: Text(context.tr('other', fallback: 'أخرى'))),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'order'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subject,
              decoration: InputDecoration(labelText: context.tr('subject', fallback: 'الموضوع')),
              validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _body,
              maxLines: 5,
              decoration: InputDecoration(labelText: context.tr('details', fallback: 'التفاصيل')),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(context.tr('submit', fallback: 'إرسال')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
