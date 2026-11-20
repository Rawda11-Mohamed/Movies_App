import 'package:movies_app/movies/data/datasources/movie_remote_data_source.dart';
import 'package:movies_app/movies/domain/entities/movie_entity.dart';
import 'package:movies_app/movies/domain/repo/movie_repo_abstract.dart';

class MovieRepoImplement implements MovieRepoAbstract {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepoImplement(this.remoteDataSource);

  @override
  Future<List<MovieEntity>> getMovies({
    required int page,
    required int limit,
  }) async {
    final response = await remoteDataSource.getMovies(page: page, limit: limit);
    return response.data?.movies?.map((m) => m.toEntity()).toList() ?? [];
  }

  @override
  Future<MovieEntity> getMovieDetails({required int id})async {
    final response = await remoteDataSource.getMovieDetails(id: id);
    return response.toEntity();

  }

  @override
  Future<List<MovieEntity>> getMoviesByGenre({
    required String genre,
    required int page,
  })async {
    final response=await remoteDataSource.getMoviesByGenre(genre: genre, page: page);
    return response.data?.movies?.map((e)=>e.toEntity()).toList()??[];
  }

  @override
  Future<List<MovieEntity>> getSimilarMovies({required int id}) async{
    final response =await remoteDataSource.getSimilarMovies(id: id);
    return response.data?.movies?.map((e)=>e.toEntity()).toList()??[];
    
  }

  @override
  Future<List<MovieEntity>> searchMovies({
    required int page,
    required String query,
  }) async
{ final response =await remoteDataSource.searchMovies(page: page, query: query);
return response.data?.movies?.map((e)=>e.toEntity()).toList()??[];

  }
}
