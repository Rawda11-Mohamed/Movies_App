import '../entities/movie_entity.dart';
import '../repo/movie_repo_abstract.dart';

class SearchMoviesUseCase {
  final MovieRepoAbstract repo;

  SearchMoviesUseCase(this.repo);

  Future<List<MovieEntity>> call({required int page, required String query}) {
    return repo.searchMovies(page: page, query: query);
  }
}