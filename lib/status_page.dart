import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class StatusPage extends StatefulWidget {
  StatusPage({Key key, this.celebrity, this.youtubeId, this.taskId})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String celebrity;
  final String youtubeId;
  final String taskId;
  final String title = "Illusion";

  @override
  _StatusPageState createState() => _StatusPageState();
}

enum AgreeValue { yes, no, unsure }

class _StatusPageState extends State<StatusPage> {
  StreamController _StatusController;
  String lastStatus = "";
  var showForm = true;
  loadStatus() async {
    getStatus().then((res) async {
      if (lastStatus != res) _StatusController.add(res);
      return res;
    });
  }

  @override
  void initState() {
    super.initState();
    _StatusController = StreamController();
    Timer.periodic(Duration(seconds: 10), (_) => loadStatus());
  }

  Future<void> detectHttp(
      String youtubeId, String celebrity, String category) async {
    var url = Uri.http('mirage.omniate.com:5000', '/train',
        {'celebrity': celebrity, 'youtubeid': youtubeId, 'category': category});

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      print(response.body.toString());
      setState(() {
        // This call to setState tells the Flutter framework that something has
        // changed in this State, which causes it to rerun the build method below
        // so that the display can reflect the updated values. If we changed
        // _counter without calling setState(), then the build method would not be
        // called again, and so nothing would appear to happen.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    AgreeValue _agreement = AgreeValue.yes;
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: true,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: new StreamBuilder(
        stream: _StatusController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Exception: ${snapshot.error}");
          }

          if (snapshot.hasData) {
            String status = snapshot.data;
            if (status == "PENDING") {
              return Center(
                child: new Container(
                  // Center is a layout widget. It takes a single child and positions it
                  // in the middle of the parent.
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          // Column is also a layout widget. It takes a list of children and
                          // arranges them vertically. By default, it sizes itself to fit its
                          // children horizontally, and tries to be as tall as its parent.
                          //
                          // Invoke "debug painting" (press "p" in the console, choose the
                          // "Toggle Debug Paint" action from the Flutter Inspector in Android
                          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                          // to see the wireframe for each widget.
                          //
                          // Column has various properties to control how it sizes itself and
                          // how it positions its children. Here we use mainAxisAlignment to
                          // center the children vertically; the main axis here is the vertical
                          // axis because Columns are vertical (the cross axis would be
                          // horizontal).
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Analyzing the video",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 30),
                            Text("Celebrity: " + widget.celebrity),
                            SizedBox(height: 15),
                            Text("YouTube ID: " + widget.youtubeId),
                            SizedBox(height: 50),
                            CircularProgressIndicator()
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Center(
                child: new Container(
                  height: 900,
                  // Center is a layout widget. It takes a single child and positions it
                  // in the middle of the parent.
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          // Column is also a layout widget. It takes a list of children and
                          // arranges them vertically. By default, it sizes itself to fit its
                          // children horizontally, and tries to be as tall as its parent.
                          //
                          // Invoke "debug painting" (press "p" in the console, choose the
                          // "Toggle Debug Paint" action from the Flutter Inspector in Android
                          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                          // to see the wireframe for each widget.
                          //
                          // Column has various properties to control how it sizes itself and
                          // how it positions its children. Here we use mainAxisAlignment to
                          // center the children vertically; the main axis here is the vertical
                          // axis because Columns are vertical (the cross axis would be
                          // horizontal).
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            YoutubePlayer(
                              controller: _controller,
                              showVideoProgressIndicator: true,
                            ),
                            SizedBox(height: 50),
                            Text("Video Analysis Complete",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            Text("Celebrity: " + widget.celebrity),
                            SizedBox(height: 7),
                            Text("YouTube ID: " + widget.youtubeId),
                            SizedBox(height: 7),
                            (status.split(" ").first == "False")
                                ? Text("Video classification: deepfake")
                                : Text("Video classification: real"),
                            SizedBox(height: 7),
                            Text("Confidence Level: " +
                                (double.parse(status.split(" ").last) * 100)
                                    .toString() +
                                "%"),
                            SizedBox(height: 15),
                            showForm
                                ? Text("Do you agree with the results?",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold))
                                : SizedBox(height: 15),
                            showForm
                                ? Column(
                                    children: <Widget>[
                                      ListTile(
                                        title: const Text('Yes'),
                                        leading: Radio<AgreeValue>(
                                          value: AgreeValue.yes,
                                          groupValue: _agreement,
                                          onChanged: (AgreeValue value) {
                                            setState(() {
                                              _agreement = value;
                                            });
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('No'),
                                        leading: Radio<AgreeValue>(
                                          value: AgreeValue.no,
                                          groupValue: _agreement,
                                          onChanged: (AgreeValue value) {
                                            setState(() {
                                              _agreement = value;
                                            });
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('Not sure'),
                                        leading: Radio<AgreeValue>(
                                          value: AgreeValue.unsure,
                                          groupValue: _agreement,
                                          onChanged: (AgreeValue value) {
                                            setState(() {
                                              _agreement = value;
                                            });
                                          },
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            showForm = false;
                                          });
                                          var category =
                                              status.split(" ").first;

                                          if ((_agreement == AgreeValue.yes &&
                                                  category == "False") ||
                                              (_agreement == AgreeValue.no &&
                                                  category == "True")) {
                                            detectHttp(widget.youtubeId,
                                                widget.celebrity, "fake");
                                            print(_agreement);
                                          } else if ((_agreement ==
                                                      AgreeValue.yes &&
                                                  category == "True") ||
                                              (_agreement == AgreeValue.no &&
                                                  category == "False")) {
                                            detectHttp(widget.youtubeId,
                                                widget.celebrity, "real");
                                            print(_agreement);
                                          }
                                        },
                                        child: const Text('Submit'),
                                      ),
                                    ],
                                  )
                                : Text("Thanks for the feedback. ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }

          if (snapshot.connectionState != ConnectionState.waiting) {
            return Center(
              child: new Container(
                height: 300,
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          Text(
                            "Sending information for analysis",
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 20),
                          new CircularProgressIndicator()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData &&
              snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: new Container(
                height: 300,
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          Text(
                            "Sending information for analysis",
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 20),
                          new CircularProgressIndicator()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return null;
        },
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<String> getStatus() async {
    var url = Uri.http('mirage.omniate.com:5000', '/status/' + widget.taskId);

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      String result = response.body.toString();
      return result;
    }
  }
}
