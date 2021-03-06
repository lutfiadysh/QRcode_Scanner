import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

final FirebaseApp app = FirebaseApp();

void main() => runApp(new MaterialApp(
  theme: ThemeData(
    primaryColor:Colors.blue,
    accentColor: Colors.blueAccent,
    fontFamily: 'primary',
  ),
  debugShowCheckedModeBanner: false,
  home: new SplashScreen(seconds: 3,navigateAfterSeconds: HomeScreen(),
      title: new Text('SHUN QRcode scanner',
        style: new TextStyle(
            fontFamily: 'nice',
            fontWeight: FontWeight.bold,
            fontSize: 20.0
        ),),
      backgroundColor: Colors.transparent,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      onClick: ()=>print("Lutfi Ardianysah"),
      loaderColor: Colors.greenAccent
      ),
    ),
  );

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Item> items = List();
  Item item;
  DatabaseReference itemRef;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState()
  {
    super.initState();
    item = Item("","","","");
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRef = database.reference().child('data/shun');
    itemRef.onChildAdded.listen(_onEntryAdded);
    itemRef.onChildChanged.listen(_onEntryChanged);
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      items[items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      itemRef.push().set(item.toJson());
      Alert(
        context: context,
        title: "Berhasil",
        desc: "Data berhasil tersimpan.",
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            color: Colors.lightBlueAccent,
            radius: BorderRadius.circular(0.0),
          ),
        ],
      ).show();
    }
  }

  String result = "Selamat Datang !";
  Future _scanQR() async {
    try{
      String qrResult = await BarcodeScanner.scan();
      setState(() {
            result = qrResult;
      });
    }on PlatformException catch(ex){
      if(ex.code == BarcodeScanner.CameraAccessDenied){
         setState(() {
           result = "Izinkan menggukan Camera!";
         });
      }else{
        setState(() {
          result = "Unkown Error $ex";
        });
      }
    } on FormatException{
      setState(() {
        result = "Anda menekan tombol kembali";
      });
    } catch(ex){
      setState(() {
        result = "Unkown Error $ex";
      });
    }
  }

  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key:scaffoldKey,
      body: ListView(
        padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
              children: <Widget>[
                new Stack(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 50.0),
                          child: Image.asset("assets/vector_laptop.png"),
                        ),
                      ],
                    ),
                    new Container(
                      margin: EdgeInsets.fromLTRB(0.0, 200.0, 0.0, 0.0),
                      padding: EdgeInsets.fromLTRB(20.0, 0.0,20.0, 0.0),
                      decoration: BoxDecoration(
                          color:Colors.white ,
                          borderRadius: BorderRadius.circular(7.0),
                          boxShadow: [
                            new BoxShadow(
                              blurRadius: 20.0,
                              offset: const Offset(3.0, 3.0),
                              color: Colors.grey,
                            )
                          ]
                      ),
                      alignment: Alignment.center,
                      child:Form(
                        key: formKey,
                        child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 30.0,
                              ),
                              GestureDetector(
                                child:Text(result,
                                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                                ),
                                onLongPress: () {
                                  Clipboard.setData(new ClipboardData(text: result));
                                  scaffoldKey.currentState.showSnackBar(
                                      new SnackBar(content: new Text("Berhasil di Copy!")));
                                },
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Divider(
                                height: 3.0,
                                color: Colors.black,
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Row(

                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
                                    CircularGradientButton(
                                      child: Icon(Icons.camera_alt),
                                      callback: (){
                                        _scanQR();
                                      },
                                      gradient: Gradients.backToFuture,
                                      shadowColor: Gradients.rainbowBlue.colors.last.withOpacity(0.5),
                                    ),
                                  ),

                                  Column(
                                    children: <Widget>[
                                        new Text("Scan Disini"),

                                    ],
                                  )


                                ],
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              new TextFormField(
                                initialValue: "",
                                onSaved: (val) => item.title = val,
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return 'Mohon Isi dulu';
                                  }
                                  return null;
                                },
                                decoration: new InputDecoration(
                                  labelText: "Paste hasil scan disini...",
                                  fillColor: Colors.white,
                                  border: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(10.0),
                                    borderSide: new BorderSide(
                                    ),
                                  ),
                                  //fillColor: Colors.green
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              new TextFormField(
                                initialValue: "",
                                onSaved: (val) => item.name = val,
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return 'Mohon Isi dulu';
                                  }
                                  return null;
                                },
                                decoration: new InputDecoration(
                                  labelText: "NIS",
                                  fillColor: Colors.white,
                                  border: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(10.0),
                                    borderSide: new BorderSide(
                                    ),
                                  ),
                                  //fillColor: Colors.green
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              new TextFormField(
                                initialValue: "",
                                onSaved: (val) => item.rombel = val,
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return 'Mohon Isi dulu';
                                  }
                                  return null;
                                },
                                decoration: new InputDecoration(
                                  labelText: "Rombel",
                                  fillColor: Colors.white,
                                  border: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(10.0),
                                    borderSide: new BorderSide(
                                    ),
                                  ),
                                  //fillColor: Colors.green
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              new TextFormField(
                                initialValue: "",
                                onSaved: (val) => item.rayon = val,
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return 'Mohon Isi dulu';
                                  }
                                  return null;
                                },
                                decoration: new InputDecoration(
                                  labelText: "Rayon",
                                  fillColor: Colors.white,
                                  border: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(10.0),
                                    borderSide: new BorderSide(
                                    ),
                                  ),
                                  //fillColor: Colors.green
                                ),
                              ),
                              SizedBox(
                                height: 40.0,
                              ),
                            ]),
                      ),
                    ),
                    Center(
                      child:Container(
                        alignment: Alignment.bottomLeft,
                        margin: EdgeInsets.only(top: 690.0),
                        child: CircularGradientButton(
                          child: Icon(Icons.send),
                          callback: (){
                            handleSubmit();
                          },
                          gradient: Gradients.rainbowBlue,
                          shadowColor: Gradients.rainbowBlue.colors.last.withOpacity(1.0),
                        ),

                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40.0,
                ),
                Center(
                  child: Text("Lutfi_Ardiansyah",
                    style: TextStyle(fontSize: 15,fontFamily: 'nice'),),
                ),
                SizedBox(
                  height: 10.0,
                ),
              ],
      ),
    );
  }
}
class Item {
  String key;
  String title;
  String name;
  String rombel;
  String rayon;

  Item(this.title,this.name,this.rombel,this.rayon);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value["name"],
        title = snapshot.value["title"],
        rombel = snapshot.value["rombel"],
        rayon = snapshot.value["rayon"];


  toJson() {
    return {
      "title": title,
      "name": name,
      "rombel":rombel,
      "rayon":rayon,
    };
  }
}

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;
  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context){
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth/100;
    blockSizeVertical = screenHeight/100;
    _safeAreaHorizontal = _mediaQueryData.padding.left +
        _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top +
        _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal)/100;
    safeBlockVertical = (screenHeight - _safeAreaVertical)/100;
  }
}
