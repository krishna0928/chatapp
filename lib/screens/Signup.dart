import 'package:chatapp/Services/Authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String userName, email, password;
  bool hidePassword = true;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                Colors.orange[800],
                Colors.orange[600],
                Colors.orange[400],
              ])),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Register",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 15),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(60),
                              topRight: Radius.circular(60))),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: Column(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Color.fromRGBO(225, 95, 27, .3),
                                          blurRadius: 20,
                                          offset: Offset(0, 10))
                                    ]),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[300]))),
                                        child: TextFormField(
                                          onChanged: (value) {
                                            userName = value;
                                          },
                                          validator: (value) {
                                            return (value.isEmpty)
                                                ? 'Invalid user name'
                                                : null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: "User name",
                                            hintStyle: TextStyle(
                                                color: Colors.grey,
                                                letterSpacing: 1.0),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[300]))),
                                        child: TextFormField(
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          onChanged: (value) {
                                            email = value.trim();
                                          },
                                          validator: (value) {
                                            return (value.isEmpty ||
                                                    !value.contains('@') ||
                                                    !value.contains('.'))
                                                ? 'Invalid Email'
                                                : null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: "Email",
                                            fillColor: Colors.deepOrange,
                                            hintStyle: TextStyle(
                                                color: Colors.grey,
                                                letterSpacing: 1.0),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[300]))),
                                        child: TextFormField(
                                          onChanged: (value) {
                                            password = value;
                                          },
                                          validator: (value) {
                                            return (value.isEmpty ||
                                                    value.length < 6)
                                                ? 'Invalid Password'
                                                : null;
                                          },
                                          style: TextStyle(letterSpacing: 1.5),
                                          obscureText: hidePassword,
                                          decoration: InputDecoration(
                                              hintText: "Password",
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  Icons.remove_red_eye,
                                                  color:
                                                      Colors.deepOrangeAccent,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    hidePassword =
                                                        !hidePassword;
                                                  });
                                                },
                                              ),
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  letterSpacing: 1.0),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[200]))),
                                        child: TextFormField(
                                          validator: (value) {
                                            return (value != password)
                                                ? 'Passwords did\'nt Match'
                                                : null;
                                          },
                                          style: TextStyle(letterSpacing: 1.5),
                                          obscureText: hidePassword,
                                          decoration: InputDecoration(
                                              hintText: "Re-Enter Password",
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  Icons.remove_red_eye,
                                                  color:
                                                      Colors.deepOrangeAccent,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    hidePassword =
                                                        !hidePassword;
                                                  });
                                                },
                                              ),
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  letterSpacing: 1.0),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              RaisedButton(
                                  padding: EdgeInsets.symmetric(vertical: 12 , horizontal: 27),
                                  color: Colors.deepOrangeAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      createUser();
                                    }
                                  },
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                        fontSize: 16.0),
                                  )),
                              SizedBox(
                                height: 20,
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Having an Account? Login here !",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16.0),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                errorMessage,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  void createUser() async {
    setState(() {
      loading = true;
    });
    try {
      final result = await AuthServices()
          .registerWithEmailAndPass(email, password, userName);

      if (result != true) {
        setState(() {
          loading = false;
          errorMessage = result.toString();
        });
      } else {
        Phoenix.rebirth(context);
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }
}
