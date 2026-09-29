import 'package:web_personal_finances/resources/constants.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String profession;
  final String birthDate;
  final String primaryCurrency; // 'USD' or 'HNL'
  final bool enableDualCurrency; // false by default, true when toggled
  final bool isOnboarded;

  const UserModel({
    required this.uid,
    required this.email,
    this.fullName = emptyString,
    this.profession = emptyString,
    this.birthDate = emptyString,
    this.primaryCurrency = usdCurrency,
    this.enableDualCurrency = false,
    this.isOnboarded = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'profession': profession,
      'birthDate': birthDate,
      'primaryCurrency': primaryCurrency,
      'enableDualCurrency': enableDualCurrency,
      'isOnboarded': isOnboarded,
    };
  }

  factory UserModel.fromMap(final Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? emptyString,
      email: map['email'] as String? ?? emptyString,
      fullName: map['fullName'] as String? ?? emptyString,
      profession: map['profession'] as String? ?? emptyString,
      birthDate: map['birthDate'] as String? ?? emptyString,
      primaryCurrency:
          map['primaryCurrency'] as String? ??
          (map['currency'] as String? ?? usdCurrency),
      enableDualCurrency: map['enableDualCurrency'] as bool? ?? false,
      isOnboarded: map['isOnboarded'] as bool? ?? false,
    );
  }

  UserModel copyWith({
    final String? uid,
    final String? email,
    final String? fullName,
    final String? profession,
    final String? birthDate,
    final String? primaryCurrency,
    final bool? enableDualCurrency,
    final bool? isOnboarded,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profession: profession ?? this.profession,
      birthDate: birthDate ?? this.birthDate,
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      enableDualCurrency: enableDualCurrency ?? this.enableDualCurrency,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}
