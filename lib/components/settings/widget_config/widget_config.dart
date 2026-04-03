import 'package:expense_manager/providers/dashboard_widget_config.dart'
    as widget_config;
import 'package:expense_manager/providers/dashboard_widgets_provider.dart';
import 'package:expense_manager/utils/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WidgetConfigPage extends StatefulWidget {
  const WidgetConfigPage({super.key});

  @override
  State<StatefulWidget> createState() => _WidgetConfigPageState();
}

class _WidgetConfigPageState extends State<WidgetConfigPage> {
  @override
  Widget build(BuildContext context) {
    final dashboardWidgetProvider =
        Provider.of<DashboardWidgetsProvider>(context);

    if (!dashboardWidgetProvider.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Widget Configuration')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final sortedConfigs = dashboardWidgetProvider.getSortedConfigs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Configuration'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset to Defaults?'),
                  content: const Text(
                    'This will enable all widgets, reset their order and sizes to default.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        dashboardWidgetProvider.resetToDefaults();
                        Navigator.pop(context);
                        showSnackBar(context, 'Widgets reset to defaults',
                            SnackBarColor.success);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Widget Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Drag widgets to reorder, use +/- buttons to resize',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  dashboardWidgetProvider.reorderWidgets(
                    oldIndex,
                    newIndex > oldIndex ? newIndex - 1 : newIndex,
                  );
                },
                children: List.generate(sortedConfigs.length, (index) {
                  final entry = sortedConfigs[index];
                  final id = entry.key;
                  final config = entry.value;

                  return _buildWidgetConfigCard(
                    key: ValueKey(id),
                    id: id,
                    config: config,
                    context: context,
                    provider: dashboardWidgetProvider,
                    sortedIndex: index,
                    sortedConfigsLength: sortedConfigs.length,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetConfigCard({
    required Key key,
    required widget_config.DashboardWidgetId id,
    required widget_config.WidgetConfig config,
    required BuildContext context,
    required DashboardWidgetsProvider provider,
    required int sortedIndex,
    required int sortedConfigsLength,
  }) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Main row with drag handle and visibility toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Drag handle
                ReorderableDragStartListener(
                  index: sortedIndex,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: const Icon(Icons.drag_handle),
                  ),
                ),
                const SizedBox(width: 12),
                // Widget name and title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        id.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // Visibility toggle
                Icon(
                  config.isEnabled ? Icons.visibility : Icons.visibility_off,
                  color: config.isEnabled ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Switch(
                  value: config.isEnabled,
                  onChanged: (value) {
                    provider.updateWidgetVisibility(id, value);
                  },
                ),
              ],
            ),
          ),
          // Size controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Width controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Width',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: config.size.$1 > 1
                              ? () => provider.updateWidgetSize(
                                  id, config.size.$1 - 1, config.size.$2)
                              : null,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${config.size.$1}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: config.size.$1 < 2
                              ? () => provider.updateWidgetSize(
                                  id, config.size.$1 + 1, config.size.$2)
                              : null,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Height controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Height',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: config.size.$2 > 1
                              ? () => provider.updateWidgetSize(
                                  id, config.size.$1, config.size.$2 - 1)
                              : null,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${config.size.$2}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: config.size.$2 < 3
                              ? () => provider.updateWidgetSize(
                                  id, config.size.$1, config.size.$2 + 1)
                              : null,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
