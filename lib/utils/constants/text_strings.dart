class TextStrings {
  TextStrings._();
  static TextStrings _instance = TextStrings._();
  factory TextStrings() => _instance;

  static final String resetButton = 'Reset';
  static const String resetDescription =
      'This will remove the selected atSign and its details from this app only.';
  static const String noAtsignToReset = 'No atSigns are paired to reset. ';
  static const String resetErrorText =
      'Please select atleast one atSign to reset';
  static const String resetWarningText =
      'Warning: This action cannot be undone';
  static const String appName = 'atArrive';
  static const String copyRight = '© 2022 The @ Company';
  // Display Title
  static const String retry = 'Retry';
  static const String actionRequired = 'Action required';
  static const String requestDeclined = 'Request declined';
  static const String cancelled = 'Cancelled';
  static const String requestRejected = 'Request rejected';
  // Error Dialogue
  static const String someErrorOccured = 'Some Error Occured';
  static const String ok = 'Ok';
  // Overlapping Contacts
  static const String and = 'and';
  static const String other = 'Other';
  static const String others = 'Others';
  // Location prompt dialog
  static const String okay = 'Okay!';
  static const String locationPromptDialogDescription =
      'Your main location sharing switch is turned off. Do you want to turn it on?';
  static const String yesTurnItOn = 'Yes! Turn it on';
  static const String no = 'No!';
  // Manage Location Sharing
  static const String youAreCurrentlySharingYourLocationForThese =
      'You are currently sharing your location for these: ';
  static const String youAreNotSharingYourLocationWithAnyone =
      'You are not sharing your location with anyone. ';
  static const updating = 'Updating';
  static const somethingWentWrongPleaseTryAgain =
      'Something went wrong , please try again.';
  static const shareLocation = 'Share Location';
  static const requestLocation = 'Request Location';
  static const areYouSureYouWantToRemove = 'Are you sure you want to remove ?';
  static const yes = 'Yes';
  static const noCancelThis = 'No! Cancel this';
  // Add Contacts
  static const add = 'Add';
  static const toContacts = 'to contacts ?';
  static const enterNickName = 'Enter Nick Name (Optional)';
  // Event Log
  static const events = 'Events';
  static const close = 'Close';
  static const upcoming = 'Upcoming';
  static const past = 'Past';
  static const eventOn = 'Event on';
  static const invitedBy = 'Invited By';
  // Home Screen
  static const noDataFound = 'No Data Found!!';
  static const createEvent = 'Create Event';
  static const delete = 'Delete';
  static const errorInGetListView = 'Error in getListView';
  static const areYouSureYouWantToDelete = 'Are you sure you want to delete ';
  static const event = 'Event - ';
  static const cancel = 'Cancel';
  static const tabbar = 'Tabbar';
  static const locations = 'Locations';
  static const noWithoutSpecialcharacters = 'No';
  static const eventData = 'Event data found';
  static const locationData = 'Location data found';
  static const filter = 'Filter';
  // Request Location Sheet
  static const requestFrom = 'Request From';
  static const searchAtsignFromContact = 'Search atSign from contacts';
  static const request = 'Request';
  static const selectAContact = 'Select a contact';
  static const locationRequestSent = 'Location Request sent';
  static const somethingWentWrong = 'Something went wrong';
  // Share Location Sheet
  static const shareWith = 'Share with';
  static const duration = 'Duration';
  static const selectDuration = 'Select Duration';
  static const untilTurnedOff = 'Until turned off';
  static const k30mins = '30 mins';
  static const k2hours = '2 hours';
  static const k24hours = '24 hours';
  static const selectTime = 'Select time';
  static const shareLocationRequestSent = 'Share Location Request sent';
  // Side Bar
  static const atSign = 'atSign';
  static const contacts = 'Contacts';
  static const blockedContacts = 'Blocked Contacts';
  static const groups = 'Groups';
  static const backupYourKeys = 'Backup your keys';
  static const faq = 'FAQ';
  static const termsAndCondition = 'Terms and Conditions';
  static const deleteAtSign = 'Delete atSign';
  static const manageLocationSharing = 'Manage location sharing';
  static const processing = 'Processing';
  static const locationSharing = 'Location Sharing';
  static const locationPermissionNotGranted = 'Location permission not granted';
  static const locationAccessDescription =
      'When you turn this on, everyone you have given access to can see  your location.';
  static const switchAtsign = 'Switch atSign';
  static const appVersion = 'App Version ';
  static const areYouSureYouWantToDeleteAllAssociatedData =
      'Are you sure you want to delete all data associated with';
  static const typeTheAtsignAboveToProceed = 'Type the atSign above to proceed';
  static const cautionTheActionCannotBeUndone =
      "Caution: this action can't be undone";
  static const pleaseTryAgain = 'Please, try again!';
  static const locationPermissionAlreadyRunning =
      ' A request for location permissions is already running, please wait for it to complete before doing another request.';
  // Splash Screen
  static const stayConnected = 'Stay connected!';
  static const whereEver = 'Wherever';
  static const youGo = 'you go.';
  static const authenticating = 'Authenticating';
  static const explore = 'Explore';
  static const loggingIn = 'Logging in';
  static const selectAll = 'Select All';
  static const remove = 'Remove';
  static const decideLater = 'Decide Later';
  // Contact BottomSheet
  static const shareLocationDurationDescription =
      'How long do you want to share your location for ?';
  // Share Location Sheet
  static const share = 'Share';

  // version_service
  static const releaseTagError = 'Error in fetching release tag.';
  static const upgradeDialogShowError =
      'Error in showing app upgrade dialog box.';
  static const appVersionFetchError =
      'Could not fetch latest app version details.';
  static const update = 'Update';
  static const mayBeLater = 'Maybe later';
}
