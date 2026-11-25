import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_to_watchlist.dart';
import '../../domain/usecases/get_watchlist.dart';
import '../../domain/usecases/remove_from_watchlist.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetWatchlist getWatchlist;
  final AddToWatchlist addToWatchlist;
  final RemoveFromWatchlist removeFromWatchlist;
  final Stream<String?> userStream;
  StreamSubscription<String?>? _userSub;

  WatchlistBloc({
    required this.getWatchlist,
    required this.addToWatchlist,
    required this.removeFromWatchlist,
    required this.userStream,
  }) : super(const WatchlistInitial()) {
    on<LoadWatchlist>(_onLoad);
    on<AddMovieToWatchlist>(_onAdd);
    on<RemoveMovieFromWatchlist>(_onRemove);
    on<ClearWatchlist>((event, emit) => emit(const WatchlistInitial()));

    _userSub = userStream.listen((uid) {
      add(uid == null ? const ClearWatchlist() : const LoadWatchlist());
    });
  }

  @override
  Future<void> close() {
    _userSub?.cancel();
    return super.close();
  }

  Future<void> _onLoad(
    LoadWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoading());
    final result = await getWatchlist(const NoParams());
    result.fold(
      (failure) => emit(WatchlistError(failure.message)),
      (movies) => emit(WatchlistLoaded(movies)),
    );
  }

  /// بعد نجاح الـ add بنحدّث القائمة محلياً بدل ما نعمل fetch تاني من Firestore،
  /// فالأيقونة بتتغير فوراً وبنوفّر read.
  Future<void> _onAdd(
    AddMovieToWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await addToWatchlist(event.movie);
    result.fold(
      (failure) => emit(
        WatchlistError(failure.message, movies: state.movies),
      ),
      (_) {
        final others =
            state.movies.where((m) => m.movieId != event.movie.movieId);
        emit(WatchlistLoaded([event.movie, ...others]));
      },
    );
  }

  Future<void> _onRemove(
    RemoveMovieFromWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await removeFromWatchlist(event.movieId);
    result.fold(
      (failure) => emit(
        WatchlistError(failure.message, movies: state.movies),
      ),
      (_) {
        emit(
          WatchlistLoaded(
            state.movies.where((m) => m.movieId != event.movieId).toList(),
          ),
        );
      },
    );
  }
}