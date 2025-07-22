import 'package:table_calendar/table_calendar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'event.dart';
part 'table_calendar_event_provider.g.dart';

@riverpod
class TableCalendarEventController extends _$TableCalendarEventController {
  final List<Event> sampleEvents = [
    Event(
      title: 'firstEvent',
      dateTime: DateTime.utc(2024, 2, 15),
      imagePath: 'assets/images/stamp_yasumi.png',
    ),
    Event(
      title: 'secondEvent',
      description: 'description',
      dateTime: DateTime.utc(2024, 2, 15),
      imagePath: 'assets/images/stamp_shuukinn.png',
    ),
  ];

  @override
  List<Event> build() {
    state = sampleEvents;
    return state;
  }

  void addEvent({
    required DateTime dateTime,
    required String title,
    String? description,
    required String imagePath,
  }) {
    var newData = Event(
      title: title,
      description: description,
      dateTime: dateTime,
      imagePath: imagePath,
    );
    state.add(newData);
  }

  void deleteEvent({required Event event}) {
    state.remove(event);
  }

  List<Event> eventsFor(DateTime day) {
    return state.where((e) => isSameDay(e.dateTime, day)).toList();
  }
}
