import 'package:movie_app/model/Popular.dart';
import 'package:movie_app/model/TopRated.dart';
import 'package:movie_app/model/repository.dart';
import 'package:rxdart/rxdart.dart';


class MoviesBloc {
  final _repository = Repository();
  final _topmoviesFetcher = PublishSubject<TopRated>();
  final _popmoviesFetcher = PublishSubject<Popular>();

  Stream<TopRated> get topMovies => _topmoviesFetcher.stream;
  Stream<Popular> get popMovies => _popmoviesFetcher.stream;

  getTopMovies() async {
    TopRated topRated = await _repository.getTopMovies();
    _topmoviesFetcher.sink.add(topRated);
  }
  getPopularMovies() async {
    Popular popular = await _repository.getPopularMovies();
    _popmoviesFetcher.sink.add(popular);
  }

  dispose() {
    _topmoviesFetcher.close();
    _popmoviesFetcher.close();
  }
}

final bloc = MoviesBloc();