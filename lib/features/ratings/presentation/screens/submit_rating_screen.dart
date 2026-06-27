import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../localization/presentation/extensions/translation_context.dart';
import '../../data/rating_repository.dart';

class SubmitRatingScreen extends StatefulWidget {
  const SubmitRatingScreen({
    super.key,
    required this.chefId,
    required this.orderId,
  });

  final int chefId;
  final int orderId;

  @override
  State<SubmitRatingScreen> createState() => _SubmitRatingScreenState();
}

class _SubmitRatingScreenState extends State<SubmitRatingScreen> {
  int _taste = 5;
  int _service = 5;
  int _speed = 5;
  final _note = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await RatingRepository(context.read<ApiClient>()).submitRating(
        chefId: widget.chefId,
        orderId: widget.orderId,
        ratingChef: _taste,
        ratingDelivery: _service,
        ratingSpeedChef: _speed,
        note: _note.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) AppToast.error(context, e.toString());
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: context.tr('rate_order', fallback: 'تقييم الطلب'),
      body: AppPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StarRow(
              label: context.tr('taste', fallback: 'الطعم'),
              value: _taste,
              onChanged: (v) => setState(() => _taste = v),
            ),
            const SizedBox(height: 16),
            _StarRow(
              label: context.tr('service', fallback: 'الخدمة'),
              value: _service,
              onChanged: (v) => setState(() => _service = v),
            ),
            const SizedBox(height: 16),
            _StarRow(
              label: context.tr('speed', fallback: 'السرعة'),
              value: _speed,
              onChanged: (v) => setState(() => _speed = v),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _note,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.tr('comment', fallback: 'تعليق'),
              ),
            ),
            const Spacer(),
            AppPrimaryButton(
              label: context.tr('submit_rating', fallback: 'إرسال التقييم'),
              loading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: AppTypography.shamelBold(size: 14)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final star = i + 1;
            return IconButton(
              onPressed: () => onChanged(star),
              icon: Icon(
                star <= value ? Icons.star : Icons.star_border,
                color: AppColors.primary,
              ),
            );
          }),
        ),
      ],
    );
  }
}
