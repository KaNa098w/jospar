// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class SKk extends S {
  SKk([String locale = 'kk']) : super(locale);

  @override
  String get settingsTheme => 'Тақырып';

  @override
  String get settingsNotifications => 'Хабарландырулар';

  @override
  String get settingsPrivacyPolicy => 'Құпиялылық саясаты';

  @override
  String get settingsVersion => 'Нұсқа';

  @override
  String get settingsBuild => 'Құрастырылым';

  @override
  String get today => 'Бүгін';

  @override
  String get tomorrow => 'Ертең';

  @override
  String get thisWeek => 'Аптада';

  @override
  String get thisMonth => 'Бір ай ішінде';

  @override
  String get later => 'Кейін';

  @override
  String get pickTaskList => 'Тапсырма тізімін таңда';

  @override
  String createTaskFailed(Object error) {
    return 'Тапсырманы жасау мүмкін болмады: $error';
  }

  @override
  String changeDateFailed(Object error) {
    return 'Күнді өзгерту мүмкін болмады: $error';
  }

  @override
  String get noTasksForDay => 'Бұл күнге тапсырма жоқ';

  @override
  String calendarTooltipToday(Object day) {
    return 'Бүгін $day';
  }

  @override
  String get menu => 'Мәзір';

  @override
  String get settings => 'Баптаулар';

  @override
  String get language => 'Тіл';

  @override
  String get monthJanuary => 'Қаңтар';

  @override
  String get monthFebruary => 'Ақпан';

  @override
  String get monthMarch => 'Наурыз';

  @override
  String get monthApril => 'Сәуір';

  @override
  String get monthMay => 'Мамыр';

  @override
  String get monthJune => 'Маусым';

  @override
  String get monthJuly => 'Шілде';

  @override
  String get monthAugust => 'Тамыз';

  @override
  String get monthSeptember => 'Қыркүйек';

  @override
  String get monthOctober => 'Қазан';

  @override
  String get monthNovember => 'Қараша';

  @override
  String get monthDecember => 'Желтоқсан';

  @override
  String get shortMonthJanuary => 'ҚАН';

  @override
  String get shortMonthFebruary => 'АҚП';

  @override
  String get shortMonthMarch => 'НАУ';

  @override
  String get shortMonthApril => 'СӘУ';

  @override
  String get shortMonthMay => 'МАМ';

  @override
  String get shortMonthJune => 'МАУ';

  @override
  String get shortMonthJuly => 'ШІЛ';

  @override
  String get shortMonthAugust => 'ТАМ';

  @override
  String get shortMonthSeptember => 'ҚЫР';

  @override
  String get shortMonthOctober => 'ҚАЗ';

  @override
  String get shortMonthNovember => 'ҚАР';

  @override
  String get shortMonthDecember => 'ЖЕЛ';

  @override
  String get shortWeekdayMonday => 'ДҮЙ';

  @override
  String get shortWeekdayTuesday => 'СЕЙ';

  @override
  String get shortWeekdayWednesday => 'СР';

  @override
  String get shortWeekdayThursday => 'БЕЙ';

  @override
  String get shortWeekdayFriday => 'ЖҰМ';

  @override
  String get shortWeekdaySaturday => 'СЕН';

  @override
  String get shortWeekdaySunday => 'ЖЕК';

  @override
  String get screenHome => 'Басты бет';

  @override
  String get screenTaskDiary => 'Тапсырмалар күнделігі';

  @override
  String get screenCart => 'Себет';

  @override
  String get taskTitle => 'Тапсырма атауы';

  @override
  String get addSubtask => 'Қосымша тапсырма қосу';

  @override
  String get subtaskTitle => 'Қосымша тапсырма атауы';

  @override
  String get delete => 'Жою';

  @override
  String get searchList => 'Тізімді іздеу';

  @override
  String get noTaskLists => 'Тапсырмалар тізімі жоқ — алдымен тізім жаса.';

  @override
  String get nothingFound => 'Ештеңе табылмады';

  @override
  String get untitled => 'Атаусыз';

  @override
  String get taskLists => 'ТАПСЫРМАЛАР ТІЗІМДЕРІ';

  @override
  String get listTitleHint => 'Тізім атауы';

  @override
  String get listHideFromHome => 'Басты бетте көрсетпеу';

  @override
  String get done => 'Дайын';

  @override
  String get reminderTitle => 'Еске салу';

  @override
  String get reminderSubtitle => 'Тапсырманы еске салатын уақытты таңдаңыз';

  @override
  String get hours => 'Сағат';

  @override
  String get minutes => 'Минут';

  @override
  String get morning => 'Таң';

  @override
  String get daytime => 'Күндіз';

  @override
  String get evening => 'Кеш';

  @override
  String get saveReminder => 'Еске салуды сақтау';

  @override
  String get removeReminder => 'Еске салуды жою';

  @override
  String get reminderNotificationTitle => 'Тапсырманы орындайтын уақыт келді';

  @override
  String get reminderTooltip => 'Еске салу';

  @override
  String get enterListTitle => 'Тізім атауын енгізіңіз';

  @override
  String get error => 'Қате';

  @override
  String get notes => 'Ескертпе';

  @override
  String get noTasksToday => 'Бұл күнге тапсырмалар жоқ';

  @override
  String get addTask => 'Тапсырма қосу';

  @override
  String get clearTrash => 'Себетті тазалау';

  @override
  String get sharedTasks => 'Ортақ тапсырмалар';

  @override
  String get developerModeEnabled => 'Сіз әзірлеуші болдыңыз';

  @override
  String get sharedProgress => 'Жалпы прогресс';

  @override
  String sharedProgressCount(Object completed, Object total) {
    return '$total тапсырманың $completed орындалды';
  }

  @override
  String subtasksProgress(Object completed, Object total) {
    return 'Қосымша тапсырмалар: $completed/$total';
  }

  @override
  String get participants => 'Қатысушылар';

  @override
  String get participant => 'Қатысушы';

  @override
  String get invite => 'Шақыру';

  @override
  String get edit => 'Өзгерту';

  @override
  String get refresh => 'Жаңарту';

  @override
  String get owner => 'Иесі';

  @override
  String get editor => 'Өңдеуші';

  @override
  String get viewer => 'Көруші';

  @override
  String get canEdit => 'Өзгерте алады';

  @override
  String get viewOnly => 'Тек көру';

  @override
  String get onlineNow => 'Қазір желіде';

  @override
  String get removeParticipant => 'Қатысушыны өшіру';

  @override
  String get leaveSharedTask => 'Ортақ тапсырмадан шығу';

  @override
  String get emptyParticipants => 'Қатысушылар тізімі бос';

  @override
  String get emptySharedTasks => 'Әзірге ортақ тапсырмалар жоқ';

  @override
  String get emptySharedTasksHint =>
      'Қатысушыларды шақырыңыз немесе шақыру сілтемесін қабылдаңыз — тапсырмалар осында пайда болады.';

  @override
  String get howToSendTask => 'Тапсырманы қалай жіберу керек?';

  @override
  String get subtasksIncluded =>
      'Қосымша тапсырмалар екі нұсқада да жіберіледі.';

  @override
  String get workTogether => 'Бірге жұмыс істеу';

  @override
  String get workTogetherHint => 'Өзгерістер барлық қатысушыға көрінеді';

  @override
  String get sendAsCopy => 'Көшірме ретінде жіберу';

  @override
  String get sendAsCopyHint =>
      'Алушы барлық қосымша тапсырмасы бар тәуелсіз тапсырманы алады';

  @override
  String get share => 'Бөлісу';

  @override
  String get sharedTaskSubject => 'Jospar ортақ тапсырмасы';

  @override
  String get taskCopySubject => 'Jospar тапсырмасының көшірмесі';

  @override
  String get signInToShare =>
      'Тапсырмамен бөлісу үшін алдымен жүйеге кіріңіз немесе тіркеліңіз.';

  @override
  String get syncNotReady =>
      'Синхрондау әлі дайын емес. Қолданбаны қайта іске қосыңыз.';

  @override
  String syncFailed(Object error) {
    return 'Соңғы өзгерістерді жіберу мүмкін болмады: $error';
  }

  @override
  String get tasksPendingSync =>
      'Тапсырма немесе оның қосымша тапсырмалары серверге әлі жіберілмеді. Интернетті тексеріп, қайталап көріңіз.';

  @override
  String get inviteLinkMissing => 'Сервер шақыру сілтемесін қайтармады.';

  @override
  String get sessionExpired => 'Сеанс аяқталды. Аккаунтқа қайта кіріңіз.';

  @override
  String inviteCreationFailed(Object error) {
    return 'Шақыру жасау мүмкін болмады: $error';
  }

  @override
  String taskSavedMessage(Object message) {
    return 'Тапсырма сақталды. $message';
  }

  @override
  String get taskSavedShareFailed =>
      'Тапсырма сақталды. Бөлісу мүмкін болмады: интернетті тексеріп, тапсырма карточкасынан қайталап көріңіз.';

  @override
  String get shareTaskFailed =>
      'Тапсырмамен бөлісу мүмкін болмады. Интернетті тексеріп, қайталап көріңіз.';

  @override
  String get openShareFailedTitle => 'Сілтемені ашу мүмкін болмады';

  @override
  String get sharedCopyAdded =>
      'Тапсырма және оның барлық қосымша тапсырмасы тәуелсіз көшірме ретінде қосылды.';

  @override
  String get shareSessionExpired =>
      'Сеанс аяқталды. Аккаунтқа кіріп, сілтемені қайта ашыңыз.';

  @override
  String get shareAccessDenied =>
      'Аккаунтыңызда бұл тапсырмаға кіру рұқсаты жоқ.';

  @override
  String get shareLinkUnavailable =>
      'Сілтеме табылмады, кері қайтарылды немесе жарамдылық мерзімі аяқталды.';

  @override
  String get shareAlreadyUsedMissingLocal =>
      'Сілтеме бұрын қолданылған, бірақ тапсырма бұл құрылғыдан табылмады. Синхрондаңыз немесе жаңа сілтеме сұраңыз.';

  @override
  String get unknownRetryError =>
      'Белгісіз қате. Интернетті тексеріп, қайталап көріңіз.';

  @override
  String get taskTitleRequired => 'Тапсырма атауын енгізіңіз.';

  @override
  String get selectTaskListForSave => 'Тапсырманы сақтайтын тізімді таңдаңыз.';

  @override
  String get taskSaveFailedTitle => 'Тапсырманы сақтау мүмкін болмады';

  @override
  String get synchronization => 'Синхрондау';

  @override
  String get syncNow => 'Синхрондау';

  @override
  String get syncInProgress => 'Синхрондалып жатыр…';

  @override
  String get syncSuccessful => 'Сәтті синхрондалды';

  @override
  String get syncFailedStatus => 'Синхрондау қатесі';

  @override
  String get syncNotRun => 'Әлі іске қосылмады';

  @override
  String get syncQueue => 'Жіберуді күтуде';

  @override
  String get syncQueueEmpty => 'Барлығы бэкендке жіберілді';

  @override
  String get syncHistory => 'Синхрондау тарихы';

  @override
  String get syncHistoryEmpty => 'Синхрондаудан кейін тарих осында көрінеді';

  @override
  String syncRetries(Object count) {
    return 'Әрекет саны: $count';
  }

  @override
  String get fallbackSyncEnabled => 'Резервтік синхрондау қосылды';

  @override
  String get websocketOnlyMode => 'Тек WebSocket: мерзімді синхрондау өшірілді';

  @override
  String get enableFastSync => 'Әр 2 секунд сайын синхрондауды қосу';

  @override
  String get fastSyncEnabled => 'Жылдам синхрондау қосылды: әр 2 секунд сайын';

  @override
  String get defaultSyncEnabled =>
      'Қалыпты синхрондау қосылды: әр 30 секунд сайын';

  @override
  String get realtimeConsole => 'WebSocket консолі';

  @override
  String get websocketConnected => 'WS қосылды';

  @override
  String get websocketDisconnected => 'WS ажыратылды';

  @override
  String get channelSubscribed => 'Арнаға жазылды';

  @override
  String get channelNotSubscribed => 'Жазылым жоқ';

  @override
  String get realtimeHistoryEmpty => 'Әзірге оқиғалар жоқ';

  @override
  String get subtaskDeleted => 'Қосалқы тапсырма жойылды';

  @override
  String get undo => 'Болдырмау';
}
