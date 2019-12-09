import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';

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
  FirebaseDatabase database = new FirebaseDatabase();

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
           result = "Permission was denied!";
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

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = new GlobalKey<ScaffoldState>();
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
                      decoration: InputDecoration(
                          labelText: 'Paste disini'
                      ),
                    ),
                  ]),
              ),
              SizedBox(height: 200),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 60.0),
                child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    height: 50,
                    color: Colors.green,
                    minWidth: 20,
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: (){},
                    child: const Text('Simpan')
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