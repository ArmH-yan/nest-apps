// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Armenian (`hy`).
class AppLocalizationsHy extends AppLocalizations {
  AppLocalizationsHy([String locale = 'hy']) : super(locale);

  @override
  String get appTitle => 'NEST Worker';

  @override
  String get retry => 'Կրկնել';

  @override
  String get cancel => 'Չեղարկել';

  @override
  String get close => 'Փակել';

  @override
  String get ok => 'Լավ';

  @override
  String get open => 'Բացել';

  @override
  String get tryAgain => 'Կրկին փորձել';

  @override
  String get fieldRequired => 'Պարտադիր դաշտ';

  @override
  String get navTasks => 'Առաջադրանքներ';

  @override
  String get navWork => 'Աշխատանք';

  @override
  String get navHistory => 'Պատմություն';

  @override
  String get navProfile => 'Պրոֆիլ';

  @override
  String get loginSubtitle => 'Մուտք գործեք՝ ձեր առաջադրանքները տեսնելու համար';

  @override
  String get phoneLabel => 'Հեռախոսահամար';

  @override
  String get passwordLabel => 'Գաղտնաբառ';

  @override
  String get loginButton => 'Մուտք';

  @override
  String get forgotPassword => 'Մոռացե՞լ եք գաղտնաբառը';

  @override
  String get forgotPasswordBody =>
      'Գաղտնաբառը վերականգնելու համար դիմեք ձեր մենեջերին։';

  @override
  String get changePasswordTitle => 'Նոր գաղտնաբառ';

  @override
  String get changePasswordBody =>
      'Անվտանգության համար աշխատանքը սկսելուց առաջ ընտրեք նոր գաղտնաբառ։';

  @override
  String get currentPassword => 'Ընթացիկ գաղտնաբառ';

  @override
  String get newPassword => 'Նոր գաղտնաբառ';

  @override
  String get repeatPassword => 'Կրկնեք նոր գաղտնաբառը';

  @override
  String get passwordsDoNotMatch => 'Գաղտնաբառերը չեն համընկնում';

  @override
  String get passwordTooShort => 'Առնվազն 8 նիշ';

  @override
  String get savePassword => 'Պահպանել գաղտնաբառը';

  @override
  String get myTasks => 'Իմ առաջադրանքները';

  @override
  String get sectionToday => 'ԱՅՍՕՐ';

  @override
  String get sectionUpcoming => 'ԱՌԱՋԻԿԱ';

  @override
  String get sectionYesterday => 'ԵՐԵԿ';

  @override
  String get emptyTasksTitle => 'Նշանակված առաջադրանքներ չկան';

  @override
  String get emptyTasksBody => 'Մենեջերի նոր առաջադրանքները կհայտնվեն այստեղ։';

  @override
  String lastUpdated(String time) {
    return 'Թարմացվել է $time-ին';
  }

  @override
  String activeTaskBanner(String title) {
    return 'Դուք աշխատում եք՝ $title';
  }

  @override
  String get leadBadge => 'ԱՎԱԳ';

  @override
  String get today => 'Այսօր';

  @override
  String get tomorrow => 'Վաղը';

  @override
  String get statusUpcoming => 'ԱՌԱՋԻԿԱ';

  @override
  String get statusToday => 'ՊԱՏՐԱՍՏ Է ՍԿՍԵԼՈՒ';

  @override
  String get statusInProgress => 'ԱՇԽԱՏԱՆՔԻ ՄԵՋ';

  @override
  String get statusOnBreak => 'ԸՆԴՄԻՋՈՒՄ';

  @override
  String get statusWaiting => 'ՍՊԱՍՈՒՄ Է ՈՒՂԱՐԿՄԱՆ';

  @override
  String get statusSyncFailed => 'ՈՒՂԱՐԿՈՒՄԸ ՁԱԽՈՂՎԵՑ';

  @override
  String get statusCompleted => 'ԱՎԱՐՏՎԱԾ';

  @override
  String get statusCancelled => 'ՉԵՂԱՐԿՎԱԾ';

  @override
  String get jobSurvey => 'Տեղազննում';

  @override
  String get jobInstallation => 'Տեղադրում';

  @override
  String get jobInspection => 'Ստուգում';

  @override
  String get jobMaintenance => 'Սպասարկում';

  @override
  String get jobDismantling => 'Ապամոնտաժում';

  @override
  String get taskInformation => 'Առաջադրանքի տվյալներ';

  @override
  String get project => 'Նախագիծ';

  @override
  String get customer => 'Պատվիրատու';

  @override
  String get instructions => 'Հրահանգներ';

