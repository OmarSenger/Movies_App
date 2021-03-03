import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/blocs/movie_bloc.dart';
import 'package:movie_app/model/TopRated.dart';
import 'package:movie_app/ui/Details.dart';
import 'package:movie_app/ui/Favourite.dart';
import 'package:movie_app/ui/PopularMovies.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'Login.dart';

User loggedInUser ;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void getCurrentUser() async {
    try{
      final user = _auth.currentUser;
      if (user!=null){
        loggedInUser = user ;
      }
    }  catch (e){
      print(e);
    }
  }

    @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    getCurrentUser();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  final _auth = FirebaseAuth.instance;
  var options = <String>['Highest Rated','Most Popular','Favourite'];

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pop(context);
    return true;
  }

  void handleClick(String value) {
    setState(() {
      switch (value) {
        case 'Highest Rate':
          break;
        case 'Most Popular':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PopularMovies()),
          );
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
    bloc.getTopMovies();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Highest Rated'),
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
        stream: bloc.topMovies,
        builder: (context, AsyncSnapshot<TopRated> snapshot) {
          if (snapshot.hasData) {
            return buildList(snapshot);
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Center(child: CircularProgressIndicator(backgroundColor: Colors.pink));
        },
      ),
    );
  }

  Widget buildList(AsyncSnapshot<TopRated> snapshot) {
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
                            image: "https://image.tmdb.org/t/p/w342/${snapshot.data.results[index].posterPath}",
                            title: snapshot.data.results[index].title,
                            overview: snapshot.data.results[index].overview,
                            releaseDate: snapshot.data.results[index].releaseDate,
                            voteAverage: snapshot.data.results[index].voteAverage,
                            popularity: snapshot.data.results[index].popularity,
                            language: snapshot.data.results[index].originalLanguage,
                        )
                        ),
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