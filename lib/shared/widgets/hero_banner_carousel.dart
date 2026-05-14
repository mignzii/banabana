import 'dart:async';
import 'package:flutter/material.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/core/theme/app_spacing.dart';
import 'package:banabana_b2b/core/theme/app_text_styles.dart';

class BannerData {
  const BannerData({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.gradientColors,
    this.badgeLabel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final List<Color> gradientColors;
  final String? badgeLabel;
  final VoidCallback? onTap;
}

class HeroBannerCarousel extends StatefulWidget {
  const HeroBannerCarousel({
    super.key,
    required this.banners,
    this.height = 180,
    this.autoScrollInterval = const Duration(seconds: 4),
  });

  final List<BannerData> banners;
  final double height;
  final Duration autoScrollInterval;

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  late final PageController _pageCtrl;
  late final Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _timer = Timer.periodic(widget.autoScrollInterval, (_) {
      if (!mounted || widget.banners.length <= 1) return;
      final next = (_currentPage + 1) % widget.banners.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (p) => setState(() => _currentPage = p),
            itemCount: widget.banners.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _BannerCard(data: widget.banners[i]),
            ),
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: AppSpacing.s12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentPage ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.data});
  final BannerData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          gradient: LinearGradient(
            colors: data.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Cercle décoratif
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            // Contenu
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s20,
                vertical: AppSpacing.s14,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (data.badgeLabel != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      child: Text(
                        data.badgeLabel!,
                        style: AppTextStyles.badge.copyWith(
                          color: AppColors.black,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                  ],
                  Text(
                    data.title,
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    data.subtitle,
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      data.ctaLabel,
                      style: AppTextStyles.label.copyWith(
                        color: data.gradientColors.first,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
