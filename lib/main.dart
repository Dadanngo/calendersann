import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'event.dart';
import 'table_calendar_event_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      appBar: AppBar(title: const Text('カレンダーさん')),
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
          // 指定日付のイベントを取得
          return events.where((e) => isSameDay(e.dateTime, date)).toList();
        },
        calendarBuilders: CalendarBuilders<Event>(
          markerBuilder: (context, day, eventList) {
            if (eventList.isEmpty) return const SizedBox.shrink();
            // 最初のイベントのスタンプを表示（複数あれば1つ目）

            final event = eventList.first;
            return Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(event.imagePath, width: 24, height: 24),
            );
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: '共有する'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '予定一覧'),
        ],
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
    final selectedImagePath = ValueNotifier<String>(
      'assets/images/stamp_yasumi.png',
    );
    final stampImages = [
      'assets/images/stamp_yasumi.png',
      'assets/images/stamp_shuukinn.png',
      'assets/images/stamp_yuukyuu.png',
      'assets/images/stamp_ake.png',
      'assets/images/stamp_yakinn.png',
      'assets/images/stamp_nikinn.png',
    ];
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('予定追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stampImages.map((path) {
                return GestureDetector(
                  onTap: () => selectedImagePath.value = path,
                  child: ValueListenableBuilder(
                    valueListenable: selectedImagePath,
                    builder: (_, value, __) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: value == path
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Image.asset(path, width: 50, height: 50),
                    ),
                  ),
                );
              }).toList(),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'コメント'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                ref
                    .read(tableCalendarEventControllerProvider.notifier)
                    .addEvent(
                      dateTime: selectedDay,
                      title: titleController.text.trim(),
                      description: descriptionController.text,
                      imagePath: selectedImagePath.value,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }
}
