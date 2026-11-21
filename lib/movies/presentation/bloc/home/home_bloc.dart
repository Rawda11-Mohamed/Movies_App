import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/movies/domain/usecases/get_movie_use_case.dart';
import 'package:movies_app/movies/presentation/bloc/home/home_event.dart';
import 'package:movies_app/movies/presentation/bloc/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetMoviesUseCase getMoviesUseCase;
  int _currentPage = 1;
  static const int _limit = 20;

  HomeBloc(this.getMoviesUseCase) : super(const HomeInitial()) {
    on<LoadMoviesEvent>(_onLoadMovies);
    on<LoadMoreMoviesEvent>(_onLoadMoreMovies);
  }

  Future<void> _onLoadMovies(
    LoadMoviesEvent event,
    Emitter<HomeState> emit,
  ) async {
    _currentPage = 1;
    emit(const HomeLoading());
    try {
      final movies = await getMoviesUseCase(page: _currentPage, limit: _limit);
      emit(HomeLoaded(movies: movies, hasReachedMax: movies.length < _limit));
    } catch (e) {
      emit(HomeError("There is an error $e"));
    }
  }

  Future<void> _onLoadMoreMovies(
    LoadMoreMoviesEvent event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeLoaded ||
        current.hasReachedMax ||
        current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = _currentPage + 1;
      final movies = await getMoviesUseCase(page: nextPage, limit: _limit);
      _currentPage = nextPage;
      emit(
        current.copyWith(
          movies: [...current.movies, ...movies],
          hasReachedMax: movies.length < _limit,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }
}
