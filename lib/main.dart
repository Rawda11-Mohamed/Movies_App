import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movies_app/movies/data/datasources/movie_remote_data_source_impl.dart';
import 'package:movies_app/movies/data/repo/movie_repo_implement.dart';
import 'package:movies_app/movies/domain/usecases/get_movie_use_case.dart';
import 'package:movies_app/movies/presentation/screens/main_screen.dart';
import 'core/theme/app_theme.dart';

import 'package:movies_app/movies/presentation/bloc/home/home_bloc.dart';
import 'package:movies_app/movies/presentation/bloc/home/home_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://movies-api.accel.li/api/v2/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  final dataSource = MovieRemoteDataSourceImpl(dio);
  final repository = MovieRepoImplement(dataSource);
  final getMoviesUseCase = GetMoviesUseCase(repository);

  runApp(MoviesApp(getMoviesUseCase: getMoviesUseCase));
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key, required this.getMoviesUseCase});

  final GetMoviesUseCase getMoviesUseCase;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Movies App',
          theme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          home: BlocProvider<HomeBloc>(
            create: (_) => HomeBloc(getMoviesUseCase)..add(LoadMoviesEvent()),
            child: MainScreen(),
          ),
        );
      },
    );
  }
}
