import 'package:expense_manager/components/database_config_form/constants.dart';
import 'package:expense_manager/components/form_helpers/form_dropdown.dart';
import 'package:expense_manager/components/form_helpers/form_field.dart';
import 'package:expense_manager/utils/database_config_store/database_config_store.dart';
import 'package:expense_manager/utils/database_manager/database_manager.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DatabaseConfigForm extends StatefulWidget {
  const DatabaseConfigForm({super.key});

  @override
  State<StatefulWidget> createState() => _DatabaseConfigFormState();
}

class _DatabaseConfigFormState extends State<DatabaseConfigForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  var isSubmitting = false;
  var isLoadingConfig = true;
  var dbConfigStore = DatabaseConfigStore();
  Map<String, TextEditingController> formControllerMap = {
    hostTextFormFieldLabel: TextEditingController(),
    portTextFormFieldLabel: TextEditingController(),
    nameTextFormFieldLabel: TextEditingController(),
    usernameTextFormFieldLabel: TextEditingController(),
    passwordTextFormFieldLabel: TextEditingController(),
    sslModeDropdownFieldLabel: TextEditingController(),
  };
  var configToFieldMap = {
    DatabaseConfigStore.dbHostKey: hostTextFormFieldLabel,
    DatabaseConfigStore.dbPortKey: portTextFormFieldLabel,
    DatabaseConfigStore.dbNameKey: nameTextFormFieldLabel,
    DatabaseConfigStore.dbUsernameKey: usernameTextFormFieldLabel,
    DatabaseConfigStore.dbPasswordKey: passwordTextFormFieldLabel,
    DatabaseConfigStore.sslModeKey: sslModeDropdownFieldLabel,
  };

  @override
  void initState() {
    super.initState();
    loadConfig();
  }

  Future<void> loadConfig() async {
    for (var e in configToFieldMap.entries) {
      await dbConfigStore.getConfigValue(e.key).then((val) {
        if (val != null) {
          formControllerMap[e.value]?.text = val;
        }
      });
    }
    setState(() {
      isLoadingConfig = false;
    });
  }

  String? checkEmptyInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return isLoadingConfig
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomFormField(
                  enabled: true,
                  maxCharacters: null,
                  keyboardType: TextInputType.text,
                  inputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                  controller: formControllerMap[hostTextFormFieldLabel]!,
                  labelText: hostTextFormFieldLabel,
                  hintText: hostTextFormFieldHint,
                  obscureText: false,
                  icon: null,
                  onSaved: (value) {},
                  validator: (value) {
                    return checkEmptyInput(value);
                  },
                ),
                CustomFormField(
                  enabled: true,
                  maxCharacters: null,
                  keyboardType: TextInputType.number,
                  inputFormatter: FilteringTextInputFormatter.digitsOnly,
                  controller: formControllerMap[portTextFormFieldLabel]!,
                  labelText: portTextFormFieldLabel,
                  hintText: portTextFormFieldHint,
                  obscureText: false,
                  icon: null,
                  onSaved: (value) {},
                  validator: (value) {
                    return checkEmptyInput(value);
                  },
                ),
                CustomFormField(
                  enabled: true,
                  maxCharacters: null,
                  keyboardType: TextInputType.text,
                  inputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                  controller: formControllerMap[nameTextFormFieldLabel]!,
                  labelText: nameTextFormFieldLabel,
                  hintText: nameTextFormFieldHint,
                  obscureText: false,
                  icon: null,
                  onSaved: (value) {},
                  validator: (value) {
                    return checkEmptyInput(value);
                  },
                ),
                CustomFormField(
                  enabled: true,
                  maxCharacters: null,
                  keyboardType: TextInputType.text,
                  inputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                  controller: formControllerMap[usernameTextFormFieldLabel]!,
                  labelText: usernameTextFormFieldLabel,
                  hintText: usernameTextFormFieldHint,
                  obscureText: false,
                  icon: null,
                  onSaved: (value) {},
                  validator: (value) {
                    return checkEmptyInput(value);
                  },
                ),
                CustomFormField(
                  enabled: true,
                  maxCharacters: null,
                  keyboardType: TextInputType.text,
                  inputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                  controller: formControllerMap[passwordTextFormFieldLabel]!,
                  labelText: passwordTextFormFieldLabel,
                  hintText: passwordTextFormFieldHint,
                  obscureText: true,
                  icon: null,
                  onSaved: (value) {},
                  validator: (value) {
                    return checkEmptyInput(value);
                  },
                ),
                CustomFormDropdown(
                  options: sslModeOptions,
                  labelText: sslModeDropdownFieldLabel,
                  controller: formControllerMap[sslModeDropdownFieldLabel]!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a value';
                    }
                    return null;
                  },
                  hintText: sslModeDropdownFieldHint,
                  icon: null,
                  addOption: null,
                  onAddOptionSelect: null,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSubmitting
                        ? theme.colorScheme.primary
                        : theme.colorScheme.inversePrimary,
                  ),
                  onPressed: () async {
                    // Ignore button presses with ongoing submit operation.
                    if (!isSubmitting) {
                      setState(() {
                        isSubmitting = true;
                      });
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        bool completedSuccessfully = true;

                        // Update values in config store
                        for (var e in configToFieldMap.entries) {
                          try {
                            await dbConfigStore.setConfigValue(
                                e.key, formControllerMap[e.value]!.text);
                          } catch (error) {
                            logger.e(error);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to save config :('),
                                  backgroundColor:
                                      Color.fromARGB(255, 95, 0, 0),
                                ),
                              );
                            }
                            completedSuccessfully = false;
                            break;
                          }
                        }

                        setState(() {
                          isSubmitting = false;
                        });

                        if (completedSuccessfully) {
                          try {
                            var dbConfig =
                                await dbConfigStore.getDatabaseConfig();
                            var dbManager = DatabaseManager();
                            await dbManager.connect(
                                dbConfig.endpoint, dbConfig.connectionSettings);
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Failed to refresh DB connection :('),
                                  backgroundColor:
                                      Color.fromARGB(255, 95, 0, 0),
                                ),
                              );
                            }
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      }
                    }
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: isSubmitting
                          ? theme.colorScheme.inversePrimary
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
