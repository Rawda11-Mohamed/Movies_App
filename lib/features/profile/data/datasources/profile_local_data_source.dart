import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel> getProfile(String uid);
  Future<void> saveProfile(ProfileModel profile);
  Future<void> clearProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  static String _profileKey(String uid) => 'profile_$uid';

  @override
  Future<ProfileModel> getProfile(String uid) async {
    final jsonString = sharedPreferences.getString(_profileKey(uid));
    if (jsonString == null) {
      throw const CacheException(message: 'No profile found in cache');
    }
    return ProfileModel.fromJsonString(jsonString);
  }

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    await sharedPreferences.setString(
      _profileKey(profile.uid),
      profile.toJsonString(),
    );
  }

  @override
  Future<void> clearProfile() async {
    final keys = sharedPreferences.getKeys().where((k) => k.startsWith('profile_'));
    for (final key in keys) {
      await sharedPreferences.remove(key);
    }
  }
}
