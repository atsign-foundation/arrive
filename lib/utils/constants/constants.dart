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
      'https://atsign.com/apps/atmosphere/atmosphere-privacy/';

  static const int TIME_OUT = 60000;

  static const String MAP_KEY = 'B3Wus46C2WZFhwZKQkEx';
  static const String API_KEY = 'yRCeKfJDPQDTp11YI1db67J_fww80QP6R3Llckg-REw';

  static const String appNamespace = 'rrive';
  static const String syncRegex =
      '(.$appNamespace|atconnections|[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12})';

  static const int maxTTL = 10080 * 60;
  static const bool isDedicated = true;

  // Onboarding API key - requires different key for production
  static String ONBOARD_API_KEY = '477b-876u-bcez-c42z-6a3d';
}
