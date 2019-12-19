import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

final FirebaseApp app = FirebaseApp();

void main() => runApp(new MaterialApp(
  theme: ThemeData(
    primaryColor:Colors.blue,
    accentColor: Colors.blueAccent,
    fontFamily: 'arial',
  ),
  debugShowCheckedModeBanner: false,
  home: new SplashScreen(seconds: 3,navigateAfterSeconds: HomeScreen(),
      title: new Text('SHUN QRcode scanner',
        style: new TextStyle(
            fontFamily: 'dark',
            fontWeight: FontWeight.bold,
            fontSize: 20.0
        ),),
      backgroundColor: Colors.lightBlue,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      onClick: ()=>print("Lutfi Ardianysah"),
      loaderColor: Colors.red
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
    item = Item("","");
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
            color: Color.fromRGBO(0, 179, 134, 1.0),
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
      appBar: AppBar(
        centerTitle: true,
        title: Text('SHUN QRCode Scanner',style: TextStyle(fontFamily: 'dark'),),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.info_outline),
            onPressed: () {

            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
              children: <Widget>[
                Center(
                  child:Form(
                    key: formKey,
                    child: Column(
                        children: <Widget>[
                          new GestureDetector(
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
                            height: 40.0,
                          ),
                          new TextFormField(
                            initialValue: "",
                            onSaved: (val) => item.title = val,
                            validator: (val) => val == "" ? val : null,
                            decoration: InputDecoration(
                                labelText: 'Paste disini'
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          new TextFormField(
                            initialValue: "",
                            onSaved: (val) => item.name = val,
                            validator: (val) => val == "" ? val : null,
                            decoration: InputDecoration(
                                labelText: 'NIS Anda'
                            ),
                          ),
                          SizedBox(
                            height: 50.0,
                          ),
                        ]),
                  ),
                ),
                Center(
                  child : Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: (){
                          handleSubmit();
                        },
                        icon: Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(padding: EdgeInsets.all(5),
                  child:MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                      height: SizeConfig.safeBlockVertical * 5,
                      minWidth: SizeConfig.safeBlockHorizontal * 5,
                      color: Colors.orange,
                      textColor: Colors.white,
                      splashColor: Colors.green,
                      onPressed: _scanQR,
                      child: const Text('SCAN!')
                  ),
                ),
                SizedBox(
                  height: 100.0,
                ),
                Center(
                  child: Text("Lutfi_Ardiansyah",
                    style: TextStyle(fontSize: 20,fontFamily: 'dark'),),
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

  Item(this.title,this.name);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value["name"],
        title = snapshot.value["title"];


  toJson() {
    return {
      "title": title,
      "name": name,
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
