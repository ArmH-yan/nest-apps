// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'NEST Worker';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get close => 'बंद करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get open => 'खोलें';

  @override
  String get tryAgain => 'फिर से कोशिश करें';

  @override
  String get fieldRequired => 'ज़रूरी';

  @override
  String get navTasks => 'काम';

  @override
  String get navWork => 'कार्य';

  @override
  String get navHistory => 'इतिहास';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get loginSubtitle => 'अपने काम देखने के लिए साइन इन करें';

  @override
  String get phoneLabel => 'फ़ोन नंबर';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get loginButton => 'लॉग इन';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get forgotPasswordBody =>
      'पासवर्ड रीसेट करने के लिए अपने मैनेजर से संपर्क करें।';

  @override
  String get changePasswordTitle => 'नया पासवर्ड सेट करें';

  @override
  String get changePasswordBody =>
      'आपकी सुरक्षा के लिए, शुरू करने से पहले नया पासवर्ड चुनें।';

  @override
  String get currentPassword => 'मौजूदा पासवर्ड';

  @override
  String get newPassword => 'नया पासवर्ड';

  @override
  String get repeatPassword => 'नया पासवर्ड दोबारा लिखें';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get passwordTooShort => 'कम से कम 8 अक्षर';

  @override
  String get savePassword => 'पासवर्ड सेव करें';

  @override
  String get myTasks => 'मेरे काम';

  @override
  String get sectionToday => 'आज';

  @override
  String get sectionUpcoming => 'आने वाले';

  @override
  String get sectionYesterday => 'कल';

  @override
  String get emptyTasksTitle => 'कोई काम नहीं दिया गया';

  @override
  String get emptyTasksBody => 'आपके मैनेजर के नए काम यहाँ दिखेंगे।';

  @override
  String lastUpdated(String time) {
    return 'आख़िरी अपडेट $time';
  }

  @override
  String activeTaskBanner(String title) {
    return 'आप इस पर काम कर रहे हैं: $title';
  }

  @override
  String get leadBadge => 'लीड';

  @override
  String get today => 'आज';

  @override
  String get tomorrow => 'कल';

  @override
  String get statusUpcoming => 'आने वाला';

  @override
  String get statusToday => 'शुरू करने के लिए तैयार';

  @override
  String get statusInProgress => 'काम जारी';

  @override
  String get statusOnBreak => 'ब्रेक पर';

  @override
  String get statusWaiting => 'भेजने का इंतज़ार';

  @override
  String get statusSyncFailed => 'सिंक नहीं हुआ';

  @override
  String get statusCompleted => 'पूरा हुआ';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String get jobSurvey => 'साइट सर्वे';

  @override
  String get jobInstallation => 'इंस्टॉलेशन';

  @override
  String get jobInspection => 'निरीक्षण';

  @override
  String get jobMaintenance => 'रखरखाव';

  @override
  String get jobDismantling => 'हटाना (डिस्मैंटलिंग)';

  @override
  String get taskInformation => 'काम की जानकारी';

  @override
  String get project => 'प्रोजेक्ट';

  @override
  String get customer => 'ग्राहक';

  @override
  String get instructions => 'निर्देश';

  @override
  String get scheduledDate => 'तारीख़';

  @override
  String get scheduledTime => 'समय';

  @override
  String get yourRole => 'आपकी भूमिका';

  @override
  String get roleLead => 'टीम लीड';

  @override
  String get roleMember => 'टीम सदस्य';

  @override
  String get crew => 'टीम';

  @override
  String get siteContact => 'साइट संपर्क';

  @override
  String get workLocation => 'काम की जगह';

  @override
  String get address => 'पता';

  @override
  String get accessNotes => 'पहुँचने के निर्देश';

  @override
  String get coordinates => 'निर्देशांक';

  @override
  String get workRadius => 'काम का दायरा';

  @override
  String metersValue(String meters) {
    return '$meters मी';
  }

  @override
  String get currentDistance => 'आपकी दूरी';

  @override
  String get navigate => 'रास्ता दिखाएँ';

  @override
  String get verifyMyLocation => 'मेरी लोकेशन जाँचें';

  @override
  String get openWorkScreen => 'काम की स्क्रीन खोलें';

  @override
  String get taskNotFound => 'यह काम अब उपलब्ध नहीं है।';

  @override
  String get errNotScheduledToday => 'यह काम आज के लिए तय नहीं है।';

  @override
  String errTooEarly(String time) {
    return 'आप यह काम $time से शुरू कर सकते हैं।';
  }

  @override
  String get errAnotherTaskActive => 'पहले अपना चालू काम पूरा करें।';

  @override
  String get errAlreadyCompleted => 'यह काम पहले ही पूरा हो चुका है।';

  @override
  String get errCancelled => 'यह काम आपके मैनेजर ने रद्द कर दिया है।';

  @override
  String get errLocationNotVerified => 'पहले अपनी लोकेशन जाँचें।';

  @override
  String get errInvalidAction => 'यह कार्रवाई अभी उपलब्ध नहीं है।';

  @override
  String get verifyTitle => 'लोकेशन जाँच';

  @override
  String get checkingLocation => 'आपकी लोकेशन जाँची जा रही है…';

  @override
  String get locationVerified => 'लोकेशन की पुष्टि हुई';

  @override
  String get atWorkLocation => 'आप काम की जगह पर हैं।';

  @override
  String get distance => 'दूरी';

  @override
  String get gpsAccuracy => 'GPS सटीकता';

  @override
  String get outsideTitle => 'आप काम के क्षेत्र से बाहर हैं';

  @override
  String get outsideBody => 'काम शुरू करने के लिए तय जगह के पास जाएँ।';

  @override
  String allowedRadius(String meters) {
    return 'अनुमति: $meters मी';
  }

  @override
  String get lowAccuracyTitle => 'GPS सिग्नल कमज़ोर है';

  @override
  String get lowAccuracyBody => 'खुली जगह पर जाएँ और फिर से कोशिश करें।';

  @override
  String get permissionDeniedTitle =>
      'काम शुरू करने के लिए लोकेशन की अनुमति ज़रूरी है।';

  @override
  String get allowLocation => 'लोकेशन की अनुमति दें';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get servicesDisabledTitle => 'लोकेशन सेवाएँ बंद हैं।';

  @override
  String get openLocationSettings => 'लोकेशन सेटिंग्स खोलें';

  @override
  String get locationTimeout => 'आपकी लोकेशन नहीं मिल सकी। फिर से कोशिश करें।';

  @override
  String get startWorkingTimer => 'काम का टाइमर शुरू करें';

  @override
  String get noActiveTaskTitle => 'कोई चालू काम नहीं';

  @override
  String get noActiveTaskBody => '\"मेरे काम\" से कोई काम शुरू करें।';

  @override
  String get workTime => 'काम का समय';

  @override
  String get breakTime => 'ब्रेक का समय';

  @override
  String get startedLabel => 'शुरू हुआ';

  @override
  String get locationLabel => 'लोकेशन';

  @override
  String get verified => 'पुष्टि हुई';

  @override
  String get stopAndStartBreak => 'रोकें और ब्रेक लें';

  @override
  String get resumeWorking => 'काम फिर शुरू करें';

  @override
  String get finishTask => 'काम पूरा करें';

  @override
  String get tapToBreak => 'ब्रेक लेने के लिए टैप करें';

  @override
  String get tapToResume => 'काम फिर शुरू करने के लिए टैप करें';

  @override
  String get earningsTitle => 'इस महीने';

  @override
  String get worksDoneThisMonth => 'पूरे किए काम (स्वीकृत)';

  @override
  String get earnedThisMonth => 'कमाई (स्वीकृत)';

  @override
  String get earningsApprovedOnly =>
      'सिर्फ़ मैनेजर द्वारा स्वीकृत काम गिने जाते हैं। भेजा गया काम स्वीकृति के बाद यहाँ जुड़ेगा।';

  @override
  String get earningsUnavailable =>
      'अभी लोड नहीं हुआ। ऑनलाइन होने पर \"मेरे काम\" में नीचे खींचकर रीफ़्रेश करें।';

  @override
  String get finishConfirmTitle => 'यह काम पूरा करें?';

  @override
  String get finishConfirmBody =>
      'अगले चरण में आप फ़ोटो जोड़कर काम भेजेंगे। भेजने तक टाइमर चलता रहेगा।';

  @override
  String get finish => 'पूरा करें';

  @override
  String get syncAllSent => 'सभी बदलाव भेज दिए गए';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम भेजे जाने बाकी',
      one: '1 आइटम भेजा जाना बाकी',
    );
    return '$_temp0';
  }

  @override
  String get syncFailedBanner => 'भेजना विफल रहा';

  @override
  String get syncOffline => 'ऑफ़लाइन — आपका काम इस फ़ोन पर सेव है';

  @override
  String get syncing => 'भेजा जा रहा है…';

  @override
  String get syncNow => 'अभी सिंक करें';

  @override
  String get completeTask => 'काम पूरा करें';

  @override
  String get summary => 'सारांश';

  @override
  String get taskLabel => 'काम';

  @override
  String get totalDuration => 'कुल अवधि';

  @override
  String get completionTime => 'पूरा होने का समय';

  @override
  String get materialsTitle => 'सामग्री';

  @override
  String get materialsInstalledHint => 'आपने क्या लगाया?';

  @override
  String get materialsDismantleHint =>
      'जो सामान वापस लाए वह दर्ज करें। अंतर को खोया हुआ माना जाएगा।';

  @override
  String get materialsInspectionHint => 'अगर कोई सामान ख़राब है तो दर्ज करें।';

  @override
  String get addMaterial => 'सामग्री जोड़ें';

  @override
  String get item => 'आइटम';

  @override
  String get quantity => 'मात्रा';

  @override
  String expectedQuantity(String quantity) {
    return 'अपेक्षित: $quantity';
  }

  @override
  String get materialsRequired => 'कम से कम एक सामग्री जोड़ें।';

  @override
  String get materialsUnavailable =>
      'सामग्री की सूची ऑफ़लाइन उपलब्ध नहीं है। ऑनलाइन होने पर फिर कोशिश करें।';

  @override
  String get checklistComingSoon =>
      'निरीक्षण चेकलिस्ट अगले संस्करण में जोड़ी जाएगी।';

  @override
  String get photosTitle => 'पूरे हुए काम की फ़ोटो';

  @override
  String get takePhoto => 'फ़ोटो लें';

  @override
  String get chooseFromGallery => 'गैलरी से चुनें';

  @override
  String photosRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'कम से कम $count फ़ोटो जोड़ें।',
      one: 'कम से कम 1 फ़ोटो जोड़ें।',
    );
    return '$_temp0';
  }

  @override
  String get uploadFailed => 'अपलोड विफल';

  @override
  String get removePhoto => 'फ़ोटो हटाएँ';

  @override
  String get commentTitle => 'टिप्पणी (वैकल्पिक)';

  @override
  String get commentHint => 'कोई बात जो आपके मैनेजर को पता होनी चाहिए';

  @override
  String get submitTask => 'काम भेजें';

  @override
  String get submitConfirmTitle => 'काम भेजें?';

  @override
  String get photos => 'फ़ोटो';

  @override
  String get materials => 'सामग्री';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '1 आइटम',
    );
    return '$_temp0';
  }

  @override
  String get movementInstalled => 'लगाया गया';

  @override
  String get movementRetrieved => 'वापस लाया गया';

  @override
  String get movementDamaged => 'ख़राब';

  @override
  String get movementLost => 'खोया';

  @override
  String get movementAdjustment => 'समायोजन';

  @override
  String get submittedTitle => 'काम भेज दिया गया ✓';

  @override
  String get submittedBody => 'आपका मैनेजर अब इसे देख सकता है।';

  @override
  String get savedOfflineTitle => 'काम सेव हो गया';

  @override
  String get savedOfflineBody => 'ऑनलाइन होते ही यह अपने आप भेज दिया जाएगा।';

  @override
  String get goToHistory => 'इतिहास पर जाएँ';

  @override
  String get historyTitle => 'इतिहास';

  @override
  String get historyEmptyTitle => 'अभी कोई पूरा काम नहीं';

  @override
  String get historyEmptyBody => 'भेजे गए काम यहाँ दिखेंगे।';

  @override
  String workingDuration(String duration) {
    return '$duration काम';
  }

  @override
  String completedAtTime(String time) {
    return '$time पर पूरा हुआ';
  }

  @override
  String get workAndBreaks => 'काम और ब्रेक';

  @override
  String get sessionWork => 'काम';

  @override
  String get sessionBreak => 'ब्रेक';

  @override
  String get completionLocation => 'पूरा होने की लोकेशन';

  @override
  String get comment => 'टिप्पणी';

  @override
  String get notRecorded => 'दर्ज नहीं';

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hoursघं $minutesमि';
  }

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get employeeId => 'कर्मचारी आईडी';

  @override
  String get phone => 'फ़ोन';

  @override
  String get company => 'कंपनी';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get notifications => 'सूचनाएँ';

  @override
  String get locationPermission => 'लोकेशन की अनुमति';

  @override
  String get cameraPermission => 'कैमरा की अनुमति';

  @override
  String get manageInSettings => 'सिस्टम सेटिंग्स में बदलें';

  @override
  String get language => 'भाषा';

  @override
  String get languageDevice => 'डिवाइस की भाषा';

  @override
  String get appVersion => 'ऐप संस्करण';

  @override
  String get unsyncedItems => 'बिना सिंक आइटम';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get logoutConfirmTitle => 'लॉग आउट करें?';

  @override
  String logoutUnsyncedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आपके $count आइटम सिंक नहीं हुए हैं।',
      one: 'आपका 1 आइटम सिंक नहीं हुआ है।',
    );
    return '$_temp0 वे इस फ़ोन पर रहेंगे और दोबारा लॉग इन करने पर भेजे जाएँगे।';
  }

  @override
  String get developer => 'डेवलपर (dev बिल्ड)';

  @override
  String get gpsSource => 'GPS स्रोत';

  @override
  String get simulateOffline => 'इंटरनेट न होने का अनुकरण';

  @override
  String get failNextUpload => 'अगला फ़ोटो अपलोड विफल करें';

  @override
  String get rejectNextCompletion => 'अगला सबमिशन अस्वीकार करें (409)';

  @override
  String get notificationsEmpty => 'कोई सूचना नहीं';

  @override
  String get errorNoInternet => 'इंटरनेट कनेक्शन नहीं है।';

  @override
  String get errorOfflineCached =>
      'आप ऑफ़लाइन हैं। सेव किए गए काम दिखाए जा रहे हैं।';

  @override
  String get errorServer => 'सर्वर पर कुछ गड़बड़ हुई।';

  @override
  String get errorGeneric => 'कुछ गड़बड़ हुई। फिर से कोशिश करें।';

  @override
  String get errTooManyAttempts =>
      'बहुत अधिक प्रयास। कुछ मिनट रुकें और फिर से कोशिश करें।';

  @override
  String get errAccountDisabled =>
      'आपका खाता बंद है। अपने मैनेजर से संपर्क करें।';

  @override
  String get errNotAWorker => 'यह खाता वर्कर ऐप का उपयोग नहीं कर सकता।';

  @override
  String get errWrongCurrentPassword => 'मौजूदा पासवर्ड गलत है।';

  @override
  String get errPasswordUnchanged =>
      'नया पासवर्ड मौजूदा पासवर्ड से अलग होना चाहिए।';

  @override
  String get errStartCheckMissing =>
      'इस काम के लिए शुरुआत की लोकेशन जाँच नहीं है।';

  @override
  String get errPhotosNotUploaded =>
      'कुछ फ़ोटो अभी अपलोड नहीं हुईं। उन्हें फिर से भेजा जाएगा।';

  @override
  String get errTimeOverlap =>
      'यह समय किसी दूसरे काम या ब्रेक के समय से टकराता है।';

  @override
  String get errNotCrewLead => 'सिर्फ़ टीम लीड सामग्री दर्ज कर सकता है।';

  @override
  String get errAlreadySavedDifferently =>
      'यह सर्वर पर पहले से अलग तरह से सेव है। अपने मैनेजर से संपर्क करें।';

  @override
  String get errorInvalidCredentials => 'गलत फ़ोन नंबर या पासवर्ड।';

  @override
  String requestId(String id) {
    return 'अनुरोध आईडी: $id';
  }
}
