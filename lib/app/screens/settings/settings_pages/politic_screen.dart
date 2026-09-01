import 'package:flutter/material.dart';
import 'package:jospar/app/utils/custom_appbar.dart';

class PoliticScreen extends StatelessWidget {
  const PoliticScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Политика'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Политика конфиденциальности',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Приложение Jospar создано, чтобы помочь вам удобно планировать задачи и управлять своим временем. '
              'Мы уважаем вашу конфиденциальность и заботимся о безопасности персональных данных.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Сбор и использование информации',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Мы можем сохранять данные, которые вы вводите в приложение: название задач, заметки, даты, напоминания. '
              'Эти данные используются только для работы приложения и отображаются исключительно вам.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Уведомления',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Приложение может отправлять локальные уведомления, чтобы напоминать о предстоящих задачах. '
              'Вы всегда можете изменить настройки уведомлений в системе.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Безопасность данных',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Все ваши задачи и заметки хранятся только на вашем устройстве, если вы не используете синхронизацию. '
              'Мы предпринимаем меры для защиты данных от несанкционированного доступа.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Контакты',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Если у вас есть вопросы по поводу политики конфиденциальности или работы Jospar, '
              'пожалуйста, свяжитесь с нашей службой поддержки.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
