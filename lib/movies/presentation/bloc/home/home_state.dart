import 'package:equatable/equatable.dart';
import '../../../domain/entities/movie_entity.dart';

class HomeState extends Equatable {
  final bool isCarouselLoading;
  final List<MovieEntity> carouselMovies;
  final String carouselError;

  final bool isActionLoading;
  final List<MovieEntity> actionMovies;
  final String actionError;

  const HomeState({
    this.isCarouselLoading = true,
    this.carouselMovies = const [],
    this.carouselError = '',
    this.isActionLoading = true,
    this.actionMovies = const [],
    this.actionError = '',
  });

  HomeState copyWith({
    bool? isCarouselLoading,
    List<MovieEntity>? carouselMovies,
    String? carouselError,
    bool? isActionLoading,
    List<MovieEntity>? actionMovies,
    String? actionError,
  }) {
    return HomeState(
      isCarouselLoading: isCarouselLoading ?? this.isCarouselLoading,
      carouselMovies: carouselMovies ?? this.carouselMovies,
      carouselError: carouselError ?? this.carouselError,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      actionMovies: actionMovies ?? this.actionMovies,
      actionError: actionError ?? this.actionError,
    );
  }

  @override
  List<Object?> get props => [
        isCarouselLoading,
        carouselMovies,
        carouselError,
        isActionLoading,
        actionMovies,
        actionError,
      ];
}