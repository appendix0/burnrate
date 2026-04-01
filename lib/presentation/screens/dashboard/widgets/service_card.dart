import 'package:burnrate/core/constants/app_colors.dart';
import 'package:burnrate/core/constants/service_metadata.dart';
import 'package:burnrate/core/utils/currency_formatter.dart';
import 'package:burnrate/data/models/service_type.dart';
import 'package:burnrate/data/models/usage_summary.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.type,
    required this.summary,
    this.capacityUsd,
    this.onTap,
    this.onSetLimit,
  });

  final ServiceType type;
  final UsageSummary summary;
  final double? capacityUsd;
  final VoidCallback? onTap;
  final VoidCallback? onSetLimit;

  double get _progress {
    if (capacityUsd == null || capacityUsd! <= 0) return 0;
    return (summary.currentPeriodCostUsd / capacityUsd!).clamp(0.0, 1.0);
  }

  bool get _overBudget =>
      capacityUsd != null &&
      summary.currentPeriodCostUsd >= capacityUsd!;

  @override
  Widget build(BuildContext context) {
    final meta = kServiceMeta[type]!;
    final barColor = _overBudget ? AppColors.error : meta.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _overBudget
                ? AppColors.error.withOpacity(0.5)
                : AppColors.surfaceBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + name + spend
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: meta.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(meta.icon, color: meta.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    meta.displayName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(summary.currentPeriodCostUsd),
                      style: TextStyle(
                        color: _overBudget
                            ? AppColors.error
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (capacityUsd != null)
                      Text(
                        'of ${CurrencyFormatter.format(capacityUsd!)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar
            if (capacityUsd != null) ...[
              _UsageBar(progress: _progress, color: barColor),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _overBudget ? 'Over budget' : '${(_progress * 100).toStringAsFixed(1)}% used',
                    style: TextStyle(
                      color: _overBudget
                          ? AppColors.error
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight:
                          _overBudget ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  _PeriodDelta(summary: summary),
                ],
              ),
            ] else ...[
              // No limit set
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PeriodDelta(summary: summary),
                  GestureDetector(
                    onTap: onSetLimit,
                    child: const Text(
                      'Set limit',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  const _UsageBar({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 8,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Container(
                  width: constraints.maxWidth * value,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PeriodDelta extends StatelessWidget {
  const _PeriodDelta({required this.summary});
  final UsageSummary summary;

  @override
  Widget build(BuildContext context) {
    if (summary.previousPeriodCostUsd == 0) return const SizedBox.shrink();
    final delta = summary.periodDelta;
    final pct = (delta.abs() / summary.previousPeriodCostUsd * 100)
        .toStringAsFixed(0);
    final isUp = delta > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isUp ? Icons.arrow_upward : Icons.arrow_downward,
          color: isUp ? AppColors.warning : AppColors.success,
          size: 12,
        ),
        const SizedBox(width: 2),
        Text(
          '$pct% vs last month',
          style: TextStyle(
            color: isUp ? AppColors.warning : AppColors.success,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
