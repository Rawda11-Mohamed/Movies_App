import '../entities/movie_entity.dart';
import '../repo/movie_repo_abstract.dart';

class GetMoviesUseCase {
  final MovieRepoAbstract repo;

  GetMoviesUseCase(this.repo);

  Future<List<MovieEntity>> call({required int page, required int limit}) {
    return repo.getMovies(page: page, limit: limit);
  }
}