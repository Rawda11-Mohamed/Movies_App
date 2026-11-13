import 'dart:convert';
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.uid,
    required super.displayName,
    required super.email,
    required super.phone,
    required super.avatarKey,
    super.wishlistCount,
    super.historyCount,
  });

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      uid: entity.uid,
      displayName: entity.displayName,
      email: entity.email,
      phone: entity.phone,
      avatarKey: entity.avatarKey,
      wishlistCount: entity.wishlistCount,
      historyCount: entity.historyCount,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uid: json['uid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarKey: json['avatarKey'] as String? ?? 'avatar_1',
      wishlistCount: json['wishlistCount'] as int? ?? 0,
      historyCount: json['historyCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'avatarKey': avatarKey,
      'wishlistCount': wishlistCount,
      'historyCount': historyCount,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory ProfileModel.fromJsonString(String jsonString) {
    return ProfileModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
