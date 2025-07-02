import 'package:hive/hive.dart';

part 'photocard.g.dart';

@HiveType(typeId: 0)
class Photocard extends HiveObject {
  @HiveField(0)
  String imagePath;
  @HiveField(1)
  String title;
  @HiveField(2)
  String number;

  Photocard({
    required this.imagePath,
    required this.title,
    required this.number,
  });
}
