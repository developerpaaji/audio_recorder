import 'dart:io' as io;
import 'dart:io';
import 'dart:math';

import 'package:audio_recorder/audio_recorder.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin audio recorder'),
        ),
        body: RecorderScreen(noOfParticipants: 1),
      ),
    );
  }
}

class RecorderScreen extends StatefulWidget {
  final int noOfParticipants;

  const RecorderScreen({Key key,@required this.noOfParticipants}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen>
    with TickerProviderStateMixin<RecorderScreen> {
  AnimationController controller;
  AudioRecorder recorder;
  String recordingPath;
  String message = "Initialising";
  bool isPaused=false;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(hours: 1),
    );
    startRecording();
  }

  void showCancelDialog(){
    showDialog(context: context,builder: (context)=>CupertinoAlertDialog(
      title: Text("Are you sure?"),
      content: Text("You will lost all your recording if you exit"),
      actions: <Widget>[
        CupertinoActionSheetAction(child: Text("Cancel"),onPressed: (){
          Navigator.of(context).pop();
        },),
        CupertinoActionSheetAction(child: Text("Ok"),onPressed: (){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: ()async{
        showCancelDialog();
        return false;
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          previousPageTitle: "Back",
          middle: Text("Record"),
        ),
        child: Material(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  message,
                  style: TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 12.0,
                ),
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    Duration duration =
                    Duration(seconds: (durationSeconds).toInt());
                    return Text(
                      "${parseString(duration.inHours)} : ${parseString(duration.inMinutes)} : ${parseString(duration.inSeconds % 60)}",
                      style:
                      TextStyle(fontSize: 40.0, fontWeight: FontWeight.w700),
                    );
                  },
                  child: Container(
                    width: 00.0,
                    height: 0.0,
                  ),
                ),
                SizedBox(height: 36.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(icon: Icon(Icons.play_arrow,color: Colors.transparent,), onPressed: null,),
                    FloatingActionButton(
                      onPressed: isRecording!=null?() async{
                        if(isRecording){
                          await pauseRecording();
                        }
                        else{
                          await resumeRecording();
                        }
                      }:null,
                      child: Icon(!(isRecording??false) ? Icons.play_arrow : Icons.pause),
                    ),
                    IconButton(icon: Icon(Icons.stop),onPressed: isRecording!=null?(){
                      stopRecording();
                    }:null),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isRecording ;

  int get  durationSeconds => (controller.value * 60 * 60).toInt();

  String parseString(int number) {
    if (number < 10) {
      return "0$number";
    }
    return "$number";
  }
  Future<bool> checkPermissions()async{
    return true;
  }
  void startRecording() async {
    String path=await getPath();
    bool check=await checkPermissions();
    if(!check){
      Navigator.of(context).pop();
    }
    await AudioRecorder.start(path: path);
    if (mounted)
      setState(() {
        isRecording = true;
        message = "Recording";
        controller.forward(from: 0.0);
      });
  }

  Future resumeRecording()async{
    print("Resume");

    await AudioRecorder.resume();
    controller.forward();
    if(mounted){
      setState(() {
        isRecording=true;
        message="Recording";
      });
    }
  }

  Future pauseRecording()async{
    await AudioRecorder.pause();
    controller.stop(canceled: false);
    if(mounted){
      setState(() {
        isRecording=false;
        message="Paused";
      });
    }
  }

  Future stopRecording() async {
    bool isRecording=await AudioRecorder.isRecording;
    if (!isRecording) return null;
    Recording result=await AudioRecorder.stop();
    print("Path ${result.path}");
    if (mounted)
      setState(() {
        isRecording = false;
        message = "Stopped";
        controller.stop(canceled: true);
      });

  }

  Future<String> getPath() async {
    Directory extDir = await getExternalStorageDirectory();
    String extPath = extDir.path;
    String path = "$extPath/${DateTime.now().toIso8601String()}";
    return path;
  }

  @override
  void dispose() {
    AudioRecorder.stop();
    controller.dispose();
    super.dispose();
  }
}
