import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/network/Services.dart';
import 'package:movie_app/model/TopRated.dart';
import 'package:movie_app/ui/Details.dart';
import 'package:movie_app/ui/Favourite.dart';
import 'package:movie_app/ui/PopularMovies.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'Login.dart';


class HomePage extends StatelessWidget {
  static const String _title = 'Movie App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      debugShowCheckedModeBanner: false,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {


  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> with SingleTickerProviderStateMixin {

  var urlImg = 'https://www.eduprizeschools.net/wp-content/uploads/2016/06/No_Image_Available.jpg';
  bool isDataLoaded = false ;
  final _auth = FirebaseAuth.instance;

    int index =0;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    getJsonData();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pop(context); // Do some stuff.
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

  TopRated top = TopRated();
  var options = <String>['Highest Rated','Most Popular','Favourite'];

  void getJsonData () async {
    final data = await Services().getTopMovies();
    setState(() {
      top = data;
      isDataLoaded = true ;
    });
  }

  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title:Text('Highest Rated') ,
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
      body:isDataLoaded?GridView.count(
      shrinkWrap: true,
      primary: false,
      childAspectRatio: 90/148,
      crossAxisCount: 2,
        children: List.generate(top.results.length, (index) {
          return Container(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Details(args: PopData(
                        image: "https://image.tmdb.org/t/p/w342/${top
                            .results[index].posterPath}",
                        title: top.results[index].title,
                        overview: top.results[index].overview,
                        releaseDate: top.results[index].releaseDate,
                        voteAverage: top.results[index].voteAverage,
                        popularity: top.results[index].popularity,
                        language: top.results[index].originalLanguage)),
                  ),
                );
              },
              child: Card(
                elevation: 10.0,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Image.network("https://image.tmdb.org/t/p/w342/${top
                          .results[index].posterPath}"),
                      SizedBox(height:MediaQuery.of(context).size.height/50,width:MediaQuery.of(context).size.width),
                      Text(top.results[index].title,style: TextStyle(
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
    ):Center(
    child: CircularProgressIndicator(backgroundColor:Colors.white)),
    );
        }
  }
