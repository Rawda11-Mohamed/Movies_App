import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/movies/domain/usecases/get_movie_use_case.dart';
import 'package:movies_app/movies/presentation/bloc/home/home_event.dart';
import 'package:movies_app/movies/presentation/bloc/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetMoviesUseCase getMoviesUseCase;

  static const int _carouselLimit = 10;
  static const int _actionLimit = 20;
  static const String _actionGenre = 'Action';

  HomeBloc(this.getMoviesUseCase) : super(const HomeState()) {
    on<LoadMoviesEvent>(_onLoadMovies);
  }

  Future<void> _onLoadMovies(
    LoadMoviesEvent event,
    Emitter<HomeState> emit,
  ) async {
  
    emit(const HomeState());

    await Future.wait([_loadCarousel(emit), _loadAction(emit)]);
  }

  Future<void> _loadCarousel(Emitter<HomeState> emit) async {
    try {
      final movies = await getMoviesUseCase(
        page: 1,
        limit: _carouselLimit,
        sortBy: 'rating',
      );
      emit(state.copyWith(isCarouselLoading: false, carouselMovies: movies));
    } catch (e) {
      emit(
        state.copyWith(
          isCarouselLoading: false,
          carouselError: 'Failed to load movies: $e',
        ),
      );
    }
  }

  Future<void> _loadAction(Emitter<HomeState> emit) async {
    try {
      final movies = await getMoviesUseCase(
        page: 1,
        limit: _actionLimit,
        genre: _actionGenre,
      );
      emit(state.copyWith(isActionLoading: false, actionMovies: movies));
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          actionError: 'Failed to load movies: $e',
        ),
      );
    }
  }
}