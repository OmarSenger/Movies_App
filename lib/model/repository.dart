import 'dart:async';
import 'package:movie_app/model/TopRated.dart';
import 'package:movie_app/network/Services.dart';
import 'Popular.dart';


class Repository {
  final moviesApiProvider = Services();

  Future<TopRated> getTopMovies() => moviesApiProvider.getTopMovies();
  Future<Popular> getPopularMovies() => moviesApiProvider.getPopularMovies();
}