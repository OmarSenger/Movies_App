import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Favourite.dart';
import 'HomePage.dart';
import 'Login.dart';
import 'PopularMovies.dart';

DocumentSnapshot snapshot;
final userRef = _firestore.collection('Reviews');
final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class Reviews extends StatefulWidget {
  @override
  _ReviewsState createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  final _auth = FirebaseAuth.instance;

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

  Future editMovie() async {}

  Future getUsers() async {
    var data = (await userRef.doc(loggedInUser.email).get()).data();
    return data;
  }

  var options = <String>[
    'Highest Rated',
    'Most Popular',
    'My Favorite',
    'My Reviews'
  ];

  void handleClick(String value) {
    setState(() {
      switch (value) {
        case 'My Favorite':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Favourite()),
          );
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
          break;
      }
    });
  }

  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
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
      body: FutureBuilder(
        future: getUsers(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          } else {
            return GestureDetector(
              onTap: () {},
              child: ListView.builder(
                  itemCount: snapshot.data['Reviews'].length,
                  itemBuilder: (context, index) {
                    final myController = TextEditingController()
                      ..text = snapshot.data['Reviews'][index];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selected = !selected;
                            });
                          },
                          child: AnimatedSwitcher(
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            switchInCurve: Curves.fastOutSlowIn,
                            duration: Duration(seconds: 1),
                            child: !selected
                                ? Stack(
                                    children: [
                                      Container(
                                        width: 420,
                                        height: 210,
                                        child: Image.network(
                                          snapshot.data['movie-image'][index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 185),
                                        child: Container(
                                            color: Colors.black38,
                                            child: Text(
                                                snapshot.data['movie-name']
                                                    [index],
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                          _firestore.collection('Reviews').doc(loggedInUser.email).update({
                                          'movie-name': FieldValue.arrayRemove([snapshot.data['movie-name'][index]]),
                                          'Reviews': FieldValue.arrayRemove([snapshot.data['Reviews'][index]]),
                                          'movie-image': FieldValue.arrayRemove([snapshot.data['movie-image'][index]])
                                            });
                                            });
                                          },
                                        child: Icon(Icons.clear,
                                              color: Colors.white,size: 30),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: CircleAvatar(
                                          radius: 100,
                                          backgroundImage: NetworkImage(snapshot
                                              .data['movie-image'][index]),
                                          child: GestureDetector(
                                              onTap: () {
                                                return showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Padding(
                                                        padding: const EdgeInsets.all(30),
                                                        child: AlertDialog(
                                                            title: Text(
                                                                'Write Your Review'),
                                                            content: TextFormField(
                                                              controller: myController,
                                                              autofocus: true,
                                                            ),
                                                            actions: <Widget>[
                                                              FlatButton(
                                                                child: Text('CANCEL'),
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                              FlatButton(
                                                                child: Text('Edit'),
                                                                onPressed: () {
                                                                  setState((){
                                                                    _firestore.collection('Reviews').doc(loggedInUser.email).update({
                                                                      'Reviews': FieldValue.arrayRemove([snapshot.data['Reviews'][index]]),
                                                                      'movie-name': FieldValue.arrayRemove([snapshot.data['movie-name'][index]]),
                                                                      'movie-image': FieldValue.arrayRemove([snapshot.data['movie-image'][index]]),
                                                                    }).whenComplete(() {
                                                                      _firestore.collection('Reviews').doc(loggedInUser.email).update({
                                                                        'Reviews': FieldValue.arrayUnion([myController.text]),
                                                                        'movie-name': FieldValue.arrayUnion([snapshot.data['movie-name'][index]]),
                                                                        'movie-image': FieldValue.arrayUnion([snapshot.data['movie-image'][index]]),
                                                                      }).whenComplete(() {
                                                                        Navigator.pop(context);
                                                                        Navigator.pushReplacement(
                                                                          context,
                                                                          MaterialPageRoute(builder: (context) => Reviews()),
                                                                        );
                                                                      });
                                                                    });
                                                                  });
                                                                },
                                                              ),
                                                            ]),
                                                      );
                                                    });
                                              },
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color:Colors.pink.withOpacity(0.3),
                                                    borderRadius: BorderRadius.circular(100)),
                                                child: Icon(Icons.edit,
                                                    color: Colors.white,size: 50),
                                              )),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Container(
                                          padding: EdgeInsets.only(top:5),
                                          width: 200,
                                          height: 150,
                                          decoration: BoxDecoration(
                                              color: Colors.pink.shade400.withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.only(topRight:Radius.circular(40),bottomLeft: Radius.circular(40))
                                          ),
                                          child: SingleChildScrollView(
                                            padding:EdgeInsets.only(top: 35),
                                            child: Center(
                                                child: Text(snapshot.data['Reviews'][index],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white))),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                          ),
                        )
                      ],
                    );
                  }),
            );
          }
        },
      ),
    );
  }
}


