import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data.dart';

final FirebaseApp app = FirebaseApp();

void main() => runApp(new MaterialApp(
  theme: ThemeData(
    primaryColor:Colors.blue,
    accentColor: Colors.blueAccent,
    fontFamily: 'arial',
  ),
  debugShowCheckedModeBanner: false,
  home: HomeScreen(),
));

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
    item = Item("");
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRef = database.reference().child('data');
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
    return Scaffold(
      key:scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('SHUN QRCode Scanner',style: TextStyle(fontFamily: 'dark'),),
      ),
      body: Center(
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(200.0, 20.0, 200.0, 20.0),
                width: 5,
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
                      height: 20,
                    ),
                    new TextFormField(
                      initialValue: "",
                      onSaved: (val) => item.title = val,
                      validator: (val) => val == "" ? val : null,
                      decoration: InputDecoration(
                          labelText: 'Paste disini'
                      ),
                    ),
                  ]),
                ),
              ),
              SizedBox(height: 200),
              Center(
              child : Column(
                children: <Widget>[
                  IconButton(
                    onPressed: (){
                      handleSubmit();
                    },
                    icon: Icon(Icons.send),
                  ),
                  MaterialButton(
                    child: Text("Lihat Data!"),
                    onPressed: (){
                      Navigator.push(
                          context,
                      MaterialPageRoute(builder: (context) => DataHasil()));
                    },
                    height: 50,
                    color: Colors.greenAccent,
                    minWidth: 20,
                    textColor: Colors.white,
                    splashColor: Colors.green,
                  ),
                ],
              ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(padding: EdgeInsets.all(40),
                child:MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                  ),
                  height: 50,
                  color: Colors.black26,
                  minWidth: 20,
                  textColor: Colors.white,
                  splashColor: Colors.green,
                  onPressed: _scanQR,
                  child: const Text('SCAN!')
              ),
          ),
              Center(
                child: Text("Lutfi_Ardiansyah",
                style: TextStyle(fontSize: 20,fontFamily: 'dark'),),
              ),
            ],
          ),
      ),
    );
  }
}
class Item {
  String key;
  String title;
  String body;

  Item(this.title);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        title = snapshot.value["title"];

  toJson() {
    return {
      "title": title,
    };
  }
}
