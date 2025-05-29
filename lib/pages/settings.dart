import 'package:expense_manager/components/settings/database_config_form/database_config_form.dart';
import 'package:expense_manager/components/settings/widget_config/widget_config.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
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
    ];
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: ListView.builder(
              itemCount: settingsItems.length,
              itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 5, top: 5),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: settingsItems[index].onClick,
                      child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            spacing: 15,
                            children: [
                              Icon(
                                settingsItems[index].icon,
                                size: 25,
                              ),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      settingsItems[index].title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      settingsItems[index].description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    )
                                  ]),
                            ],
                          )),
                    ),
                  )),
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
