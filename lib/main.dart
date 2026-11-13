import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/shared_prefs_helper.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/data/datasources/profile_local_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart' as profile_uc;
import 'features/profile/presentation/bloc/profile_bloc.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  final sharedPrefsHelper = await SharedPrefsHelper.getInstance();

  // ── Auth dependencies ──────────────────────────────────────────
  final authRemoteDataSource = AuthRemoteDataSourceImpl();
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  final signInUseCase = SignInUseCase(authRepository);
  final signUpUseCase = SignUpUseCase(authRepository);
  final signOutUseCase = SignOutUseCase(authRepository);
  final forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
  final updateProfileUseCase = UpdateProfileUseCase(authRepository);

  final authBloc = AuthBloc(
    signInUseCase: signInUseCase,
    signUpUseCase: signUpUseCase,
    signOutUseCase: signOutUseCase,
    forgotPasswordUseCase: forgotPasswordUseCase,
    updateProfileUseCase: updateProfileUseCase,
    authRepository: authRepository,
    sharedPrefsHelper: sharedPrefsHelper,
  )..add(const AppStarted());

  // ── Profile dependencies ───────────────────────────────────────
  final profileLocalDataSource = ProfileLocalDataSourceImpl(
    sharedPreferences: sharedPreferences,
  );
  final profileRepository = ProfileRepositoryImpl(
    localDataSource: profileLocalDataSource,
  );
  final getProfileUseCase = GetProfileUseCase(profileRepository);
  final updateProfileUC = profile_uc.UpdateProfileUseCase(profileRepository);

  final profileBloc = ProfileBloc(
    getProfileUseCase: getProfileUseCase,
    updateProfileUseCase: updateProfileUC,
    sharedPrefsHelper: sharedPrefsHelper,
  );

  // ── Router ─────────────────────────────────────────────────────
  final router = AppRouter.createRouter(authBloc, sharedPrefsHelper);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<ProfileBloc>.value(value: profileBloc),
        // TODO: Teammates add their blocs here as separate BlocProvider entries
      ],
      child: MoviesApp(router: router),
    ),
  );
}

class MoviesApp extends StatelessWidget {
  final dynamic router;
  const MoviesApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Route Movies',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
