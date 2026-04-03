import 'package:expense_manager/providers/dashboard_widget_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardWidgetsProvider extends ChangeNotifier {
  late final SharedPreferences prefs;
  final Map<DashboardWidgetId, WidgetConfig> _configs = {};
  bool _initialized = false;

  Map<DashboardWidgetId, WidgetConfig> get configs =>
      Map.unmodifiable(_configs);

  bool get isInitialized => _initialized;

  /// Get sorted list of widget configs by order
  List<MapEntry<DashboardWidgetId, WidgetConfig>> getSortedConfigs() {
    final entries = _configs.entries.toList();
    entries.sort((a, b) => a.value.order.compareTo(b.value.order));
    return entries;
  }

  /// Initialize provider - must be called before using
  Future<void> initialize() async {
    if (_initialized) return;

    prefs = await SharedPreferences.getInstance();

    // Initialize all widgets with their default configs and persisted values
    for (var id in DashboardWidgetId.values) {
      final isEnabled = prefs.getBool(id.persistenceKey) ?? true;
      final order = prefs.getInt(id.orderPersistenceKey) ?? id.index;

      // Load persisted size or use default
      final sizeString = prefs.getString(id.sizePersistenceKey);
      final (int, int) size;
      if (sizeString != null) {
        final parts = sizeString.split(',');
        if (parts.length == 2) {
          size = (
            int.tryParse(parts[0]) ?? id.defaultSize.$1,
            int.tryParse(parts[1]) ?? id.defaultSize.$2
          );
        } else {
          size = id.defaultSize;
        }
      } else {
        size = id.defaultSize;
      }

      _configs[id] = WidgetConfig(
        id: id,
        size: size,
        isEnabled: isEnabled,
        order: order,
      );
    }

    _initialized = true;
    notifyListeners();
  }

  /// Update widget visibility and persist
  void updateWidgetVisibility(DashboardWidgetId id, bool isEnabled) {
    if (_configs.containsKey(id)) {
      _configs[id] = _configs[id]!.copyWith(isEnabled: isEnabled);
      prefs.setBool(id.persistenceKey, isEnabled);
      notifyListeners();
    }
  }

  /// Reorder widgets by new positions
  void reorderWidgets(int oldIndex, int newIndex) {
    final entries = getSortedConfigs();
    if (oldIndex < 0 ||
        oldIndex >= entries.length ||
        newIndex < 0 ||
        newIndex >= entries.length) {
      return;
    }

    final widget = entries[oldIndex];
    int newOrder;

    if (newIndex == 0) {
      // Moving to the beginning
      newOrder = entries[0].value.order - 1;
    } else if (newIndex == entries.length - 1) {
      // Moving to the end
      newOrder = entries.last.value.order + 1;
    } else {
      // Moving to middle - find the adjacent items in the final position
      int prevOrder, nextOrder;

      if (newIndex < oldIndex) {
        // Moving backward (up in list)
        prevOrder = entries[newIndex - 1].value.order;
        nextOrder = entries[newIndex].value.order;
      } else {
        // Moving forward (down in list)
        prevOrder = entries[newIndex].value.order;
        nextOrder = entries[newIndex + 1].value.order;
      }

      newOrder = ((prevOrder + nextOrder) / 2).toInt();

      // Ensure we have a unique value between prev and next
      if (newOrder <= prevOrder) {
        newOrder = prevOrder + 1;
      }
      if (newOrder >= nextOrder) {
        newOrder = nextOrder - 1;
      }
    }

    _configs[widget.key] = widget.value.copyWith(order: newOrder);
    prefs.setInt(widget.key.orderPersistenceKey, newOrder);
    notifyListeners();
  }

  /// Update widget size with validation
  void updateWidgetSize(DashboardWidgetId id, int width, int height) {
    if (_configs.containsKey(id)) {
      // Validate size constraints: 1-2 width, 1-3 height
      final validWidth = width.clamp(1, 2);
      final validHeight = height.clamp(1, 3);

      _configs[id] = _configs[id]!.copyWith(size: (validWidth, validHeight));
      prefs.setString(id.sizePersistenceKey, '$validWidth,$validHeight');
      notifyListeners();
    }
  }

  /// Get valid size options for a widget
  List<(int, int)> getValidSizeOptions() =>
      [(1, 1), (1, 2), (1, 3), (2, 1), (2, 2), (2, 3)];

  /// Reset all widgets to default state
  void resetToDefaults() {
    for (var id in DashboardWidgetId.values) {
      _configs[id] = WidgetConfig(
        id: id,
        size: id.defaultSize,
        isEnabled: true,
        order: id.index,
      );
      prefs.setBool(id.persistenceKey, true);
      prefs.setInt(id.orderPersistenceKey, id.index);
      prefs.setString(
          id.sizePersistenceKey, '${id.defaultSize.$1},${id.defaultSize.$2}');
    }
    notifyListeners();
  }
}
