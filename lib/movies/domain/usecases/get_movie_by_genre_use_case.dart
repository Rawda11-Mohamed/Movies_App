import '../entities/movie_entity.dart';
import '../repo/movie_repo_abstract.dart';

class GetMovieByGenreUseCase {
  final MovieRepoAbstract repo;

  GetMovieByGenreUseCase(this.repo);

  Future<List<MovieEntity>> call({required int page,  required String genreId}) {
    return repo.getMoviesByGenre(page: page, genre: genreId );
  }
}