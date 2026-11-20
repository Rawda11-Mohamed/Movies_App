import 'package:movies_app/movies/data/models/movie_list_model.dart';
import 'package:movies_app/movies/data/models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<MovieListModel> getMovies({required int page, required int limit});

  Future<MovieListModel> searchMovies({
    required int page,
    required String query,
  });

  Future<MovieModel> getMovieDetails({required int id});

  Future<MovieListModel> getSimilarMovies({required int id});

  Future<MovieListModel> getMoviesByGenre({
    required String genre,
    required int page,
  });
}
