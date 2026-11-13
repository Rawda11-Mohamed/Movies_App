import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/shared_prefs_helper.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final SharedPrefsHelper sharedPrefsHelper;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.sharedPrefsHelper,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<ClearProfile>(_onClearProfile);
  }

  ProfileEntity? _currentProfile;

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    final result = await getProfileUseCase(GetProfileParams(uid: event.uid));
    result.fold(
      (failure) {
        // Build a default profile from Firebase data if cache miss
        final defaultProfile = ProfileEntity(
          uid: event.uid,
          displayName: event.displayName,
          email: event.email,
          phone: sharedPrefsHelper.getUserPhone(),
          avatarKey: sharedPrefsHelper.getUserAvatar(),
        );
        _currentProfile = defaultProfile;
        emit(ProfileLoaded(profile: defaultProfile));
      },
      (profile) {
        _currentProfile = profile;
        emit(ProfileLoaded(profile: profile));
      },
    );
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    if (_currentProfile == null) return;
    emit(const ProfileLoading());
    final updated = _currentProfile!.copyWith(
      displayName: event.displayName,
      phone: event.phone,
      avatarKey: event.avatarKey,
    );
    final result = await updateProfileUseCase(updated);
    await result.fold(
      (failure) async => emit(ProfileError(message: failure.message)),
      (_) async {
        if (event.phone != null) {
          await sharedPrefsHelper.saveUserPhone(event.phone!);
        }
        if (event.avatarKey != null) {
          await sharedPrefsHelper.saveUserAvatar(event.avatarKey!);
        }
        _currentProfile = updated;
        emit(ProfileUpdatedSuccess(profile: updated));
      },
    );
  }

  Future<void> _onClearProfile(ClearProfile event, Emitter<ProfileState> emit) async {
    _currentProfile = null;
    emit(const ProfileInitial());
  }
}
