// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SRu extends S {
  SRu([String locale = 'ru']) : super(locale);

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get thisWeek => 'На неделе';

  @override
  String get thisMonth => 'В течение месяца';

  @override
  String get later => 'Потом';

  @override
  String get pickTaskList => 'Выбери список задач';

  @override
  String createTaskFailed(Object error) {
    return 'Не удалось создать задачу: $error';
  }

  @override
  String changeDateFailed(Object error) {
    return 'Не удалось изменить дату: $error';
  }

  @override
  String get noTasksForDay => 'На этот день задач нет';

  @override
  String calendarTooltipToday(Object day) {
    return 'Сегодня $day';
  }

  @override
  String get menu => 'Меню';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get monthJanuary => 'Января';

  @override
  String get monthFebruary => 'Февраля';

  @override
  String get monthMarch => 'Марта';

  @override
  String get monthApril => 'Апреля';

  @override
  String get monthMay => 'Мая';

  @override
  String get monthJune => 'Июня';

  @override
  String get monthJuly => 'Июля';

  @override
  String get monthAugust => 'Августа';

  @override
  String get monthSeptember => 'Сентября';

  @override
  String get monthOctober => 'Октября';

  @override
  String get monthNovember => 'Ноября';

  @override
  String get monthDecember => 'Декабря';

  @override
  String get shortMonthJanuary => 'ЯНВ';

  @override
  String get shortMonthFebruary => 'ФЕВ';

  @override
  String get shortMonthMarch => 'МАР';

  @override
  String get shortMonthApril => 'АПР';

  @override
  String get shortMonthMay => 'МАЙ';

  @override
  String get shortMonthJune => 'ИЮН';

  @override
  String get shortMonthJuly => 'ИЮЛ';

  @override
  String get shortMonthAugust => 'АВГ';

  @override
  String get shortMonthSeptember => 'СЕН';

  @override
  String get shortMonthOctober => 'ОКТ';

  @override
  String get shortMonthNovember => 'НОЯ';

  @override
  String get shortMonthDecember => 'ДЕК';

  @override
  String get shortWeekdayMonday => 'ПН';

  @override
  String get shortWeekdayTuesday => 'ВТ';

  @override
  String get shortWeekdayWednesday => 'СР';

  @override
  String get shortWeekdayThursday => 'ЧТ';

  @override
  String get shortWeekdayFriday => 'ПТ';

  @override
  String get shortWeekdaySaturday => 'СБ';

  @override
  String get shortWeekdaySunday => 'ВС';

  @override
  String get screenHome => 'Главный экран';

  @override
  String get screenTaskDiary => 'Дневник задач';

  @override
  String get screenCart => 'Корзина';

  @override
  String get taskTitle => 'Название задачи';

  @override
  String get addSubtask => 'Добавить подзадачу';

  @override
  String get subtaskTitle => 'Название подзадачи';

  @override
  String get delete => 'Удалить';

  @override
  String get searchList => 'Поиск списка';

  @override
  String get noTaskLists => 'Нет списков задач — сначала создай список.';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get untitled => 'Без названия';

  @override
  String get taskLists => 'СПИСКИ ЗАДАЧ';

  @override
  String get listTitleHint => 'Название списка';

  @override
  String get listHideFromHome => 'Не показывать на главном';

  @override
  String get done => 'Готово';

  @override
  String get reminderTitle => 'Напоминание';

  @override
  String get reminderSubtitle => 'Выберите время, когда напомнить о задаче';

  @override
  String get hours => 'Часы';

  @override
  String get minutes => 'Минуты';

  @override
  String get morning => 'Утро';

  @override
  String get daytime => 'День';

  @override
  String get evening => 'Вечер';

  @override
  String get saveReminder => 'Сохранить напоминание';

  @override
  String get removeReminder => 'Удалить напоминание';

  @override
  String get reminderNotificationTitle => 'Пора выполнить задачу';

  @override
  String get reminderTooltip => 'Напоминание';

  @override
  String get enterListTitle => 'Введите название списка';

  @override
  String get error => 'Ошибка';

  @override
  String get notes => 'Заметки';

  @override
  String get noTasksToday => 'На этот день нет задач';

  @override
  String get addTask => 'Добавить задачу';

  @override
  String get clearTrash => 'Очистить корзину';

  @override
  String get sharedTasks => 'Совместные задачи';

  @override
  String get sharedProgress => 'Общий прогресс';

  @override
  String sharedProgressCount(Object completed, Object total) {
    return '$completed из $total выполнено';
  }

  @override
  String subtasksProgress(Object completed, Object total) {
    return 'Подзадачи: $completed/$total';
  }

  @override
  String get participants => 'Участники';

  @override
  String get participant => 'Участник';

  @override
  String get invite => 'Пригласить';

  @override
  String get edit => 'Изменить';

  @override
  String get refresh => 'Обновить';

  @override
  String get owner => 'Владелец';

  @override
  String get editor => 'Редактор';

  @override
  String get viewer => 'Просмотр';

  @override
  String get canEdit => 'Может изменять';

  @override
  String get viewOnly => 'Только просмотр';

  @override
  String get onlineNow => 'Сейчас онлайн';

  @override
  String get removeParticipant => 'Удалить участника';

  @override
  String get leaveSharedTask => 'Покинуть совместную задачу';

  @override
  String get emptyParticipants => 'Список участников пуст';

  @override
  String get emptySharedTasks => 'Пока нет совместных задач';

  @override
  String get emptySharedTasksHint =>
      'Пригласите участников или примите ссылку — задачи появятся здесь.';

  @override
  String get howToSendTask => 'Как отправить задачу?';

  @override
  String get subtasksIncluded => 'Подзадачи будут переданы в обоих вариантах.';

  @override
  String get workTogether => 'Работать совместно';

  @override
  String get workTogetherHint => 'Изменения будут видны всем участникам';

  @override
  String get sendAsCopy => 'Отправить как копию';

  @override
  String get sendAsCopyHint =>
      'Получатель получит независимую задачу со всеми подзадачами';

  @override
  String get share => 'Поделиться';

  @override
  String get sharedTaskSubject => 'Совместная задача Jospar';

  @override
  String get taskCopySubject => 'Копия задачи Jospar';

  @override
  String get signInToShare =>
      'Чтобы поделиться задачей, сначала войдите или зарегистрируйтесь.';

  @override
  String get syncNotReady =>
      'Синхронизация ещё не готова. Перезапустите приложение.';

  @override
  String syncFailed(Object error) {
    return 'Не удалось отправить последние изменения: $error';
  }

  @override
  String get tasksPendingSync =>
      'Задача или её подзадачи ещё не отправлены на сервер. Проверьте интернет и попробуйте снова.';

  @override
  String get inviteLinkMissing => 'Сервер не вернул ссылку приглашения.';

  @override
  String get sessionExpired => 'Сессия истекла. Войдите в аккаунт ещё раз.';

  @override
  String inviteCreationFailed(Object error) {
    return 'Не удалось создать приглашение: $error';
  }

  @override
  String taskSavedMessage(Object message) {
    return 'Задача сохранена. $message';
  }

  @override
  String get taskSavedShareFailed =>
      'Задача сохранена. Не удалось поделиться: проверьте интернет и повторите попытку из карточки задачи.';

  @override
  String get shareTaskFailed =>
      'Не удалось поделиться задачей. Проверьте интернет и повторите попытку.';

  @override
  String get openShareFailedTitle => 'Не удалось открыть ссылку';

  @override
  String get sharedCopyAdded =>
      'Задача и все её подзадачи добавлены как независимая копия.';

  @override
  String get shareSessionExpired =>
      'Сессия истекла. Войдите в аккаунт и откройте ссылку ещё раз.';

  @override
  String get shareAccessDenied =>
      'У вашего аккаунта нет доступа к этой задаче.';

  @override
  String get shareLinkUnavailable =>
      'Ссылка не найдена, была отозвана или срок её действия закончился.';

  @override
  String get shareAlreadyUsedMissingLocal =>
      'Ссылка уже была использована, но задача не найдена на этом устройстве. Выполните синхронизацию или попросите новую ссылку.';

  @override
  String get unknownRetryError =>
      'Неизвестная ошибка. Проверьте интернет и попробуйте ещё раз.';

  @override
  String get taskTitleRequired => 'Введите название задачи.';

  @override
  String get selectTaskListForSave =>
      'Выберите список, в который сохранить задачу.';

  @override
  String get taskSaveFailedTitle => 'Не удалось сохранить задачу';

  @override
  String get synchronization => 'Синхронизация';

  @override
  String get syncNow => 'Синхронизировать';

  @override
  String get syncInProgress => 'Идёт синхронизация…';

  @override
  String get syncSuccessful => 'Успешно синхронизировано';

  @override
  String get syncFailedStatus => 'Ошибка синхронизации';

  @override
  String get syncNotRun => 'Ещё не запускалась';

  @override
  String get syncQueue => 'Ожидает отправки';

  @override
  String get syncQueueEmpty => 'Всё отправлено на бэкенд';

  @override
  String get syncHistory => 'История синхронизации';

  @override
  String get syncHistoryEmpty => 'История появится после синхронизации';

  @override
  String syncRetries(Object count) {
    return 'Попыток: $count';
  }

  @override
  String get subtaskDeleted => 'Подзадача удалена';

  @override
  String get undo => 'Отменить';
}
