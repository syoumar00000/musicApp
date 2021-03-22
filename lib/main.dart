import 'dart:async';
import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayer/audioplayer.dart';
//import 'package:audioplayers/audioplayers.dart';
//import 'package:audioplayers/audio_cache.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sy Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Sy Music App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Musique> maListeDeMusiques = [
    new Musique('code java ', 'oumar sy', 'assets/un.jpg', 'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    new Musique('code flutter', 'oumar sy', 'assets/deux.jpg', 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3'),
  ];
  AudioPlayer audioPlayer;
  Musique maMusiqueActuelle;//objet
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 0);
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;
  PlayerState statut = PlayerState.stopped;
  int index = 0;
  @override
  void initState() {// etat initialisateur de homepage
    super.initState();
    maMusiqueActuelle = maListeDeMusiques[index];//je veux que ma musique soit la premiere musique quand on fais initState
    configurationAudioPlayer();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,//centre le titre de mon application
        backgroundColor: Colors.grey[900],//background du appbar
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey[800],//background du scaffold
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card( //uncard pour contenir mon image
              elevation: 9.0,//cela donne de lombre autor de notre Card
              child: new Container(// un container pour avoir une taille fixe
                width: MediaQuery.of(context).size.height / 2.5,//je divise la taille de mon body par 2.5 pour que mon image ai cette height trouvé sur tout type decran
                child: new Image.asset(maMusiqueActuelle.imagePath),//le chemin pour trouver mon image
              ),
            ),
            textAvecStyle(maMusiqueActuelle.titre, 1.5),//jajoute le titre du son en utilisant ma fonction de texte
            textAvecStyle(maMusiqueActuelle.artiste, 1.0),//jajoute le nom de lartiste en utilisant ma fonction de texte
            new Row(//celui ci va contenir nos icones
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),//icone pour precedent
                bouton((statut == PlayerState.playing) ? Icons.pause : Icons.play_arrow, 45.0, (statut == PlayerState.playing) ? ActionMusic.pause : ActionMusic.play),//icone pour play
                bouton(Icons.fast_forward, 30.0, ActionMusic.forward),//icone pour suivant

              ],
            ),
            new Row( //je met une ligne pour la lecture du son
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                textAvecStyle(fromDuration(position), 0.8),
                textAvecStyle(fromDuration(duree), 0.8),


              ],
            ),
            new Slider(//le trait montrant lavancer de la musique
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                inactiveColor: Colors.white,//couleur quand la musique ne joue pas
                activeColor: Colors.blue,//couleur quand la musique joue ou est en pause
                onChanged: (double d){
                  setState(() {
                    audioPlayer.seek(d);
                   // Duration nouvelleDuration = new Duration(seconds: duration.toInt()),
                   // position = nouvelleDuration;
                  });
                }),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  IconButton bouton(IconData icone, double taille, ActionMusic action){//fonction pour mes icones left right pause et start
      return new IconButton(
        iconSize: taille,
          color: Colors.white,
          icon: new Icon(icone),
          onPressed: (){
             switch (action){
               case ActionMusic.play:
                 play();
                 break;
               case ActionMusic.pause:
                 pause();
                 break;
               case ActionMusic.rewind:
                 rewind();
                 break;
               case ActionMusic.forward:
                 forward();
                 break;
             }
          }
      );
  }
  Text textAvecStyle(String data, double scale){ //fonction qui me permet d'ajouter du texte
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }
  void configurationAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
        (pos) => setState(() => position = pos)
    );
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
        if(state == AudioPlayerState.PLAYING){
          setState(() {
            duree = audioPlayer.duration;
          });
        } else if(state == AudioPlayerState.STOPPED){
          setState(() {
            statut = PlayerState.stopped;
          });
        }
    }, onError: (message) {
      print('erreur: $message');
      setState(() {
        statut = PlayerState.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    }
    );
  }
  Future play() async {
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }
  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }
  void forward() {
    if(index == maListeDeMusiques.length - 1){
      index = 0;
    } else {
      index++;
    }
    maMusiqueActuelle = maListeDeMusiques[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();

  }

  String fromDuration(Duration duree){
    return duree.toString().split('.').first;
  }

  void rewind() {
    if(position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else {
      if(index == 0) {
        index = maListeDeMusiques.length - 1 ;
      } else {
        index-- ;
      }
      maMusiqueActuelle = maListeDeMusiques[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }
}
 enum ActionMusic {//nous permet deffectuer differentes actions pour une fonction
  play,
  pause,
  rewind,
  forward,
 }
 enum PlayerState {// gerer les differentes etats de notre music
  playing,
  paused,
  stopped,
 }