import 'dart:io';
import 'dart:typed_data';

import 'package:RSAp/helpers/rsa_sign_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CheckSignature extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CheckSignatureState();
  }
}

class _CheckSignatureState extends State<CheckSignature> {
  var _textFieldController = TextEditingController();
  var _pemPublicKey = "";
  var _signature;
  var _result;
  var _showResult = false;
  String _plainText;
  final _key = GlobalKey();

  void _checkSignature() async {
    if (_pemPublicKey != "") {
      var isCorrect = RSASignHelper.rsaVerify(
          _pemPublicKey, Uint8List.fromList(_plainText.codeUnits), _signature);
      setState(() {
        _result = isCorrect;
        _showResult = true;
      });
    }
  }

  void _openPublicKeyFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path);
      var tmp = await file.readAsString();
      setState(() {
        _pemPublicKey = tmp;
      });
    }
  }

  void _openSignatureFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path);
      var tmp = await file.readAsBytes();
      setState(() {
        _signature = tmp;
      });
    }
  }

  void _openTextFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path);
      var tmp = await file.readAsString();
      setState(() {
        _plainText = tmp;
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
        title: Text('Check signature'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_signature == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.close), Text('No signature')],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.check), Text('Signature loaded')],
              ),
            RaisedButton(
                onPressed: () {
                  _openSignatureFile();
                },
                child: Text('Open signature file')),
            if (_pemPublicKey == "")
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.close), Text('No public key')],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.check), Text('Public key loaded')],
              ),
            RaisedButton(
                onPressed: () {
                  _openPublicKeyFile();
                },
                child: Text('Open public key file')),
            TextField(
                onChanged: (String msg) {
                  setState(() {
                    _plainText = msg;
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
                  _checkSignature();
                },
                child: Text('Check signature !')),
            Divider(),
            if (_showResult)
              if (_result)
                Center(
                    child: Text("OK",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)))
              else
                Center(
                    child: Text("NOK",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)))
          ],
        ),
      ),
    );
  }
}
