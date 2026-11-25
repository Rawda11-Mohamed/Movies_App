import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movies_app/core/storage/app_prefs.dart';
import 'package:movies_app/movies/data/datasources/movie_local__data_source_impl.dart';
=======
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/shared_prefs_helper.dart';

// Auth Imports
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/delete_account_usecase.dart';
import 'features/auth/domain/usecases/forgot_password_usecase.dart';
import 'features/auth/domain/usecases/get_auth_state_stream_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/update_profile_usecase.dart' as auth_uc;
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Profile Imports
import 'features/profile/data/datasources/profile_local_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/clear_profile_usecase.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart' as profile_uc;
import 'features/profile/presentation/bloc/profile_bloc.dart';
>>>>>>> origin/feature/profile

import 'package:movies_app/movies/data/datasources/movie_remote_data_source_impl.dart';
import 'package:movies_app/movies/data/repo/movie_repo_implement.dart';
import 'package:movies_app/movies/domain/usecases/get_movie_details_use_case.dart';
import 'package:movies_app/movies/domain/usecases/get_movie_use_case.dart';
import 'package:movies_app/movies/domain/usecases/get_similar_movies_use_case.dart';
import 'package:movies_app/movies/domain/usecases/search_movie_use_case.dart';
import 'package:movies_app/movies/presentation/bloc/browse/browse_bloc.dart';
import 'package:movies_app/movies/presentation/bloc/search/search_bloc.dart';
import 'package:movies_app/movies/presentation/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'package:movies_app/movies/presentation/bloc/home/home_bloc.dart';
import 'package:movies_app/movies/presentation/bloc/home/home_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

<<<<<<< HEAD
  await Hive.initFlutter();
  final moviesBox = await Hive.openBox<String>('movies_cache');
  final prefs = AppPrefs(await SharedPreferences.getInstance());

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://movies-api.accel.li/api/v2/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  final dataSource = MovieRemoteDataSourceImpl(dio);
  final localDataSource = MovieLocalDataSourceImpl(moviesBox);
  final repository = MovieRepoImplement(dataSource, localDataSource);
  final getMoviesUseCase = GetMoviesUseCase(repository);
  final searchMoviesUseCase = SearchMoviesUseCase(repository);
  final getMovieDetailsUseCase = GetMovieDetailsUseCase(repository);
  final getSimilarMoviesUseCase = GetSimilarMoviesUseCase(repository);
  
  runApp(
    MoviesApp(
      getMoviesUseCase: getMoviesUseCase,
      searchMoviesUseCase: searchMoviesUseCase,
      getMovieDetailsUseCase: getMovieDetailsUseCase,
      getSimilarMoviesUseCase: getSimilarMoviesUseCase,
      prefs: prefs,
=======
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  final sharedPrefsHelper = await SharedPrefsHelper.getInstance();

  // ── Auth dependencies ──────────────────────────────────────────
  final authRemoteDataSource = AuthRemoteDataSourceImpl();
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

  final signInUseCase = SignInUseCase(authRepository);
  final signUpUseCase = SignUpUseCase(authRepository);
  final signOutUseCase = SignOutUseCase(authRepository);
  final forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
  final authUpdateProfileUseCase = auth_uc.UpdateProfileUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  final getAuthStateStreamUseCase = GetAuthStateStreamUseCase(authRepository);
  final signInWithGoogleUseCase = SignInWithGoogleUseCase(authRepository);
  final deleteAccountUseCase = DeleteAccountUseCase(authRepository);

  final authBloc = AuthBloc(
    signInUseCase: signInUseCase,
    signUpUseCase: signUpUseCase,
    signOutUseCase: signOutUseCase,
    forgotPasswordUseCase: forgotPasswordUseCase,
    updateProfileUseCase: authUpdateProfileUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    getAuthStateStreamUseCase: getAuthStateStreamUseCase,
    signInWithGoogleUseCase: signInWithGoogleUseCase,
    deleteAccountUseCase: deleteAccountUseCase,
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
  final profileUpdateUseCase = profile_uc.UpdateProfileUseCase(profileRepository);
  final clearProfileUseCase = ClearProfileUseCase(profileRepository);

  final profileBloc = ProfileBloc(
    getProfileUseCase: getProfileUseCase,
    updateProfileUseCase: profileUpdateUseCase,
    clearProfileUseCase: clearProfileUseCase,
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
>>>>>>> origin/feature/profile
    ),
  );
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({
    super.key,
    required this.getMoviesUseCase,
    required this.searchMoviesUseCase,
    required this.getMovieDetailsUseCase,
    required this.getSimilarMoviesUseCase, required this.prefs,
  });

  final GetMoviesUseCase getMoviesUseCase;
  final SearchMoviesUseCase searchMoviesUseCase;
  final GetMovieDetailsUseCase getMovieDetailsUseCase;
  final GetSimilarMoviesUseCase getSimilarMoviesUseCase;
  final AppPrefs prefs;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: getMovieDetailsUseCase),
            RepositoryProvider.value(value: getSimilarMoviesUseCase),
          ],
          child: MaterialApp(
            title: 'Movies App',
            theme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            home: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create:
                      (_) =>
                          HomeBloc(getMoviesUseCase)
                            ..add(const LoadMoviesEvent()),
                ),
                BlocProvider(create: (_) => BrowseBloc(getMoviesUseCase)),
                BlocProvider(create: (_) => SearchBloc(searchMoviesUseCase)),
              ],
              child:  MainScreen(prefs: prefs,),
            ),
          ),
        );
      },
    );
  }
}