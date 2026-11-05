// lib/models/user_model.dart
class UserModel {
  final String email;
  final int highestUnlockedLesson;
  final Map<int, int> testScores; // best score per lesson, e.g. {1: 100, 2: 85}

  const UserModel({
    required this.email,
    this.highestUnlockedLesson = 1,
    this.testScores = const {},
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'highestUnlockedLesson': highestUnlockedLesson,
        'testScores': testScores.map((k, v) => MapEntry(k.toString(), v)),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json['email'] as String,
        highestUnlockedLesson: (json['highestUnlockedLesson'] as int?) ?? 1,
        testScores: ((json['testScores'] as Map?) ?? {})
            .map((k, v) => MapEntry(int.parse(k.toString()), v as int)),
      );
}
