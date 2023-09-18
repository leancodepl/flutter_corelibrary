// TODO: Remove after implementing real backend queries
import 'dart:math';

import 'package:force_update/src/models/raw_notification.dart';
import 'package:leancode_contracts/leancode_contracts.dart';

Iterable<RawNotification> getMockedMessages(String? nextToken) {
  const titles = [
    'Nowa naukowa teoria',
    'Skandal w kocim showbiznesie',
    'Catspresso Time',
    'Koci malarz na horyzoncie',
    'Koci rekordzista',
    'Koty kontra psy',
    'Koci fitness',
    'Koci detektyw',
    'Kocie kulinaria',
    'Koci DJ na imprezie',
  ];

  const contents = [
    'Koty to tak naprawdę kosmiczni obserwatorzy ludzkości, a drzemki to ich intergalaktyczny raport.',
    'Gwiazda internetu Mr. Whiskers właśnie zdradził swoją obsesję na punkcie kawałków nici. Paparazzi są na miejscu!',
    'Twoja kotka właśnie zamówiła swoje pierwsze latte w kociej kawiarni. Czy to początek nowej pasji?',
    'Twój kotek rozpoczął kurs malowania łapkami. Wkrótce możesz spodziewać się kocich dzieł sztuki na ścianach.',
    'Kot o imieniu Garfield właśnie zjadł 30 lasagne w 30 minut. Kocie rekordy zostają pobijane!',
    'Dyskusja w Internecie nadal trwa. Kocie lobby twierdzi, że koty są lepsze niż psy. Kolejna debata w nocy.',
    'Twój kot właśnie zaczyna trening kocich mięśni. Nowy rok, nowa figura kociaka!',
    'Kotka Miss Whiskers rozpoczęła prywatne śledztwo w sprawie zaginionego kawałka sznurka. Ślad prowadzi do kociej kolonii na strychu.',
    "Twój kot właśnie stworzył nowe danie: 'Ryba w sosie kociego łapczywego'. Czy zaryzykujesz spróbować?",
    'Kot DJ WhiskerCat właśnie zaczął grać na kociej imprezie. Dancefloor pełen wirujących ogonów!',
  ];

  return List.generate(
    10,
    (index) => RawNotification(
      title: titles[index],
      content: contents[index],
      imageUrl: Random().nextBool()
          ? Uri.parse('http://placekitten.com/${index}00/${index}00')
          : null,
      category: Random().nextBool() ? 'YourPostWasLiked' : 'NewMessageReceived',
      dateTime: DateTimeOffset(
        DateTime(2023, 9, 14, 21, 26)
            .subtract(Duration(hours: pow(index, 4).toInt() * 100 + index * 4))
            .toUtc(),
        0,
      ),
      payload: {
        'PostLink': 'Link do posta',
        'PostName': 'Nazwa posta',
        'UserName': 'Nazwa usera',
      },
    ),
  );
}
