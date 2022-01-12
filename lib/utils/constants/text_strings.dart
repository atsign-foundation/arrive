class TextStrings {
  TextStrings._();
  static TextStrings _instance = TextStrings._();
  factory TextStrings() => _instance;

  static final String resetButton = 'Reset';
  static const String resetDescription =
      'This will remove the selected @sign and its details from this app only.';
  static const String noAtsignToReset = 'No @signs are paired to reset. ';
  static const String resetErrorText =
      'Please select atleast one @sign to reset';
  static const String resetWarningText =
      'Warning: This action cannot be undone';
  static const String appName = '@rrive';
  static const String copyRight = '© 2021 The @ Company';
}
