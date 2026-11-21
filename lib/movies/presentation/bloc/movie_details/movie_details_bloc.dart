
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/movies/domain/usecases/get_movie_details_use_case.dart';

import 'package:movies_app/movies/presentation/bloc/movie_details/movie_details_event.dart';
import 'package:movies_app/movies/presentation/bloc/movie_details/movie_details_state.dart';

class MovieDetailsBloc extends Bloc<MovieDetailsEvent,MovieDetailsState>{
 
final GetMovieDetailsUseCase getMovieDetailsUseCase;
MovieDetailsBloc(this.getMovieDetailsUseCase):super(const MovieDetailsInitial()){
  on<LoadMovieDetailsEvent>(_onLoadMovieDetails);
}

Future <void> _onLoadMovieDetails(
LoadMovieDetailsEvent event,
Emitter<MovieDetailsState> emit,

)async {
  emit(const MovieDetailsLoading());
  try {
    final movie = await getMovieDetailsUseCase(id: event.movieId);
    emit(MovieDetailsLoaded(movie));
  } catch (e) {
    emit(MovieDetailsError("There is an error $e"));
  }

}
}