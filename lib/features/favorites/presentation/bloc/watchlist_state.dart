import 'package:equatable/equatable.dart';
import '../../domain/entities/saved_movie_entity.dart';

abstract class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();
}

class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

class WatchlistLoaded extends WatchlistState {
  final List<SavedMovieEntity> movies;

  const WatchlistLoaded(this.movies);

  bool isSaved(int movieId) => movies.any((m) => m.movieId == movieId);

  @override
  List<Object?> get props => [movies];
}

class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError(this.message);

  @override
  List<Object?> get props => [message];
}