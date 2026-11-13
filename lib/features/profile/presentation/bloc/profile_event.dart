part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String uid;
  final String email;
  final String displayName;
  const LoadProfile({required this.uid, required this.email, required this.displayName});
  @override
  List<Object> get props => [uid, email, displayName];
}

class UpdateProfile extends ProfileEvent {
  final String? displayName;
  final String? phone;
  final String? avatarKey;
  const UpdateProfile({this.displayName, this.phone, this.avatarKey});
  @override
  List<Object?> get props => [displayName, phone, avatarKey];
}

class ClearProfile extends ProfileEvent {
  const ClearProfile();
}
