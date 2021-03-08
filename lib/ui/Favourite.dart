import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/ui/HomePage.dart';
import 'Details.dart';
import 'Login.dart';
import 'PopularMovies.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Reviews.dart';

int index ;

Future getUsers() async {
  var data = (await userRef.doc(loggedInUser.email).get()).data();
  return data;
}

DocumentSnapshot snapshot;
final userRef = _firestore.collection('Favourite');
final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class Favourite extends StatefulWidget {
  @override
  _FavouriteState createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUsers();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  bool isDataLoaded = false;

  final _auth = FirebaseAuth.instance;
  var options = <String>[
    'Highest Rated',
    'Most Popular',
    'My Favorite',
    'My Reviews'
  ];

  void handleClick(String value) {
    setState(() {
      switch (value) {
        case 'My Favourite':
          break;
        case 'Most Popular':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PopularMovies()),
          );
          break;
        case 'Highest Rated':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          break;
        case 'My Reviews':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Reviews()),
          );
      }
    });
  }

  bool isFavourited = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: Text('Favourite'),
          actions: <Widget>[
            GestureDetector(
                onTap: () {
                  _auth.signOut();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Login()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Logout',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                )),
            PopupMenuButton<String>(
              onSelected: handleClick,
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
        body:
        FutureBuilder(
          future: getUsers(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return LinearProgressIndicator();
            } else {
              return GridView.count(
                  shrinkWrap: true,
                  primary: false,
                  childAspectRatio: 90 / 148,
                  crossAxisCount: 2,
                  children: List.generate(snapshot.data['movie'].length,
                      (index) {
                    return Container(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => Details(
                                  args: MovieData(
                                    image:
                                    snapshot.data['movie'][index]['movie-image'],
                                    title: snapshot.data['movie'][index]['movie-name'],
                                    overview: snapshot.data['movie'][index]['overview'],
                                    releaseDate: snapshot.data['movie'][index]['release-date'],
                                    voteAverage: snapshot.data['movie'][index]['vote-average'],
                                    popularity: snapshot.data['movie'][index]['popularity'],
                                    language: snapshot.data['movie'][index]['language'],
                                    fav: isFavourited,
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
                                Image.network(
                                    snapshot.data['movie'][index]['movie-image']),
                                SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 58,
                                    width: MediaQuery.of(context).size.width),
                                Text(snapshot.data['movie'][index]['movie-name'],
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }));
            }
          },
        )
    );
  }
}
