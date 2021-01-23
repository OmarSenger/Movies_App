import 'package:flutter/material.dart';
import 'package:movie_app/model/Popular.dart';
import 'package:movie_app/network/Services.dart';
import 'package:movie_app/ui/Details.dart';
import 'package:movie_app/ui/HomePage.dart';


class PopularMovies extends StatefulWidget {
  @override
  _PopularMoviesState createState() => _PopularMoviesState();
}

class _PopularMoviesState extends State<PopularMovies> {

  void handleClick(String value) {
    setState(() {
      switch (value) {
        case 'Most Popular':
          break;
        case 'Highest Rated':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          break;
      }
    });
  }
  var urlImg = 'https://www.eduprizeschools.net/wp-content/uploads/2016/06/No_Image_Available.jpg';
  var options = <String>['Highest Rated','Most Popular'];
  bool isDataLoaded = false ;

  @override
  void initState() {
    super.initState();
    getJsonData();
  }

  Popular most = Popular();

  void getJsonData () async {
    final data = await Services().getPopularMovies();
    setState(() {
      most = data;
      isDataLoaded = true ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title:Text('Popular Movies') ,
        actions: <Widget>[
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
        childAspectRatio: 100/175,
        crossAxisCount: 2,
          children: List.generate(most.results.length, (index) {
          return Container(
            child: GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Details(args: PopData(
                    image: "https://image.tmdb.org/t/p/w342/${most.results[index].posterPath}",
                    title: most.results[index].title,
                    overview: most.results[index].overview,
                    releaseDate: most.results[index].releaseDate,
                    voteAverage: most.results[index].voteAverage,
                    popularity: most.results[index].popularity,
                    language: most.results[index].originalLanguage)),
                ),
                );
              },
              child: Card(
                elevation: 10.0,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Image.network("https://image.tmdb.org/t/p/w342/${most.results[index].posterPath}"),
                    SizedBox(height: 20),
                    Text(most.results[index].title, style: TextStyle(
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
        },
          ),
      ):Center(
      child: CircularProgressIndicator(backgroundColor:Colors.white)),
    );
  }
}
