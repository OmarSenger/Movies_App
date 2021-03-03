import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/blocs/movie_bloc.dart';
import 'package:movie_app/model/Popular.dart';
import 'package:movie_app/ui/Details.dart';
import 'package:movie_app/ui/HomePage.dart';
import 'Favourite.dart';
import 'Login.dart';

User loggedInUser ;

class PopularMovies extends StatefulWidget {
  @override
  _PopularMoviesState createState() => _PopularMoviesState();
}

class _PopularMoviesState extends State<PopularMovies> {

  final _auth = FirebaseAuth.instance;
  var options = <String>['Highest Rated','Most Popular','Favourite'];
  bool isFavourited = false ;

  void handleClick(String value) {
    setState(() {
      switch (value) {
        case 'Highest Rated':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          break;
        case 'Most Popular':
          break;
        case 'Favourite':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Favourite()),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bloc.getPopularMovies();
    return Scaffold(
      appBar: AppBar(
        title: Text('Popular Movies'),
        actions: <Widget>[
          GestureDetector(
              onTap: (){
                _auth.signOut();
                Navigator.push(context, MaterialPageRoute(builder:(BuildContext context) => Login()));
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Logout',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
              )),
          PopupMenuButton<String>(
            onSelected: handleClick ,
            itemBuilder: (BuildContext context) {
              return options.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: bloc.popMovies,
        builder: (context, AsyncSnapshot<Popular> snapshot) {
          if (snapshot.hasData) {
            return buildList(snapshot);
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildList(AsyncSnapshot<Popular> snapshot) {
    return GridView.count(
        shrinkWrap: true,
        primary: false,
        childAspectRatio: 90 / 148,
        crossAxisCount: 2,
        children: List.generate(snapshot.data.results.length, (index) {
          return Container(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        Details(args: PopData(
                            image: "https://image.tmdb.org/t/p/w342/${snapshot.data
                                .results[index].posterPath}",
                            title: snapshot.data.results[index].title,
                            overview: snapshot.data.results[index].overview,
                            releaseDate: snapshot.data.results[index].releaseDate,
                            voteAverage: snapshot.data.results[index].voteAverage,
                            popularity: snapshot.data.results[index].popularity,
                            language: snapshot.data.results[index].originalLanguage,
                            )),
                  ),
                );
              },
              child: Card(
                elevation: 10.0,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Image.network("https://image.tmdb.org/t/p/w342/${snapshot.data.results[index].posterPath}"),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height / 50, width: MediaQuery
                          .of(context)
                          .size
                          .width),
                      Text(snapshot.data.results[index].title, style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        })
    );
  }
}