import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movies_app/core/storage/app_prefs.dart';
import 'package:movies_app/movies/data/datasources/movie_local__data_source_impl.dart';

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