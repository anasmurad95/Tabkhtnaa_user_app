import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/figma_page_scaffold.dart' show FigmaAuthScaffold;
import '../../../localization/presentation/extensions/translation_context.dart';

/// Figma 0:4901, 0:4730 — OTP / phone code
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, this.phoneOrEmail});

  final String? phoneOrEmail;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verify() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('otp_required', fallback: 'أدخل الرمز المكون من 4 أرقام'))),
      );
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return FigmaAuthScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(43, 24, 43, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('verification_code', fallback: 'رمز التحقق'),
              textAlign: TextAlign.center,
              style: AppTypography.shamelBold(size: 20, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              '${context.tr('otp_sent', fallback: 'أرسلنا رمزاً إلى')} ${widget.phoneOrEmail ?? ''}',
              textAlign: TextAlign.center,
              style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) {
                return SizedBox(
                  width: 56,
                  height: 48,
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: AppTypography.shamelBold(size: 18, color: AppColors.primary),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 3) _focusNodes[i + 1].requestFocus();
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _verify,
                child: Text(context.tr('verify', fallback: 'تحقق')),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              child: Text(
                context.tr('resend_code', fallback: 'إعادة إرسال الرمز'),
                style: AppTypography.shamelBold(size: 10, color: AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
