class Event {
  final String title;
  final String? description;
  final DateTime dateTime;
  final String imagePath;

  Event(
      {required this.title, this.description, required this.dateTime, required this.imagePath});
}