  @override
  String get scheduledDate => 'Ամսաթիվ';

  @override
  String get scheduledTime => 'Ժամ';

  @override
  String get yourRole => 'Ձեր դերը';

  @override
  String get roleLead => 'Բրիգադի ավագ';

  @override
  String get roleMember => 'Բրիգադի անդամ';

  @override
  String get crew => 'Բրիգադ';

  @override
  String get siteContact => 'Կոնտակտ օբյեկտում';

  @override
  String get workLocation => 'Աշխատանքի վայր';

  @override
  String get address => 'Հասցե';

  @override
  String get accessNotes => 'Մուտքի նշումներ';

  @override
  String get coordinates => 'Կոորդինատներ';

  @override
  String get workRadius => 'Աշխատանքային շառավիղ';

  @override
  String metersValue(String meters) {
    return '$meters մ';
  }

  @override
  String get currentDistance => 'Ձեր հեռավորությունը';

  @override
  String get navigate => 'Երթուղի';

  @override
  String get verifyMyLocation => 'Ստուգել իմ գտնվելու վայրը';

  @override
  String get openWorkScreen => 'Բացել աշխատանքի էկրանը';

  @override
  String get taskNotFound => 'Այս առաջադրանքն այլևս հասանելի չէ։';

  @override
  String get errNotScheduledToday =>
      'Այս առաջադրանքը նախատեսված չէ այսօրվա համար։';

  @override
  String errTooEarly(String time) {
    return 'Այս առաջադրանքը կարող եք սկսել $time-ից։';
  }

  @override
  String get errAnotherTaskActive => 'Նախ ավարտեք ընթացիկ առաջադրանքը։';

  @override
  String get errAlreadyCompleted => 'Այս առաջադրանքն արդեն ավարտված է։';

  @override
  String get errCancelled => 'Այս առաջադրանքը չեղարկվել է մենեջերի կողմից։';

  @override
  String get errLocationNotVerified => 'Նախ ստուգեք ձեր գտնվելու վայրը։';

  @override
  String get errInvalidAction => 'Այս գործողությունը հիմա հասանելի չէ։';

  @override
  String get verifyTitle => 'Վայրի ստուգում';

  @override
  String get checkingLocation => 'Ստուգում ենք ձեր գտնվելու վայրը…';

  @override
  String get locationVerified => 'Վայրը հաստատված է';

  @override
  String get atWorkLocation => 'Դուք աշխատանքի վայրում եք։';

  @override
  String get distance => 'Հեռավորություն';

  @override
  String get gpsAccuracy => 'GPS ճշտություն';

  @override
  String get outsideTitle => 'Դուք աշխատանքային տարածքից դուրս եք';

  @override
  String get outsideBody =>
      'Մոտեցեք նշանակված աշխատանքի վայրին՝ աշխատանքը սկսելու համար։';

  @override
  String allowedRadius(String meters) {
    return 'Թույլատրելի՝ $meters մ';
  }

  @override
  String get lowAccuracyTitle => 'GPS ազդանշանը թույլ է';

  @override
  String get lowAccuracyBody => 'Դուրս եկեք բաց տարածք և կրկին փորձեք։';

  @override
  String get permissionDeniedTitle =>
      'Աշխատանքը սկսելու համար անհրաժեշտ է գտնվելու վայրի թույլտվություն։';

  @override
  String get allowLocation => 'Թույլատրել';

  @override
  String get openSettings => 'Բացել կարգավորումները';

  @override
  String get servicesDisabledTitle =>
      'Գտնվելու վայրի ծառայություններն անջատված են։';

  @override
  String get openLocationSettings => 'Բացել վայրի կարգավորումները';

  @override
  String get locationTimeout =>
      'Չհաջողվեց որոշել ձեր գտնվելու վայրը։ Կրկին փորձեք։';

  @override
  String get startWorkingTimer => 'Սկսել աշխատանքի ժամաչափը';

  @override
  String get noActiveTaskTitle => 'Ակտիվ առաջադրանք չկա';

  @override
  String get noActiveTaskBody =>
      'Սկսեք առաջադրանքը «Իմ առաջադրանքները» բաժնից։';

  @override
  String get workTime => 'ԱՇԽԱՏԱՆՔԱՅԻՆ ԺԱՄԱՆԱԿ';

  @override
  String get breakTime => 'ԸՆԴՄԻՋՄԱՆ ԺԱՄԱՆԱԿ';

  @override
  String get startedLabel => 'ՍԿՍՎԵԼ Է';

  @override
  String get locationLabel => 'ՎԱՅՐ';

