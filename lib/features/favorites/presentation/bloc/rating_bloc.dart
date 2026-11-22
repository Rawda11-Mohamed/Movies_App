import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/delete_movie_rating.dart';
import '../../domain/usecases/get_movie_rating.dart';
import '../../domain/usecases/rate_movie.dart';
import 'rating_event.dart';
import 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final GetMovieRating getMovieRating;
  final RateMovie rateMovie;
  final DeleteMovieRating deleteMovieRating;

  RatingBloc({
    required this.getMovieRating,
    required this.rateMovie,
    required this.deleteMovieRating,
  }) : super(const RatingInitial()) {
    on<LoadMovieRating>(_onLoad);
    on<SubmitMovieRating>(_onSubmit);
    on<RemoveMovieRating>(_onRemove);
  }

  Future<void> _onLoad(
    LoadMovieRating event,
    Emitter<RatingState> emit,
  ) async {
    emit(RatingLoading(event.movieId));
    final result = await getMovieRating(event.movieId);
    result.fold(
      (failure) => emit(RatingError(failure.message)),
      (rating) => emit(RatingLoaded(event.movieId, rating)),
    );
  }

  Future<void> _onSubmit(
    SubmitMovieRating event,
    Emitter<RatingState> emit,
  ) async {
    final result = await rateMovie(event.rating);
    result.fold(
      (failure) => emit(RatingError(failure.message)),
      (_) => emit(RatingLoaded(event.rating.movieId, event.rating)),
    );
  }

  Future<void> _onRemove(
    RemoveMovieRating event,
    Emitter<RatingState> emit,
  ) async {
    final result = await deleteMovieRating(event.movieId);
    result.fold(
      (failure) => emit(RatingError(failure.message)),
      (_) => emit(RatingLoaded(event.movieId, null)),
    );
  }
}