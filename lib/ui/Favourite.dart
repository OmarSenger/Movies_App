import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/ui/HomePage.dart';
import 'Login.dart';
import 'PopularMovies.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Reviews.dart';

DocumentSnapshot snapshot;
final userRef = _firestore.collection('Favourite');
final _firestore = FirebaseFirestore.instance;
User loggedInUser ;

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

  Future getUsers() async {
    var data = (await userRef.doc(loggedInUser.uid)
        .get())
        .data();
    return data;
  }

  bool isDataLoaded = false;

  final _auth = FirebaseAuth.instance;
  var options = <String>['Highest Rated', 'Most Popular', 'My Favorite','My Reviews'];

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
                Navigator.push(context, MaterialPageRoute(
                    builder: (BuildContext context) => Login()));
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Logout', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
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
      body: FutureBuilder(future: getUsers(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          } else {
            return GestureDetector(
              onTap: (){
              },
              child: ListView.builder(
                  itemCount: snapshot.data['movie-name'].length,
                  itemBuilder: (context,index){
                    return Card(
                      elevation: 10,
                      child: ListTile(
                        title: Text(snapshot.data['movie-name'][index]),
                      ),
                    );
                  }
              ),
            );
          }
        },
      ),
    );
  }
}