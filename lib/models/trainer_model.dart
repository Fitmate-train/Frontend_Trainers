class Trainer {
  final String name;
  final String location;
  final int price;
  final String type;
  final List<String> imageUrls;
  final int reviewCount;
  final String intro;
  final double firstLessonRate;
  final List<String> tags;

  Trainer({
    required this.name,
    required this.location,
    required this.price,
    required this.type,
    required this.imageUrls,
    required this.reviewCount,
    required this.intro,
    required this.firstLessonRate,
    required this.tags,
  });
}
