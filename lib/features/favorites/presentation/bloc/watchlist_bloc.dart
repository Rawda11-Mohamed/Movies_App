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
    await _refresh(emit);
  }

  Future<void> _onAdd(
    AddMovieToWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await addToWatchlist(event.movie);
    await result.fold(
      (failure) async => emit(WatchlistError(failure.message)),
      (_) => _refresh(emit),
    );
  }

  Future<void> _onRemove(
    RemoveMovieFromWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final result = await removeFromWatchlist(event.movieId);
    await result.fold(
      (failure) async => emit(WatchlistError(failure.message)),
      (_) => _refresh(emit),
    );
  }

  Future<void> _refresh(Emitter<WatchlistState> emit) async {
    final result = await getWatchlist(const NoParams());
    result.fold(
      (failure) => emit(WatchlistError(failure.message)),
      (movies) => emit(WatchlistLoaded(movies)),
    );
  }
}