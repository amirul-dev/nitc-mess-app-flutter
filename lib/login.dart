import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:validators/validators.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final storage = new FlutterSecureStorage();
  String _email, _password, _error;
  bool _isLoading = false;
  final url = "https://nitc-mess.herokuapp.com";
  final GlobalKey<FormState> _loginkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final email = Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 10.0),
      child: TextFormField(
        validator: (value) {
          if (isEmail(value)) {
            return null;
          } else {
            return "Enter a valid Email";
          }
        },
        onSaved: (String value) {
          this._email = value;
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            labelText: "Email",
            border: OutlineInputBorder()),
      ),
    );
    final password = Padding(
      padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 10.0),
      child: TextFormField(
        onSaved: (value) {
          this._password = value;
        },
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            labelText: "Password",
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black))),
      ),
    );
    _login() async {
      if (_loginkey.currentState.validate()) {
        _loginkey.currentState.save();
        print(_email);
        print(_password);
        http.Response response = await http.post(url + '/api/auth/signin',
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body:
                convert.json.encode({'email': _email, 'password': _password}));
        print(_email);
        print(_password);
        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200) {
          var jsonResponse = convert.jsonDecode(response.body);
          storage.write(key: 'token', value: jsonResponse['token']);
          print(jsonResponse);
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (response.statusCode == 500) {
          setState(() {
            final errorTxt =
                convert.json.decode(response.body)['errors']['message'];
            print(errorTxt);
            _error = errorTxt;
          });
        }
      }
    }

    final signinbtn = Padding(
        padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 10.0),
        child: SizedBox(
          height: 55,
          child: RaisedButton(
            color: Colors.blue,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            child: Center(
                child: Text(
              "Login",
              style: TextStyle(color: Colors.white),
            )),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await _login();
              setState(() {
                _isLoading = false;
              });
            },
          ),
        ));
    
    final errormsg = Container(
      padding: EdgeInsets.all(5),
      alignment: Alignment.center,
      child: (Text(
        "ERROR: " + _error,
        style: GoogleFonts.robotoMono(
          fontSize: 15,
          textStyle: TextStyle(
            color: Colors.red
          )
        )
      )),
    );
    Widget _submit() {
      if (_isLoading) {
        return CircularProgressIndicator();
      } else if (_error != null) {
        return Column(
          children: <Widget>[
            signinbtn,
            errormsg
          ],
        );
      } else {
        return signinbtn;
      }
    }
    Widget login() => Form(
          key: _loginkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 50, top: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/icon1.png',
                      width: 150,
                      height: 150,
                    )
                  ],
                ),
              ),
              email,
              password,
              _submit(),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("NITC MESS",
            style: GoogleFonts.abel(
                textStyle: TextStyle(fontWeight: FontWeight.bold))),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[login()],
        ),
      ),
    );
  }
}
