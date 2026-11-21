import '../entities/movie_entity.dart';

abstract class MovieRepoAbstract {
  Future<List<MovieEntity>> getMovies({
    required int page,
    required int limit,
    String? genre,
  });
  Future<List<MovieEntity>> searchMovies({
    required int page,
    required int limit,
    required String query,
  });
  Future<MovieEntity> getMovieDetails({required int id});
  Future<List<MovieEntity>> getSimilarMovies({required int id});
}