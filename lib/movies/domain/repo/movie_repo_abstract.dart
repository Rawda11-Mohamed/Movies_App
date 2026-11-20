import '../entities/movie_entity.dart';

abstract class MovieRepoAbstract {
  Future<List<MovieEntity>> getMovies({required int page, required int limit});
  Future<List<MovieEntity>> searchMovies({
    required int page,
    required String query,
  });
  Future<MovieEntity> getMovieDetails({required int id});
  Future<List<MovieEntity>> getSimilarMovies({required int id});
  Future<List<MovieEntity>> getMoviesByGenre({
    required String genre,
    required int page,
  });
}
