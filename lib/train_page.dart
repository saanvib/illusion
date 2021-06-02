import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mirage/trainstatus_page.dart';

class TrainPage extends StatefulWidget {
  TrainPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _TrainPageState createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  String result = "nothing";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  final celebController = TextEditingController();
  String celebrity = "";
  bool checkedValue = true;
  TextStyle labelStyle = TextStyle(color: Colors.blue[700]);
  UnderlineInputBorder lineStyle1 = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.blue[700], width: 1));
  UnderlineInputBorder lineStyle2 = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.blue[700], width: 2));

  @override
  void initState() {
    super.initState();
  }

  Future<void> detectHttp(
      String youtubeId, String celebrity, String category) async {
    var url = Uri.http('mirage.omniate.com:5000', '/train',
        {'celebrity': celebrity, 'youtubeid': youtubeId, 'category': category});

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      result = response.body.toString();
      print(result);
      setState(() {
        // This call to setState tells the Flutter framework that something has
        // changed in this State, which causes it to rerun the build method below
        // so that the display can reflect the updated values. If we changed
        // _counter without calling setState(), then the build method would not be
        // called again, and so nothing would appear to happen.
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TrainStatusPage(
                  celebrity: celebrity,
                  youtubeId: youtubeId,
                  taskId: result,
                  category: category)),
        );
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
    return Container(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
      padding: EdgeInsets.all(25.0),
      child: Card(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(25.0),
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Train models",
                  style: TextStyle(fontSize: 25.0, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                Text("Enter a YouTube link and celebrity name",
                    style: TextStyle(fontSize: 15.0, color: Colors.grey[800])),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 40),
                      TextFormField(
                        controller: myController,
                        decoration: InputDecoration(
                          icon: Container(
                              child: Icon(Icons.ondemand_video,
                                  color: Colors.grey),
                              margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                          labelText: "YouTube Link",
                          labelStyle: labelStyle,
                          enabledBorder: lineStyle1,
                          focusedBorder: lineStyle2,
                        ),
                        validator: (String value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      DropdownCustomWidget(onSelectChanged: (String x) {
                        setState(() {
                          celebrity = x;
                          print(celebrity);
                        });
                      }),
                      if (celebrity == "Other")
                        TextFormField(
                          controller: celebController,
                          decoration: const InputDecoration(
                            hintText: 'Enter celebrity last name (no spaces)',
                            labelText: 'Celebrity Name',
                          ),
                          validator: (String value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }

                            return null;
                          },
                        ),
                      SizedBox(height: 20),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: Text("Is the video real?"),
                        value: checkedValue,
                        onChanged: (newValue) {
                          setState(() {
                            checkedValue = newValue;
                            print(checkedValue);
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.
                            if (_formKey.currentState.validate()) {
                              if (celebrity == "Other")
                                celebrity = celebController.text;
                              String youtubeId;
                              if (myController.text.contains("="))
                                youtubeId = myController.text.split("=").last;
                              else
                                youtubeId = myController.text.split("/").last;

                              detectHttp(youtubeId, celebrity,
                                  checkedValue ? "real" : "fake");
                              print(youtubeId + " " + celebrity);
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

class DropdownCustomWidget extends StatefulWidget {
  Function(String) onSelectChanged;

  DropdownCustomWidget({Key key, this.onSelectChanged}) : super(key: key);
  @override
  _DropdownCustomWidget createState() => _DropdownCustomWidget();
}

/// This is the private State class that goes with MyStatefulWidget.
class _DropdownCustomWidget extends State<DropdownCustomWidget> {
  String dropdownValue = 'Select a celebrity';
  TextStyle labelStyle = TextStyle(color: Colors.blue[700]);
  UnderlineInputBorder lineStyle1 = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.blue[700], width: 1));
  UnderlineInputBorder lineStyle2 = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.blue[700], width: 2));

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      DropdownButtonFormField<String>(
        value: dropdownValue,
        icon: const Icon(Icons.arrow_downward),
        iconSize: 24,
        decoration: InputDecoration(
          icon: Container(
              child: Icon(Icons.person, color: Colors.grey),
              margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
          labelText: "Celebrity Name",
          labelStyle: labelStyle,
          enabledBorder: lineStyle1,
          focusedBorder: lineStyle2,
        ),
        elevation: 16,
        //style: const TextStyle(color: Colors.deepPurple),
        // underline: Container(
        //   height: 2,
        //   color: Colors.blueAccent,
        // ),
        onChanged: (String newValue) {
          setState(() {
            dropdownValue = newValue;
            widget.onSelectChanged(newValue);
          });
        },
        items: <String>[
          'Select a celebrity',
          'Trump',
          'Obama',
          'Elizabeth',
          'Other'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      )
    ]);
  }
}
