import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'event.dart';
import 'table_calendar_event_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calendar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 58, 93, 183),
        ),
        useMaterial3: true,
      ),
      home: const TableCalendarSample(),
    );
  }
}

class TableCalendarSample extends HookConsumerWidget {
  const TableCalendarSample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = useState(DateTime.now());
    final focusedDay = useState(DateTime.now());
    final events = ref.watch(
      tableCalendarEventControllerProvider,
    ); // イベントのリストを取得

    return Scaffold(
      appBar: AppBar(title: const Text('カレンダー')),
      body: TableCalendar<Event>(
        locale: 'ja_JP',
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: focusedDay.value,
        selectedDayPredicate: (day) => isSameDay(selectedDay.value, day),
        onDaySelected: (selected, focused) {
          selectedDay.value = selected;
          focusedDay.value = focused;
        },
        onDayLongPressed: (selected, focused) {
          showAddEventDialog(context, selectedDay.value, ref);
        },
        eventLoader: (date) {
          final selectedEventList = <Event>[];
          for (var event in events) {
            if (isSameDay(event.dateTime, date)) {
              selectedEventList.add(event);
            }
          }
          return selectedEventList;
        },
      ),
    );
  }

  Future<void> showAddEventDialog(
    BuildContext context,
    DateTime selectedDay,
    WidgetRef ref,
  ) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('イベント追加'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'タイトル'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                ref
                    .read(tableCalendarEventControllerProvider.notifier)
                    .addEvent(
                      dateTime: selectedDay,
                      title: titleController.text,
                      description: descriptionController.text,
                    );
              }
              Navigator.pop(context);
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }
}
