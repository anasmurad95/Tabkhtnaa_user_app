import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import '../../../../core/constants/figma_assets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';

import '../../../../core/theme/app_typography.dart';

import '../../../../core/utils/relative_time.dart';

import '../../../../core/widgets/error_view.dart';

import '../../../../core/widgets/figma_asset_image.dart';

import '../../../../core/widgets/app_page_scaffold.dart';

import '../../../../core/widgets/figma_underline_tabs.dart';

import '../../../../core/widgets/loading_view.dart';

import '../../../localization/presentation/extensions/translation_context.dart';

import '../../data/models/notification_model.dart';
import '../providers/notifications_provider.dart';



/// Figma — الإشعارات with order/admin tabs.

class NotificationsScreen extends StatefulWidget {

  const NotificationsScreen({super.key});



  @override

  State<NotificationsScreen> createState() => _NotificationsScreenState();

}



class _NotificationsScreenState extends State<NotificationsScreen> {

  @override

  void initState() {

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      context.read<NotificationsProvider>().load();

    });

  }



  @override

  Widget build(BuildContext context) {

    final provider = context.watch<NotificationsProvider>();

    final tabIndex = provider.tab == NotificationTab.orders ? 0 : 1;



    return AppPageScaffold(

      title: context.tr('notifications', fallback: 'الإشعارات'),

      actions: [

        if (provider.items.isNotEmpty)

          TextButton(

            onPressed: () async {
              try {
                await provider.deleteAll();
                if (context.mounted) {
                  AppToast.success(
                    context,
                    context.tr('notifications_deleted', fallback: 'تم حذف الإشعارات'),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppToast.error(context, e.toString());
                }
              }
            },

            child: Text(

              context.tr('delete_all', fallback: 'حذف الكل'),

              style: AppTypography.shamelBook(size: 10, color: Colors.white),

            ),

          ),

      ],

      body: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          FigmaUnderlineTabs(

            tabs: [

              context.tr('order_notifications', fallback: 'إشعارات الطلبات'),

              context.tr('admin_messages', fallback: 'رسائل الإدارة'),

            ],

            currentIndex: tabIndex,

            onTap: (i) => provider.setTab(i == 0 ? NotificationTab.orders : NotificationTab.admin),

          ),

          Expanded(

            child: provider.loading

                ? const LoadingView()

                : provider.error != null

                    ? ErrorView(message: provider.error!, onRetry: provider.load)

                    : provider.filteredItems.isEmpty

                        ? _EmptyNotifications()

                        : ListView.separated(

                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),

                            itemCount: provider.filteredItems.length,

                            separatorBuilder: (_, _) => const SizedBox(height: 10),

                            itemBuilder: (_, i) {

                              final item = provider.filteredItems[i];

                              return _NotificationCard(

                                item: item,

                                onSeen: () => _markSeen(context, provider, item.id),

                              );

                            },

                          ),

          ),

        ],

      ),

    );

  }

  Future<void> _markSeen(
    BuildContext context,
    NotificationsProvider provider,
    int id,
  ) async {
    try {
      await provider.markSeen(id);
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, e.toString());
      }
    }
  }

}



class _EmptyNotifications extends StatelessWidget {

  @override

  Widget build(BuildContext context) {

    return Center(

      child: Padding(

        padding: const EdgeInsets.all(32),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            FigmaAssetImage(FigmaAssets.profileNotification, width: 48, height: 48),

            const SizedBox(height: 16),

            Text(

              context.tr('no_notifications', fallback: 'لا توجد إشعارات حالياً'),

              textAlign: TextAlign.center,

              style: AppTypography.shamelBook(size: 12, color: AppColors.textMuted),

            ),

          ],

        ),

      ),

    );

  }

}



class _NotificationCard extends StatelessWidget {

  const _NotificationCard({required this.item, required this.onSeen});



  final NotificationModel item;

  final VoidCallback onSeen;



  @override

  Widget build(BuildContext context) {

    final text = item.body?.isNotEmpty == true ? item.body! : (item.title ?? '');

    final downloaded = item.seen;



    return Material(

      color: AppColors.surface,

      borderRadius: BorderRadius.circular(12),

      child: InkWell(

        onTap: onSeen,

        borderRadius: BorderRadius.circular(12),

        child: Container(

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),

          ),

          child: Row(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              _DownloadCircle(active: !downloaded),

              const SizedBox(width: 10),

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [

                    Text(

                      text,

                      style: AppTypography.shamelBook(size: 12),

                      maxLines: 3,

                      overflow: TextOverflow.ellipsis,

                    ),

                    const SizedBox(height: 8),

                    Row(

                      mainAxisAlignment: MainAxisAlignment.end,

                      children: [

                        Text(

                          formatRelativeTimeAr(item.createdAt),

                          style: AppTypography.shamelBook(size: 10, color: AppColors.textMuted),

                        ),

                        const SizedBox(width: 4),

                        const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),

                      ],

                    ),

                  ],

                ),

              ),

              const SizedBox(width: 8),

              Icon(

                Icons.info_outline,

                size: 18,

                color: downloaded ? AppColors.iconMuted : AppColors.primary,

              ),

            ],

          ),

        ),

      ),

    );

  }

}



class _DownloadCircle extends StatelessWidget {

  const _DownloadCircle({required this.active});



  final bool active;



  @override

  Widget build(BuildContext context) {

    return Container(

      width: 32,

      height: 32,

      decoration: BoxDecoration(

        shape: BoxShape.circle,

        color: active ? AppColors.primary : AppColors.iconMuted.withValues(alpha: 0.3),

      ),

      child: Icon(

        Icons.download_rounded,

        size: 16,

        color: active ? Colors.white : AppColors.iconMuted,

      ),

    );

  }

}


