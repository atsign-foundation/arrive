class MixedConstants {
  // static const String WEBSITE_URL = 'https://staging.atsign.wtf/';
  static const String WEBSITE_URL = 'https://atsign.com/';

  // for local server
  // static const String ROOT_DOMAIN = 'vip.ve.atsign.zone';
  // for staging server
  // static const String ROOT_DOMAIN = 'root.atsign.wtf';
  // for production server
  static const String ROOT_DOMAIN = 'root.atsign.org';

  static const String TERMS_CONDITIONS = 'https://atsign.com/terms-conditions/';
  // static const String PRIVACY_POLICY = 'https://atsign.com/privacy-policy/';
  static const String PRIVACY_POLICY =
      "https://atsign.com/apps/atmosphere/atmosphere-privacy/";

  static const int TIME_OUT = 60000;

  static List<String> startTimeOptions = [
    '2 hours before the event',
    '60 minutes before the event',
    '30 minutes before the event'
  ];

  static List<String> endTimeOptions = [
    '10 mins after I reach the venue',
    'After everyone’s at the venue',
    'At the end of the day'
  ];

  static const String appNamespace = 'rrive';
  static const String syncRegex = '.$appNamespace@';

  static const int maxTTL = 10080 * 60;
  static const bool isDedicated = false;
}
