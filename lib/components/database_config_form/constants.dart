import 'package:postgres/postgres.dart';

const String hostTextFormFieldLabel = 'Host';
const String portTextFormFieldLabel = 'Port';
const String nameTextFormFieldLabel = 'Database Name';
const String usernameTextFormFieldLabel = 'Username';
const String passwordTextFormFieldLabel = 'Password';
const String sslModeDropdownFieldLabel = 'SSL Mode';

const String hostTextFormFieldHint = 'Enter host';
const String portTextFormFieldHint = 'Enter port';
const String nameTextFormFieldHint = 'Enter database name';
const String usernameTextFormFieldHint = 'Enter username';
const String passwordTextFormFieldHint = 'Enter password';
const String sslModeDropdownFieldHint = 'Enter SSL Mode';

var sslModeOptions = SslMode.values.map((s) {
  return s.toString();
}).toList();
