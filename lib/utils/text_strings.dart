class TextStrings {
  TextStrings._();
  static TextStrings _instance = TextStrings._();
  factory TextStrings() => _instance;

  //error texts
  String errorOccured = 'Some Error occured';
}
