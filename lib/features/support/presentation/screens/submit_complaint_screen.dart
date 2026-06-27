import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';

import '../../../../core/theme/app_typography.dart';

import '../../../../core/widgets/app_page_scaffold.dart';

import '../../../localization/presentation/extensions/translation_context.dart';

import '../../../orders/presentation/providers/orders_provider.dart';

import '../providers/support_provider.dart';



/// Figma — قدم شكوى form.

class SubmitComplaintScreen extends StatefulWidget {

  const SubmitComplaintScreen({super.key});



  @override

  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();

}



class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {

  final _title = TextEditingController();

  final _details = TextEditingController();

  String _type = 'order';

  int? _orderId;

  List<Map<String, dynamic>> _orders = [];

  bool _loadingOrders = true;



  @override

  void initState() {

    super.initState();

    _loadOrders();

  }



  Future<void> _loadOrders() async {
    try {
      final provider = context.read<OrdersProvider>();
      await provider.load();
      if (mounted) {
        setState(() {
          _orders = provider.orders;
          if (_orders.isNotEmpty) {
            _orderId = (_orders.first['id'] as num?)?.toInt();
          }
          _loadingOrders = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingOrders = false);
    }
  }



  @override

  void dispose() {

    _title.dispose();

    _details.dispose();

    super.dispose();

  }



  Future<void> _submit() async {

    if (_orderId == null) {
      AppToast.info(context, context.tr('select_order', fallback: 'اختر طلباً'));
      return;
    }

    if (_title.text.trim().isEmpty || _details.text.trim().isEmpty) {
      AppToast.info(context, context.tr('fill_required', fallback: 'يرجى تعبئة جميع الحقول'));
      return;
    }



    final ok = await context.read<SupportProvider>().submitComplaint(

          type: _type,

          orderId: _orderId!,

          title: _title.text.trim(),

          details: _details.text.trim(),

        );

    if (!mounted) return;

    if (ok) {
      AppToast.success(context, context.tr('complaint_sent', fallback: 'تم إرسال الشكوى'));
      Navigator.pop(context, true);
    } else {
      AppToast.error(
        context,
        context.read<SupportProvider>().error ??
            context.tr('complaint_send_failed', fallback: 'تعذر إرسال الشكوى'),
      );
    }

  }



  @override

  Widget build(BuildContext context) {

    final submitting = context.watch<SupportProvider>().submitting;



    return AppPageScaffold(

      title: context.tr('send_complaint', fallback: 'قدم شكوى'),

      body: SingleChildScrollView(

        padding: const EdgeInsets.fromLTRB(30, 16, 30, 24),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            DropdownButtonFormField<String>(

              initialValue: _type,

              decoration: InputDecoration(

                labelText: context.tr('complaint_type', fallback: 'نوع الشكوى'),

                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

              ),

              items: [

                DropdownMenuItem(value: 'order', child: Text(context.tr('order_issue', fallback: 'مشكلة طلب'))),

                DropdownMenuItem(value: 'delivery', child: Text(context.tr('delivery', fallback: 'توصيل'))),

                DropdownMenuItem(value: 'payment', child: Text(context.tr('payment', fallback: 'دفع'))),

                DropdownMenuItem(value: 'other', child: Text(context.tr('other', fallback: 'أخرى'))),

              ],

              onChanged: (v) => setState(() => _type = v ?? 'order'),

            ),

            const SizedBox(height: 12),

            if (_loadingOrders)

              const LinearProgressIndicator(color: AppColors.primary)

            else if (_orders.isEmpty)

              Text(

                context.tr('no_orders_for_complaint', fallback: 'لا توجد طلبات لربط الشكوى'),

                style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),

              )

            else

              DropdownButtonFormField<int>(

                initialValue: _orderId,

                decoration: InputDecoration(

                  labelText: context.tr('order', fallback: 'الطلب'),

                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

                ),

                items: _orders

                    .map((o) => DropdownMenuItem<int>(

                          value: (o['id'] as num).toInt(),

                          child: Text('#${o['id']}'),

                        ))

                    .toList(),

                onChanged: (v) => setState(() => _orderId = v),

              ),

            const SizedBox(height: 12),

            TextFormField(

              controller: _title,

              decoration: InputDecoration(

                labelText: context.tr('subject', fallback: 'العنوان'),

                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

              ),

            ),

            const SizedBox(height: 12),

            TextFormField(

              controller: _details,

              maxLines: 5,

              decoration: InputDecoration(

                labelText: context.tr('details', fallback: 'التفاصيل'),

                alignLabelWithHint: true,

                enabledBorder: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(12),

                  borderSide: const BorderSide(color: Color(0xFF1E9BD7), width: 1.5),

                ),

                focusedBorder: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(12),

                  borderSide: const BorderSide(color: Color(0xFF1E9BD7), width: 2),

                ),

              ),

            ),

            const SizedBox(height: 24),

            SizedBox(

              height: 40,

              child: ElevatedButton(

                onPressed: submitting ? null : _submit,

                style: ElevatedButton.styleFrom(

                  backgroundColor: AppColors.primary,

                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23.5)),

                ),

                child: submitting

                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))

                    : Text(context.tr('submit', fallback: 'إرسال'), style: AppTypography.shamelBold(size: 14, color: Colors.white)),

              ),

            ),

          ],

        ),

      ),

    );

  }

}