  @override
  String get verified => 'Հաստատված';

  @override
  String get stopAndStartBreak => 'ԴԱԴԱՐ ԵՎ ԸՆԴՄԻՋՈՒՄ';

  @override
  String get resumeWorking => 'ՇԱՐՈՒՆԱԿԵԼ ԱՇԽԱՏԱՆՔԸ';

  @override
  String get finishTask => 'ԱՎԱՐՏԵԼ ԱՌԱՋԱԴՐԱՆՔԸ';

  @override
  String get tapToBreak => 'Սեղմեք՝ ընդմիջման համար';

  @override
  String get tapToResume => 'Սեղմեք՝ աշխատանքը շարունակելու համար';

  @override
  String get earningsTitle => 'Այս ամիս';

  @override
  String get worksDoneThisMonth => 'Կատարված աշխատանքներ (հաստատված)';

  @override
  String get earnedThisMonth => 'Վաստակած (հաստատված)';

  @override
  String get earningsApprovedOnly =>
      'Հաշվվում են միայն մենեջերի կողմից հաստատված առաջադրանքները։ Ուղարկված առաջադրանքը կավելանա այստեղ հաստատումից հետո։';

  @override
  String get earningsUnavailable =>
      'Տվյալները դեռ բեռնված չեն։ Առցանց լինելիս «Իմ առաջադրանքները» էկրանին քաշեք ներքև՝ թարմացնելու համար։';

  @override
  String get finishConfirmTitle => 'Ավարտե՞լ առաջադրանքը';

  @override
  String get finishConfirmBody =>
      'Հաջորդ քայլում կավելացնեք լուսանկարներ և կուղարկեք։ Ժամաչափն աշխատում է մինչև ուղարկելը։';

  @override
  String get finish => 'Ավարտել';

