import 'package:flutter/material.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';

class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final int badgeCount;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray900 : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.gray200,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomPadding > 0 ? bottomPadding : AppSpacing.s20,
          top: AppSpacing.s8,
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final isActive = i == currentIndex;
            return Expanded(
              child: _NavItem(
                item: item,
                isActive: isActive,
                isDark: isDark,
                onTap: () => onTap(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final AppNavItem item;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.primary;
    final inactiveColor = isDark ? AppColors.gray600 : AppColors.gray400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: AppSpacing.touchTarget + AppSpacing.s8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Indicateur teal — slide animé
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: isActive ? 24 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppSpacing.radiusPill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            // Icône avec badge optionnel
            Stack(
              clipBehavior: Clip.none,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: isActive ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 150),
                  builder: (_, fill, __) => Icon(
                    item.icon,
                    size: 24,
                    fill: fill,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
                if (item.badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.badgeCount > 9 ? '9+' : '${item.badgeCount}',
                        style: AppTextStyles.badge.copyWith(fontSize: 9),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s4),
            // Label uniquement sur item actif
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isActive ? 1.0 : 0.0,
              child: Text(
                item.label,
                style: AppTextStyles.badge.copyWith(
                  color: activeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
