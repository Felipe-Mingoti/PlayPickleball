import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../common/extensions/context_extensions.dart';
import '../../../../common/layouts/responsive_layout.dart';
import '../../../../common/widgets/branding/app_footer.dart';
import '../../../../common/widgets/feedback/app_empty_state.dart';
import '../../../../common/widgets/feedback/app_error_state.dart';
import '../../../../common/widgets/feedback/app_loading_state.dart';
import '../../../../common/widgets/inputs/app_search_field.dart';
import '../../domain/value_objects/comparison_selection.dart';
import '../controllers/catalog_controller.dart';
import '../providers/catalog_providers.dart';
import '../providers/comparison_providers.dart';
import '../providers/paddle_providers.dart';
import '../widgets/catalog_filter_bar.dart';
import '../widgets/catalog_filter_sheet.dart';
import '../widgets/catalog_sort_menu.dart';
import '../widgets/hero_namespace.dart';
import '../widgets/paddle_card.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLimitMessage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warning = Theme.of(context).extension<AppSemanticColors>()?.warning;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You can compare up to 3 paddles. Remove one to add another.',
          style: TextStyle(
            color: isDark ? AppColors.darkOnSecondary : Colors.white,
          ),
        ),
        backgroundColor: warning,
      ),
    );
  }

  void _toggleCompare(String id, ComparisonSelection selection) {
    if (selection.contains(id)) {
      context.router.replaceSelection(selection.remove(id));
      return;
    }
    final result = selection.add(id);
    if (result.result == ComparisonAddResult.limitReached) {
      _showLimitMessage();
      return;
    }
    context.router.replaceSelection(result.selection);
  }

  @override
  Widget build(BuildContext context) {
    final selection = selectionFromContext(context);
    final filters = ref.watch(catalogControllerProvider);
    final filtered = ref.watch(filteredPaddlesProvider);
    final columns = ResponsiveLayout.catalogColumns(context);

    return filtered.when(
      loading: () => const AppLoadingState(),
      error: (error, _) => AppErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(paddlesProvider),
      ),
      data: (paddles) {
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: context.pagePadding.copyWith(bottom: 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paddle catalog',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Discover paddles and select up to three to compare.',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: context.colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (context.isCompact)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: AppSearchField(
                                controller: _searchController,
                                onChanged: (value) => ref
                                    .read(catalogControllerProvider.notifier)
                                    .setQuery(value),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            CatalogFilterMenuButton(
                              selected: filters.hasActiveFilters,
                              onPressed: () => showCatalogFilterSheet(context),
                            ),
                          ],
                        ),
                      )
                    else
                      AppSearchField(
                        controller: _searchController,
                        onChanged: (value) => ref
                            .read(catalogControllerProvider.notifier)
                            .setQuery(value),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    if (context.isCompact)
                      const Align(
                        alignment: Alignment.centerRight,
                        child: CatalogSortMenu(),
                      )
                    else
                      const CatalogFilterBar(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            if (paddles.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  title: 'No paddles match',
                  message: 'Try adjusting your search or filters.',
                  icon: Icons.search_off,
                ),
              )
            else
              SliverPadding(
                padding: context.pagePadding.copyWith(top: 0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                    // Slightly taller than wide so image + meta + compare action fit.
                    childAspectRatio: columns == 1 ? 0.58 : 0.64,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final paddle = paddles[index];
                    final selected = selection.contains(paddle.id);
                    return PaddleCard(
                      paddle: paddle,
                      selected: selected,
                      heroNamespace: HeroNamespace.catalog,
                      onOpen: () {
                        context.router.goPaddleDetail(
                          paddle.id,
                          selection: selection,
                          extra: const PaddleHeroExtra(
                            namespace: HeroNamespace.catalog,
                          ),
                        );
                      },
                      onToggleCompare: () =>
                          _toggleCompare(paddle.id, selection),
                    );
                  }, childCount: paddles.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
            AppFooter.sliver(context),
          ],
        );
      },
    );
  }
}

extension on BuildContext {
  GoRouter get router => GoRouter.of(this);
}
