import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;
import 'package:movies_app/features/favorites/presentation/bloc/history_event.dart';
import 'package:movies_app/features/favorites/presentation/bloc/watchlist_event.dart';
 

import 'data/datasources/history_remote_datasource.dart';
import 'data/datasources/watchlist_remote_datasource.dart';
import 'data/repositories/history_repository_impl.dart';
import 'data/repositories/watchlist_repository_impl.dart';
import 'domain/usecases/add_to_history.dart';
import 'domain/usecases/add_to_watchlist.dart';
import 'domain/usecases/clear_history.dart';
import 'domain/usecases/get_history.dart';
import 'domain/usecases/get_watchlist.dart';
import 'domain/usecases/remove_from_watchlist.dart';
import 'presentation/bloc/history_bloc.dart';
import 'presentation/bloc/watchlist_bloc.dart';

List<BlocProvider> favoritesProviders() {  String? currentUid() => FirebaseAuth.instance.currentUser?.uid;

  final watchlistRepo = WatchlistRepositoryImpl(
    WatchlistRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
      getUserId: currentUid,
    ),
  );

  final historyRepo = HistoryRepositoryImpl(
    HistoryRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
      getUserId: currentUid,
    ),
  );

  return [
    BlocProvider<WatchlistBloc>(
      create: (_) => WatchlistBloc(
        getWatchlist: GetWatchlist(watchlistRepo),
        addToWatchlist: AddToWatchlist(watchlistRepo),
        removeFromWatchlist: RemoveFromWatchlist(watchlistRepo),
      )..add(const LoadWatchlist()),
    ),
    BlocProvider<HistoryBloc>(
      create: (_) => HistoryBloc(
        getHistory: GetHistory(historyRepo),
        addToHistory: AddToHistory(historyRepo),
        clearHistory: ClearHistory(historyRepo),
      )..add(const LoadHistory()),
    ),
  ];
}