import 'package:flutter/material.dart';
import 'package:kenburns/kenburns.dart';
import 'package:just_audio/just_audio.dart';

import 'datarepo.dart';
import 'dataitem.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

//class MyApp extends StatelessWidget {
class _MyAppState extends State<MyApp> {
  final PageController ctrl = PageController();

  DataRepo repo = new DataRepo();
  Future<List<DataItem>> futureItems;
  AudioPlayer player;
  bool languageState = true;   // state is true for Anishinaabe and false for English

  @override
  void initState() {
    print("Inside initState");
    //repo.InitInCode();      // initialize the repo
    //repo.InitEmpty();       // init item list wiht loading image until future returns below and resets it
    //repo.InitWithJson();    // initialize the repo from the jason file
    // Sample code from https://docs.flutter.dev/cookbook/networking/fetch-data#why-is-fetchalbum-called-in-initstate
    futureItems = repo.InitWithJson();
    player = AudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  final List<String> fileList = [
    'by_the_fire_1.jpg',
    'by_the_fire_2.jpg',
    'by_the_fire_3.jpg',
    'by_the_fire_4.jpg',
    'by_the_fire_5.jpg',
    'in_the_circle_1.jpg',
    'in_the_circle_2.jpg',
    'in_the_circle_3.jpg',
    'in_the_circle_4.jpg',
    'in_the_circle_5.jpg'
  ];

  void playAudio(int index) async {
    await player.setAsset(repo.getJourdainAudio(index));
    player.play();
  }

  String getTextDescription(int index) {
    if (languageState) {
      return repo.getJourdainAnishinaabe(index);
    } else {
      return repo.getJourdainEnglish(index);
    }

  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('SlideShow'),
          ),
          body: FutureBuilder<List<DataItem>>(
            future: futureItems,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                print("Inside FutureBuilder --- no data");
                // No data yet, show a loading spinner.
                return (Image.asset('assets/images/loading_image.gif',
                    fit: BoxFit.cover));
              } else {
                print("Inside FutureBuilder --- DATA");
                return PageView.builder(
                  controller: ctrl,
                  //itemCount: fileList.length,
                  itemCount: repo.length(),
                  itemBuilder: (context, index) {
                    print("PageView Builder --- playing audio "+index.toString());

                    playAudio(index);
                    return
                      //Image.asset(items[index]);
                      Container(
                        constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height), // add this line
                        child: Stack(
                          //alignment: FractionalOffset(0.5, 0.8),
                            children: <Widget>[
                              KenBurns(
                                maxScale: 2,
                                minAnimationDuration: Duration(milliseconds: 10000),
                                maxAnimationDuration: Duration(milliseconds: 20000),
                                //child: Image.asset(filePrfix + fileList[index], fit: BoxFit.cover),
                                child: Image.asset(repo.getImageFile(index),
                                    fit: BoxFit.cover,
                                    height: double.infinity),
                              ),
                              Container(
                                alignment: FractionalOffset(0.5, 0.8),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      print("----- text click -----");
                                      languageState = !languageState;
                                    });
                                  },
                                  child: Text(
                                    getTextDescription(index),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 36,
                                    ),
                                  ),
                                ),
                              )
                            ]),
                      );
                  },
                );
              }
              ;
            },
          ),
        ));
  }
}