  @override
  String get syncAllSent => 'Բոլոր փոփոխություններն ուղարկված են';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count տարր սպասում է ուղարկման',
      one: '1 տարր սպասում է ուղարկման',
    );
    return '$_temp0';
  }

  @override
  String get syncFailedBanner => 'Ուղարկումը ձախողվեց';

  @override
  String get syncOffline => 'Ցանց չկա — ձեր աշխատանքը պահպանված է հեռախոսում';

  @override
  String get syncing => 'Ուղարկում…';

  @override
  String get syncNow => 'Ուղարկել հիմա';

  @override
  String get completeTask => 'Առաջադրանքի ավարտ';

  @override
  String get summary => 'Ամփոփում';

  @override
  String get taskLabel => 'Առաջադրանք';

  @override
  String get totalDuration => 'Ընդհանուր տևողություն';

  @override
  String get completionTime => 'Ավարտի ժամ';

  @override
  String get materialsTitle => 'Նյութեր';

  @override
  String get materialsInstalledHint => 'Ի՞նչ եք տեղադրել։';

  @override
  String get materialsDismantleHint =>
      'Նշեք, թե ինչ եք հետ բերել։ Տարբերությունը կգրանցվի որպես կորուստ։';

  @override
  String get materialsInspectionHint => 'Նշեք վնասված տարրերը, եթե կան։';

  @override
  String get addMaterial => 'Ավելացնել նյութ';

  @override
  String get item => 'Անվանում';

  @override
  String get quantity => 'Քանակ';

  @override
  String expectedQuantity(String quantity) {
    return 'Սպասվող՝ $quantity';
  }

  @override
  String get materialsRequired => 'Ավելացրեք առնվազն մեկ նյութ։';

  @override
  String get materialsUnavailable =>
      'Նյութերի ցանկը հասանելի չէ առանց ցանցի։ Կրկին փորձեք, երբ ցանց լինի։';

  @override
  String get checklistComingSoon =>
      'Ստուգման ցուցակը կավելացվի հաջորդ տարբերակներում։';

  @override
  String get photosTitle => 'Կատարված աշխատանքի լուսանկարներ';

  @override
  String get takePhoto => 'Լուսանկարել';

  @override
  String get chooseFromGallery => 'Ընտրել պատկերասրահից';

  @override
  String photosRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ավելացրեք առնվազն $count լուսանկար։',
      one: 'Ավելացրեք առնվազն 1 լուսանկար։',
    );
    return '$_temp0';
  }

  @override
  String get uploadFailed => 'Վերբեռնումը ձախողվեց';

  @override
  String get removePhoto => 'Ջնջել լուսանկարը';

  @override
  String get commentTitle => 'Մեկնաբանություն (ըստ ցանկության)';

  @override
  String get commentHint => 'Ինչ պետք է իմանա ձեր մենեջերը';

  @override
  String get submitTask => 'Ուղարկել առաջադրանքը';

  @override
  String get submitConfirmTitle => 'Ուղարկե՞լ առաջադրանքը';

  @override
  String get photos => 'Լուսանկարներ';

  @override
  String get materials => 'Նյութեր';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count տարր',
      one: '1 տարր',
    );
    return '$_temp0';
  }

  @override
  String get movementInstalled => 'Տեղադրված';

  @override
  String get movementRetrieved => 'Հետ բերված';

  @override
  String get movementDamaged => 'Վնասված';

  @override
  String get movementLost => 'Կորած';

  @override
  String get movementAdjustment => 'Ճշգրտում';

  @override
  String get submittedTitle => 'Առաջադրանքն ուղարկված է ✓';

  @override
  String get submittedBody => 'Ձեր մենեջերն արդեն տեսնում է այն։';

  @override
  String get savedOfflineTitle => 'Առաջադրանքը պահպանված է';

  @override
  String get savedOfflineBody => 'Այն ավտոմատ կուղարկվի, երբ ցանց լինի։';

  @override
  String get goToHistory => 'Անցնել պատմությանը';

  @override
  String get historyTitle => 'Պատմություն';

  @override
  String get historyEmptyTitle => 'Ավարտված առաջադրանքներ դեռ չկան';

  @override
  String get historyEmptyBody => 'Ուղարկված առաջադրանքները կհայտնվեն այստեղ։';

  @override
  String workingDuration(String duration) {
    return '$duration աշխատանք';
  }

  @override
  String completedAtTime(String time) {
    return 'Ավարտվել է $time-ին';
  }

  @override
  String get workAndBreaks => 'Աշխատանք և ընդմիջումներ';

  @override
  String get sessionWork => 'Աշխատանք';

  @override
  String get sessionBreak => 'Ընդմիջում';

  @override
  String get completionLocation => 'Ավարտի վայր';

  @override
  String get comment => 'Մեկնաբանություն';

  @override
  String get notRecorded => 'Գրանցված չէ';

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hoursժ $minutesր';
  }

  @override
  String get profileTitle => 'Պրոֆիլ';

  @override
  String get employeeId => 'Աշխատակցի ID';

  @override
  String get phone => 'Հեռախոս';

  @override
  String get company => 'Ընկերություն';

  @override
  String get settings => 'Կարգավորումներ';

  @override
  String get notifications => 'Ծանուցումներ';

  @override
  String get locationPermission => 'Գտնվելու վայրի թույլտվություն';

  @override
  String get cameraPermission => 'Տեսախցիկի թույլտվություն';

  @override
  String get manageInSettings => 'Կառավարել համակարգի կարգավորումներում';

  @override
  String get language => 'Լեզու';

  @override
  String get languageDevice => 'Սարքի լեզու';

  @override
  String get appVersion => 'Հավելվածի տարբերակ';

  @override
  String get unsyncedItems => 'Չուղարկված տարրեր';

  @override
  String get logout => 'Ելք';

  @override
  String get logoutConfirmTitle => 'Դուրս գա՞լ';

  @override
  String logoutUnsyncedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ունեք $count չուղարկված տարր։',
      one: 'Ունեք 1 չուղարկված տարր։',
    );
    return '$_temp0 Այն կմնա հեռախոսում և կուղարկվի կրկին մուտք գործելուց հետո։';
  }

  @override
  String get developer => 'Մշակողի համար (dev)';

  @override
  String get gpsSource => 'GPS աղբյուր';

  @override
  String get simulateOffline => 'Մոդելավորել ցանցի բացակայություն';

  @override
  String get failNextUpload => 'Ձախողել հաջորդ լուսանկարի վերբեռնումը';

  @override
  String get rejectNextCompletion => 'Մերժել հաջորդ ուղարկումը (409)';

  @override
  String get notificationsEmpty => 'Ծանուցումներ չկան';

  @override
  String get errorNoInternet => 'Ինտերնետ կապ չկա։';

  @override
  String get errorOfflineCached =>
      'Ցանց չկա։ Ցուցադրվում են պահպանված առաջադրանքները։';

  @override
  String get errorServer => 'Սերվերում սխալ է տեղի ունեցել։';

  @override
  String get errorGeneric => 'Ինչ-որ բան սխալ գնաց։ Կրկին փորձեք։';

  @override
  String get errorInvalidCredentials => 'Սխալ հեռախոսահամար կամ գաղտնաբառ։';

  @override
  String requestId(String id) {
    return 'Հարցման ID՝ $id';
  }
}
