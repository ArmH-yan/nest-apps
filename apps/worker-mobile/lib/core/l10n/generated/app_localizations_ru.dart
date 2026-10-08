// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'NEST Worker';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get ok => 'ОК';

  @override
  String get open => 'Открыть';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get fieldRequired => 'Обязательное поле';

  @override
  String get navTasks => 'Задачи';

  @override
  String get navWork => 'Работа';

  @override
  String get navHistory => 'История';

  @override
  String get navProfile => 'Профиль';

  @override
  String get loginSubtitle => 'Войдите, чтобы увидеть свои задачи';

  @override
  String get phoneLabel => 'Номер телефона';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get loginButton => 'Войти';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get forgotPasswordBody =>
      'Чтобы восстановить пароль, обратитесь к своему менеджеру.';

  @override
  String get changePasswordTitle => 'Новый пароль';

  @override
  String get changePasswordBody =>
      'Для безопасности выберите новый пароль перед началом работы.';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get repeatPassword => 'Повторите новый пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get passwordTooShort => 'Минимум 8 символов';

  @override
  String get savePassword => 'Сохранить пароль';

  @override
  String get myTasks => 'Мои задачи';

  @override
  String get sectionToday => 'СЕГОДНЯ';

  @override
  String get sectionUpcoming => 'ПРЕДСТОЯЩИЕ';

  @override
  String get sectionYesterday => 'ВЧЕРА';

  @override
  String get emptyTasksTitle => 'Нет назначенных задач';

  @override
  String get emptyTasksBody => 'Новые задачи от менеджера появятся здесь.';

  @override
  String lastUpdated(String time) {
    return 'Обновлено в $time';
  }

  @override
  String activeTaskBanner(String title) {
    return 'Вы работаете над: $title';
  }

  @override
  String get leadBadge => 'СТАРШИЙ';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get statusUpcoming => 'ПРЕДСТОИТ';

  @override
  String get statusToday => 'МОЖНО НАЧИНАТЬ';

  @override
  String get statusInProgress => 'В РАБОТЕ';

  @override
  String get statusOnBreak => 'ПЕРЕРЫВ';

  @override
  String get statusWaiting => 'ОЖИДАЕТ ОТПРАВКИ';

  @override
  String get statusSyncFailed => 'ОШИБКА ОТПРАВКИ';

  @override
  String get statusCompleted => 'ЗАВЕРШЕНА';

  @override
  String get statusCancelled => 'ОТМЕНЕНА';

  @override
  String get jobSurvey => 'Осмотр объекта';

  @override
  String get jobInstallation => 'Монтаж';

  @override
  String get jobInspection => 'Проверка';

  @override
  String get jobMaintenance => 'Обслуживание';

  @override
  String get jobDismantling => 'Демонтаж';

  @override
  String get taskInformation => 'Информация о задаче';

  @override
  String get project => 'Проект';

  @override
  String get customer => 'Заказчик';

  @override
  String get instructions => 'Инструкции';

  @override
  String get scheduledDate => 'Дата';

  @override
  String get scheduledTime => 'Время';

  @override
  String get yourRole => 'Ваша роль';

  @override
  String get roleLead => 'Старший бригады';

  @override
  String get roleMember => 'Член бригады';

  @override
  String get crew => 'Бригада';

  @override
  String get siteContact => 'Контакт на объекте';

  @override
  String get workLocation => 'Место работы';

  @override
  String get address => 'Адрес';

  @override
  String get accessNotes => 'Как пройти';

  @override
  String get coordinates => 'Координаты';

  @override
  String get workRadius => 'Рабочий радиус';

  @override
  String metersValue(String meters) {
    return '$meters м';
  }

  @override
  String get currentDistance => 'Ваше расстояние';

  @override
  String get navigate => 'Маршрут';

  @override
  String get verifyMyLocation => 'Проверить местоположение';

  @override
  String get openWorkScreen => 'Открыть экран работы';

  @override
  String get taskNotFound => 'Эта задача больше недоступна.';

  @override
  String get errNotScheduledToday => 'Эта задача не запланирована на сегодня.';

  @override
  String errTooEarly(String time) {
    return 'Эту задачу можно начать с $time.';
  }

  @override
  String get errAnotherTaskActive => 'Сначала завершите текущую задачу.';

  @override
  String get errAlreadyCompleted => 'Эта задача уже завершена.';

  @override
  String get errCancelled => 'Эта задача отменена менеджером.';

  @override
  String get errLocationNotVerified => 'Сначала проверьте местоположение.';

  @override
  String get errInvalidAction => 'Это действие сейчас недоступно.';

  @override
  String get verifyTitle => 'Проверка местоположения';

  @override
  String get checkingLocation => 'Проверяем ваше местоположение…';

  @override
  String get locationVerified => 'Местоположение подтверждено';

  @override
  String get atWorkLocation => 'Вы находитесь на месте работы.';

  @override
  String get distance => 'Расстояние';

  @override
  String get gpsAccuracy => 'Точность GPS';

  @override
  String get outsideTitle => 'Вы вне рабочей зоны';

  @override
  String get outsideBody => 'Подойдите ближе к месту работы, чтобы начать.';

  @override
  String allowedRadius(String meters) {
    return 'Допустимо: $meters м';
  }

  @override
  String get lowAccuracyTitle => 'Слабый сигнал GPS';

  @override
  String get lowAccuracyBody => 'Выйдите на открытое место и попробуйте снова.';

  @override
  String get permissionDeniedTitle =>
      'Для начала работы нужен доступ к местоположению.';

  @override
  String get allowLocation => 'Разрешить';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get servicesDisabledTitle => 'Службы геолокации отключены.';

  @override
  String get openLocationSettings => 'Открыть настройки геолокации';

  @override
  String get locationTimeout =>
      'Не удалось определить местоположение. Попробуйте снова.';

  @override
  String get startWorkingTimer => 'Запустить таймер работы';

  @override
  String get noActiveTaskTitle => 'Нет активной задачи';

  @override
  String get noActiveTaskBody => 'Начните задачу в разделе «Мои задачи».';

  @override
  String get workTime => 'ВРЕМЯ РАБОТЫ';

  @override
  String get breakTime => 'ВРЕМЯ ПЕРЕРЫВА';

  @override
  String get startedLabel => 'НАЧАЛО';

  @override
  String get locationLabel => 'МЕСТО';

  @override
  String get verified => 'Подтверждено';

  @override
  String get stopAndStartBreak => 'СТОП И ПЕРЕРЫВ';

  @override
  String get resumeWorking => 'ПРОДОЛЖИТЬ РАБОТУ';

  @override
  String get finishTask => 'ЗАВЕРШИТЬ ЗАДАЧУ';

  @override
  String get tapToBreak => 'Нажмите, чтобы начать перерыв';

  @override
  String get tapToResume => 'Нажмите, чтобы продолжить работу';

  @override
  String get earningsTitle => 'Этот месяц';

  @override
  String get worksDoneThisMonth => 'Выполнено работ (утверждено)';

  @override
  String get earnedThisMonth => 'Заработано (утверждено)';

  @override
  String get earningsApprovedOnly =>
      'Учитываются только задачи, утверждённые менеджером. Отправленная задача появится здесь после утверждения.';

  @override
  String get earningsUnavailable =>
      'Данные ещё не загружены. Потяните вниз на экране «Мои задачи», когда будете онлайн.';

  @override
  String get finishConfirmTitle => 'Завершить задачу?';

  @override
  String get finishConfirmBody =>
      'Дальше вы добавите фото и отправите задачу. Таймер идёт до отправки.';

  @override
  String get finish => 'Завершить';

  @override
  String get syncAllSent => 'Все изменения отправлены';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элементов ждут отправки',
      few: '$count элемента ждут отправки',
      one: '1 элемент ждёт отправки',
    );
    return '$_temp0';
  }

  @override
  String get syncFailedBanner => 'Ошибка отправки';

  @override
  String get syncOffline => 'Нет сети — работа сохранена на телефоне';

  @override
  String get syncing => 'Отправка…';

  @override
  String get syncNow => 'Отправить сейчас';

  @override
  String get completeTask => 'Завершение задачи';

  @override
  String get summary => 'Итог';

  @override
  String get taskLabel => 'Задача';

  @override
  String get totalDuration => 'Общая длительность';

  @override
  String get completionTime => 'Время завершения';

  @override
  String get materialsTitle => 'Материалы';

  @override
  String get materialsInstalledHint => 'Что вы установили?';

  @override
  String get materialsDismantleHint =>
      'Укажите, что вы забрали. Разница будет учтена как потеря.';

  @override
  String get materialsInspectionHint =>
      'Отметьте повреждённые элементы, если есть.';

  @override
  String get addMaterial => 'Добавить материал';

  @override
  String get item => 'Наименование';

  @override
  String get quantity => 'Количество';

  @override
  String expectedQuantity(String quantity) {
    return 'Ожидается: $quantity';
  }

  @override
  String get materialsRequired => 'Добавьте хотя бы один материал.';

  @override
  String get materialsUnavailable =>
      'Список материалов недоступен без сети. Попробуйте, когда появится сеть.';

  @override
  String get checklistComingSoon =>
      'Чек-лист проверки будет добавлен в следующих версиях.';

  @override
  String get photosTitle => 'Фото выполненной работы';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get chooseFromGallery => 'Выбрать из галереи';

  @override
  String photosRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавьте хотя бы $count фото.',
      one: 'Добавьте хотя бы 1 фото.',
    );
    return '$_temp0';
  }

  @override
  String get uploadFailed => 'Ошибка загрузки';

  @override
  String get removePhoto => 'Удалить фото';

  @override
  String get commentTitle => 'Комментарий (необязательно)';

  @override
  String get commentHint => 'Что должен знать ваш менеджер';

  @override
  String get submitTask => 'Отправить задачу';

  @override
  String get submitConfirmTitle => 'Отправить задачу?';

  @override
  String get photos => 'Фото';

  @override
  String get materials => 'Материалы';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count позиций',
      few: '$count позиции',
      one: '1 позиция',
    );
    return '$_temp0';
  }

  @override
  String get movementInstalled => 'Установлено';

  @override
  String get movementRetrieved => 'Забрано';

  @override
  String get movementDamaged => 'Повреждено';

  @override
  String get movementLost => 'Утеряно';

  @override
  String get movementAdjustment => 'Корректировка';

  @override
  String get submittedTitle => 'Задача отправлена ✓';

  @override
  String get submittedBody => 'Менеджер уже видит её.';

  @override
  String get savedOfflineTitle => 'Задача сохранена';

  @override
  String get savedOfflineBody =>
      'Она будет отправлена автоматически, когда появится сеть.';

  @override
  String get goToHistory => 'Перейти в историю';

  @override
  String get historyTitle => 'История';

  @override
  String get historyEmptyTitle => 'Завершённых задач пока нет';

  @override
  String get historyEmptyBody => 'Отправленные задачи появятся здесь.';

  @override
  String workingDuration(String duration) {
    return '$duration работы';
  }

  @override
  String completedAtTime(String time) {
    return 'Завершено в $time';
  }

  @override
  String get workAndBreaks => 'Работа и перерывы';

  @override
  String get sessionWork => 'Работа';

  @override
  String get sessionBreak => 'Перерыв';

  @override
  String get completionLocation => 'Место завершения';

  @override
  String get comment => 'Комментарий';

  @override
  String get notRecorded => 'Не записано';

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String get profileTitle => 'Профиль';

  @override
  String get employeeId => 'Табельный номер';

  @override
  String get phone => 'Телефон';

  @override
  String get company => 'Компания';

  @override
  String get settings => 'Настройки';

  @override
  String get notifications => 'Уведомления';

  @override
  String get locationPermission => 'Доступ к местоположению';

  @override
  String get cameraPermission => 'Доступ к камере';

  @override
  String get manageInSettings => 'Управлять в системных настройках';

  @override
  String get language => 'Язык';

  @override
  String get languageDevice => 'Язык устройства';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get unsyncedItems => 'Неотправленные элементы';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirmTitle => 'Выйти?';

  @override
  String logoutUnsyncedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У вас $count неотправленных элементов.',
      few: 'У вас $count неотправленных элемента.',
      one: 'У вас 1 неотправленный элемент.',
    );
    return '$_temp0 Данные останутся на телефоне и будут отправлены после повторного входа.';
  }

  @override
  String get developer => 'Для разработчика (dev)';

  @override
  String get gpsSource => 'Источник GPS';

  @override
  String get simulateOffline => 'Имитировать отсутствие сети';

  @override
  String get failNextUpload => 'Сорвать следующую загрузку фото';

  @override
  String get rejectNextCompletion => 'Отклонить следующую отправку (409)';

  @override
  String get notificationsEmpty => 'Нет уведомлений';

  @override
  String get errorNoInternet => 'Нет подключения к интернету.';

  @override
  String get errorOfflineCached => 'Нет сети. Показаны сохранённые задачи.';

  @override
  String get errorServer => 'На сервере произошла ошибка.';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте снова.';

  @override
  String get errorInvalidCredentials => 'Неверный номер телефона или пароль.';

  @override
  String requestId(String id) {
    return 'ID запроса: $id';
  }
}
