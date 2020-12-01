import 'dart:io';
import 'dart:typed_data';

import 'package:RSAp/helpers/rsa_sign_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignScreenState();
  }
}

class _SignScreenState extends State<SignScreen> {
  var _textFieldController = TextEditingController();
  Uint8List _signature;
  String _text;
  final _key = GlobalKey();

  Future<void> _saveSignature() async {
    final _fileName = "signature.txt";
    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {
      File('/storage/emulated/0/Download/$_fileName').writeAsBytes(_signature);
    }
  }

  Future<bool> _requestPermissions() async {
    var permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
    }
    return permission == PermissionStatus.granted;
  }

  void _sign(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('private_key');
    var signature = RSASignHelper.rsaSign(
        privateKey, Uint8List.fromList(_text.codeUnits));
    setState(() {
      _signature = signature;
    });
    await _saveSignature();
    (_key.currentState as ScaffoldState).showSnackBar(SnackBar(
      content: Text("Signature saved saved !"),
    ));
  }

  void _openTextFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path);
      var tmp = await file.readAsString();
      setState(() {
        _text = tmp;
      });
    }
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Sign Text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                onChanged: (String msg) {
                  setState(() {
                    _text = msg;
                  });
                },
                controller: _textFieldController,
                decoration: InputDecoration(hintText: 'Enter your text')),
            Text('or'),
            RaisedButton(
                onPressed: () {
                  _openTextFile();
                },
                child: Text('Open text file')),
            RaisedButton(
                onPressed: () {
                  _sign(context);
                },
                child: Text('Sign !')),
          ],
        ),
      ),
    );
  }
}
