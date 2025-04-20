import 'package:flutter/foundation.dart';

@immutable
class UserName {
  const UserName({
    required this.lastName,
    required this.firstName,
    required this.kanaLastName,
    required this.kanaFirstName,
  });

  final String lastName;
  final String firstName;
  final String kanaLastName;
  final String kanaFirstName;

  String get fullName => '$lastName $firstName';

  String get kanaFullName => '$kanaLastName $kanaFirstName';

  UserName copyWith({
    String? lastName,
    String? firstName,
    String? kanaLastName,
    String? kanaFirstName,
  }) {
    return UserName(
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      kanaLastName: kanaLastName ?? this.kanaLastName,
      kanaFirstName: kanaFirstName ?? this.kanaFirstName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserName &&
          runtimeType == other.runtimeType &&
          lastName == other.lastName &&
          firstName == other.firstName &&
          kanaLastName == other.kanaLastName &&
          kanaFirstName == other.kanaFirstName;

  @override
  int get hashCode =>
      lastName.hashCode ^
      firstName.hashCode ^
      kanaLastName.hashCode ^
      kanaFirstName.hashCode;

  @override
  String toString() {
    return 'UserName(lastName: $lastName, firstName: $firstName, kanaLastName: '
        '$kanaLastName, kanaFirstName: $kanaFirstName)';
  }
}
