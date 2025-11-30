import 'package:expense_manager/components/settings/database_config_form/database_config_form.dart';
import 'package:expense_manager/components/settings/recurring_transactions/recurring_transactions.dart';
import 'package:expense_manager/components/settings/theme_settings/theme_settings.dart';
import 'package:expense_manager/components/settings/widget_config/widget_config.dart';
import 'package:expense_manager/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    var settingsItems = [
      SettingsItem(
        title: 'Database Configuration',
        description: 'Configure the database connection',
        icon: Icons.storage,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DatabaseConfigForm()),
          );
        },
      ),
      SettingsItem(
        title: 'Dashboard Configuration',
        description: 'Manage dashboard widget visibility',
        icon: Icons.widgets,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WidgetConfig()),
          );
        },
      ),
      SettingsItem(
        title: 'Reccuring Transactions',
        description: 'Manage recurring transactions and schedule',
        icon: Icons.replay,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecurringTransactions()),
          );
        },
      ),
      SettingsItem(
        title: 'Theme Settings',
        description: 'Dark mode, Theme color',
        icon: Icons.palette,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThemeSettings()),
          );
        },
      ),
      SettingsItem(
        title: 'Toggle Authentication',
        description: 'Enable or disable biometric authentication',
        icon: authProvider.isAuthEnabled ? Icons.key : Icons.key_off,
        onClick: () {
          authProvider.updateIsAuthEnabled(!authProvider.isAuthEnabled);
        },
      ),
    ];
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: ListView(
              children: settingsItems
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 5, top: 5),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: item.onClick,
                          child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                spacing: 15,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 25,
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      Text(
                                        item.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        softWrap: true,
                                      ),
                                    ],
                                  )),
                                ],
                              )),
                        ),
                      ))
                  .toList()),
        ));
  }
}

class SettingsItem {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onClick;

  SettingsItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.onClick,
  });
}
