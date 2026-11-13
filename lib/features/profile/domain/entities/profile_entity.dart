import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final String avatarKey;
  final int wishlistCount;
  final int historyCount;

  const ProfileEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.avatarKey,
    this.wishlistCount = 0,
    this.historyCount = 0,
  });

  ProfileEntity copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? phone,
    String? avatarKey,
    int? wishlistCount,
    int? historyCount,
  }) {
    return ProfileEntity(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarKey: avatarKey ?? this.avatarKey,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      historyCount: historyCount ?? this.historyCount,
    );
  }

  @override
  List<Object?> get props => [uid, displayName, email, phone, avatarKey, wishlistCount, historyCount];
}
