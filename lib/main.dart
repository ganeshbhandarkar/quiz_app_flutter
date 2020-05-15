import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Quiz App",
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.black45,
      appBar: AppBar(
        title: Text(
          "CS QUIZ APP",
          style: TextStyle(letterSpacing: 4),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Center(
                  child: Image(
                    image: AssetImage("assets/logo.png"),
                    width: 200,
                    height: 200,
                    color: Colors.teal,
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "CS QUIZ",
                  style: TextStyle(fontSize: 60, color: Colors.green),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                margin: EdgeInsets.all(40),
                width: 200,
                height: 60,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new QuizScreen()));
                  },
                  child: Text(
                    "START",
                    style: TextStyle(fontSize: 30),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: Colors.green[300],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {

  final String apiURL = "https://opentdb.com/api.php?amount=20&category=18&type=multiple";

  QuestionModel questionModel;

  int index = 0;

  int totalSec = 30;
  int elapsedTime = 0;
  int score = 0;

  Timer timer;


  @override
  void initState() {
    // TODO: implement initState

    _getQue();
    super.initState();
  }


  void _getQue() async {
    var response = await http.get(apiURL);

    var body = response.body;

    var json = jsonDecode(body);

    print(body);

    setState(() {
      questionModel = QuestionModel.fromJson(json);
      questionModel.results[index].incorrectAnswers.add(
          questionModel.results[index].correctAnswer
      );
      questionModel.results[index].incorrectAnswers.shuffle();
    });

    initTimer();
  }

  initTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t){
      if(t.tick == totalSec){
        t.cancel();
        changeQuestion();
      }else{
        setState(() {
          elapsedTime = t.tick;
        });
      }
    });
  }

  @override
  void dispose(){
    timer.cancel();
    super.dispose();
  }


  checkAnswer(answer) {
    String correctAnswer = questionModel.results[index].correctAnswer;
    if(correctAnswer == answer){
      score++;

    }else{
      print("wrong");
    }
    changeQuestion();
  }

  changeQuestion(){
    timer.cancel();

    if(index == questionModel.results.length - 1 ){
      print(score);
      Navigator.of(context).push(new MaterialPageRoute(builder: (context) => ResultScreen(scores: score,)));
    }else{
      setState(() {
        index++;
      });

      questionModel.results[index].incorrectAnswers.add(
          questionModel.results[index].correctAnswer
      );
      questionModel.results[index].incorrectAnswers.shuffle();

      initTimer();
    }
  }


  @override
  Widget build(BuildContext context) {
    return questionModel != null ? Scaffold(
      backgroundColor: Colors.black45,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage(
                      "assets/logo.png",
                    ),
                    width: 50,
                    height: 150,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "$elapsedTime s",
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  )
                ],
              ),
              Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    "${questionModel.results[index].question}",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  )),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 60,
                ),
                child: Column(
                  children: questionModel.results[index].incorrectAnswers
                      .map((option) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: 55,
                      child: RaisedButton(
                        colorBrightness: Brightness.dark,
                        color: Colors.white10,
                        onPressed: () {
                          checkAnswer(option);
                        },
                        child: Text(option, style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.normal),),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white30),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ),
      ),
    ) : Scaffold(backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(),),);
  }
}


class ResultScreen extends StatelessWidget {

  int scores;

  ResultScreen({this.scores});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Center(
                  child: Image(
                    image: AssetImage("assets/logo.png"),
                    width: 200,
                    height: 200,
                    color: Colors.teal,
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "$scores/20",
                  style: TextStyle(fontSize: 60, color: Colors.green),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                margin: EdgeInsets.all(40),
                width: 200,
                height: 60,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new QuizScreen()));
                  },
                  child: Text(
                    "RESTART",
                    style: TextStyle(fontSize: 30),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: Colors.green[300],
                ),
              ),
              Container(
                margin: EdgeInsets.all(40),
                width: 200,
                height: 60,
                child: RaisedButton(
                  onPressed: () => exit(0),
                  child: Text(
                    "QUIT",
                    style: TextStyle(fontSize: 30,color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                    side: BorderSide(color: Colors.white30)
                  ),
                  color: Colors.black38,
                ),
              )
            ],
          ),
        ),
      ),
    );;
  }
}



/// Model for Question
///
class QuestionModel {
  int responseCode;
  List<Results> results;

  QuestionModel({this.responseCode, this.results});

  QuestionModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    if (json['results'] != null) {
      results = new List<Results>();
      json['results'].forEach((v) {
        results.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['response_code'] = this.responseCode;
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String category;
  String type;
  String difficulty;
  String question;
  String correctAnswer;
  List<String> incorrectAnswers;

  Results({this.category,
    this.type,
    this.difficulty,
    this.question,
    this.correctAnswer,
    this.incorrectAnswers});

  Results.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    type = json['type'];
    difficulty = json['difficulty'];
    question = json['question'];
    correctAnswer = json['correct_answer'];
    incorrectAnswers = json['incorrect_answers'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category'] = this.category;
    data['type'] = this.type;
    data['difficulty'] = this.difficulty;
    data['question'] = this.question;
    data['correct_answer'] = this.correctAnswer;
    data['incorrect_answers'] = this.incorrectAnswers;
    return data;
  }
}