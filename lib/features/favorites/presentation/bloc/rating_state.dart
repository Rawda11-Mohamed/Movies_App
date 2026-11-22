import 'package:equatable/equatable.dart';
import '../../domain/entities/movie_rating_entity.dart';

abstract class RatingState extends Equatable {
  const RatingState();

  @override
  List<Object?> get props => [];
}

class RatingInitial extends RatingState {
  const RatingInitial();
}

class RatingLoading extends RatingState {
  final int movieId;

  const RatingLoading(this.movieId);

  @override
  List<Object?> get props => [movieId];
}

class RatingLoaded extends RatingState {
  final int movieId;
  final MovieRatingEntity? rating;

  const RatingLoaded(this.movieId, this.rating);

  @override
  List<Object?> get props => [movieId, rating];
}

class RatingError extends RatingState {
  final String message;

  const RatingError(this.message);

  @override
  List<Object?> get props => [message];
}