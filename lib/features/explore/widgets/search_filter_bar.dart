import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:world_travel/features/explore/models/spot.dart';
import 'package:world_travel/features/explore/providers/spots_provider.dart';

class SearchFilterBar extends HookConsumerWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final filter = ref.watch(spotsFilterProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'スポットを検索',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        ref
                            .read(spotsFilterProvider.notifier)
                            .updateSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.1),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onChanged: (value) {
              ref.read(spotsFilterProvider.notifier).updateSearchQuery(value);
            },
          ),
          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Distance filter
                _FilterChip(
                  label: filter.distanceRange.displayName,
                  icon: Icons.location_on,
                  onTap: () => _showDistanceRangeDialog(context, ref),
                ),
                const SizedBox(width: 8),

                // Category filter
                _FilterChip(
                  label: filter.categories.isEmpty
                      ? 'カテゴリ'
                      : '${filter.categories.length}件選択中',
                  icon: Icons.category,
                  isActive: filter.categories.isNotEmpty,
                  onTap: () => _showCategoryDialog(context, ref),
                ),
                const SizedBox(width: 8),

                // Sort order
                _FilterChip(
                  label: filter.sortOrder.displayName,
                  icon: Icons.sort,
                  onTap: () => _showSortOrderDialog(context, ref),
                ),

                if (filter.hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'クリア',
                    icon: Icons.clear_all,
                    onTap: () {
                      searchController.clear();
                      ref.read(spotsFilterProvider.notifier).clearFilters();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDistanceRangeDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '検索範囲',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...DistanceRange.values.map((range) {
                return ListTile(
                  title: Text(range.displayName),
                  onTap: () {
                    ref
                        .read(spotsFilterProvider.notifier)
                        .updateDistanceRange(range);
                    Navigator.pop(context);
                  },
                  trailing:
                      ref.watch(spotsFilterProvider).distanceRange == range
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final selectedCategories =
                ref.watch(spotsFilterProvider).categories;

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'カテゴリ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...SpotCategory.values.map((category) {
                    final isSelected = selectedCategories.contains(category);

                    return CheckboxListTile(
                      title: Text(category.displayName),
                      value: isSelected,
                      onChanged: (value) {
                        final updatedCategories = [...selectedCategories];
                        if (value ?? false) {
                          updatedCategories.add(category);
                        } else {
                          updatedCategories.remove(category);
                        }
                        ref
                            .read(spotsFilterProvider.notifier)
                            .updateCategories(updatedCategories);
                      },
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('完了'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortOrderDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '並び順',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...SortOrder.values.map((order) {
                return ListTile(
                  title: Text(order.displayName),
                  onTap: () {
                    ref
                        .read(spotsFilterProvider.notifier)
                        .updateSortOrder(order);
                    Navigator.pop(context);
                  },
                  trailing: ref.watch(spotsFilterProvider).sortOrder == order
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? Theme.of(context).primaryColor
          : Colors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : null,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
