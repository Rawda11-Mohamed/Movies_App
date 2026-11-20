import 'package:dio/dio.dart';
import 'package:movies_app/core/constants/api_constants.dart';

import 'package:movies_app/movies/data/datasources/movie_remote_data_source.dart';
import 'package:movies_app/movies/data/models/movie_list_model.dart';
import 'package:movies_app/movies/data/models/movie_model.dart';

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final Dio dio;

  MovieRemoteDataSourceImpl(this.dio);

  @override
  Future<MovieListModel> getMovies({
    required int page,
    required int limit,
  }) async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}${ApiConstants.listMovies}',
      queryParameters: {'page': page, 'limit': limit},
    );
    return MovieListModel.fromJson(response.data);
  }

  @override
  Future<MovieModel> getMovieDetails({required int id}) async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}${ApiConstants.movieDetails}',
      queryParameters: {'movie_id': id, 'with_images': true, 'with_cast': true},
    );
    return MovieModel.fromJson(response.data['data']['movie']);
  }

  @override
  Future<MovieListModel> getMoviesByGenre({
    required String genre,
    required int page,
  }) async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}${ApiConstants.listMovies}',
      queryParameters: {'genre': genre, 'page': page},
    );
    return MovieListModel.fromJson(response.data);
  }

  @override
  Future<MovieListModel> getSimilarMovies({required int id}) async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}${ApiConstants.movieSuggestions}',
      queryParameters: {'movie_id': id},
    );
    return MovieListModel.fromJson(response.data);
  }

  @override
  Future<MovieListModel> searchMovies({
    required int page,
    required String query,
  }) async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}${ApiConstants.listMovies}',
      queryParameters: {'page': page, 'query_term': query},
    );
    return MovieListModel.fromJson(response.data);
  }
}
