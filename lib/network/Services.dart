import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movie_app/model/Popular.dart';
import 'package:movie_app/model/TopRated.dart';

class Services {

  Future<TopRated> getTopMovies () async {
    final response = await http.get('https://api.themoviedb.org/3/movie/top_rated?api_key=5d69e6deb3c63a7d7227ad0421474f89&language=en-US&page=1');
    if (response.statusCode == 200){
      final json = jsonDecode(response.body);
      return TopRated.fromJson(json);
    }
    else {
      throw Exception('Error');
    }
  }

  Future<Popular> getPopularMovies () async {
    final response = await http.get('https://api.themoviedb.org/3/movie/popular?api_key=5d69e6deb3c63a7d7227ad0421474f89&language=en-US&page=1');
    if (response.statusCode == 200){
      final json = jsonDecode(response.body);
      return Popular.fromJson(json);
    }
    else {
      throw Exception('Error');
    }
  }
}

