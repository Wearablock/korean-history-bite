// lib/features/settings/widgets/premium_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_history_bite/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/premium_provider.dart';
import '../../../services/iap_service.dart';

/// 프리미엄 (광고 제거) 타일
class PremiumTile extends ConsumerWidget {
  const PremiumTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(isPremiumProvider);
    final product = ref.watch(removeAdsProductProvider);
    final isAvailable = ref.watch(isIAPAvailableProvider);

    if (isPremium) {
      // 이미 프리미엄 사용자
      return ListTile(
        leading: const Icon(
          Icons.check_circle,
          color: AppColors.correct,
        ),
        title: Text(l10n.removeAds),
        subtitle: Text(l10n.premiumActivated),
      );
    }

    return Column(
      children: [
        // 광고 제거 구매 버튼
        ListTile(
          leading: const Icon(
            Icons.block,
            color: AppColors.secondary,
          ),
          title: Text(l10n.removeAds),
          subtitle: Text(
            isAvailable && product != null
                ? product.price
                : l10n.productNotAvailable,
          ),
          trailing: ElevatedButton(
            onPressed: isAvailable && product != null
                ? () => _purchaseRemoveAds(context)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.purchase),
          ),
        ),

        const Divider(height: 1, indent: 56),

        // 구매 복원 버튼
        ListTile(
          leading: const Icon(
            Icons.restore,
            color: AppColors.textSecondaryLight,
          ),
          title: Text(l10n.restorePurchases),
          onTap: () => _restorePurchases(context),
        ),
      ],
    );
  }

  Future<void> _purchaseRemoveAds(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final success = await IAPService().purchaseRemoveAds();
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.purchaseFailed)),
      );
    }
  }

  Future<void> _restorePurchases(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    await IAPService().restorePurchases();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.purchasesRestored)),
      );
    }
  }
}
