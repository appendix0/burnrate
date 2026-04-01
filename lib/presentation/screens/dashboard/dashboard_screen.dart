import 'package:burnrate/core/constants/app_colors.dart';
import 'package:burnrate/core/utils/currency_formatter.dart';
import 'package:burnrate/data/models/service_type.dart';
import 'package:burnrate/presentation/providers/credential_providers.dart';
import 'package:burnrate/presentation/providers/usage_providers.dart';
import 'package:burnrate/presentation/screens/dashboard/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuredAsync = ref.watch(configuredServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BurnRate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {
              ref.invalidate(configuredServicesProvider);
              final configured =
                  ref.read(configuredServicesProvider).valueOrNull ?? [];
              for (final type in configured) {
                ref.invalidate(usageSummaryProvider(type));
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: configuredAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => _ErrorState(message: e.toString()),
        data: (configured) {
          if (configured.isEmpty) return const _EmptyState();
          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              ref.invalidate(configuredServicesProvider);
              for (final type in configured) {
                ref.invalidate(usageSummaryProvider(type));
              }
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _TotalCard(configured: configured),
                const SizedBox(height: 20),
                const _SectionHeader(title: 'Services'),
                const SizedBox(height: 12),
                ...configured.map((type) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ServiceCardWrapper(type: type),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Total spend card ──────────────────────────────────────────────────────────

class _TotalCard extends ConsumerWidget {
  const _TotalCard({required this.configured});
  final List<ServiceType> configured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAsync = ref.watch(totalSpendProvider);
    final totalCapacity = ref.watch(totalCapacityProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total this month',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          totalAsync.when(
            loading: () => const _SpendSkeleton(),
            error: (_, __) => const Text('—',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w700)),
            data: (total) {
              final progress = totalCapacity != null && totalCapacity > 0
                  ? (total / totalCapacity).clamp(0.0, 1.0)
                  : null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(total),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                      if (totalCapacity != null) ...[
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '/ ${CurrencyFormatter.format(totalCapacity)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 14),
                    _TotalBar(progress: progress, total: total,
                        capacity: totalCapacity!),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  const _TotalBar(
      {required this.progress,
      required this.total,
      required this.capacity});
  final double progress;
  final double total;
  final double capacity;

  @override
  Widget build(BuildContext context) {
    final isOver = total >= capacity;
    final barColor = isOver ? AppColors.error : AppColors.accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(builder: (context, constraints) {
          return Container(
            height: 10,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Container(
                  width: constraints.maxWidth * value,
                  height: 10,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          isOver
              ? 'Over total budget'
              : '${(progress * 100).toStringAsFixed(1)}% of total budget used',
          style: TextStyle(
            color: isOver ? AppColors.error : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ── Per-service card wrapper ──────────────────────────────────────────────────

class _ServiceCardWrapper extends ConsumerWidget {
  const _ServiceCardWrapper({required this.type});
  final ServiceType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(usageSummaryProvider(type));
    final capacity = ref.watch(capacityProvider(type));

    return summaryAsync.when(
      loading: () => const _CardSkeleton(),
      error: (e, _) => _CardError(
        message: e is UnimplementedError ? 'Coming soon' : e.toString(),
        onRetry: () => ref.invalidate(usageSummaryProvider(type)),
      ),
      data: (summary) => ServiceCard(
        type: type,
        summary: summary,
        capacityUsd: capacity,
        onSetLimit: () {
          // Phase 8: navigate to settings/budgets
        },
      ),
    );
  }
}

// ── Skeleton / error / empty states ──────────────────────────────────────────

class _SpendSkeleton extends StatelessWidget {
  const _SpendSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 140,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.accent),
        ),
      ),
    );
  }
}

class _CardError extends StatelessWidget {
  const _CardError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_circle_outline,
              color: AppColors.textTertiary, size: 48),
          SizedBox(height: 16),
          Text('No services configured',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message,
          style: const TextStyle(color: AppColors.error, fontSize: 14)),
    );
  }
}
