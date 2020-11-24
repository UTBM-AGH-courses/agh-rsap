import 'dart:io';
import 'dart:typed_data';

import 'package:cyber_secu_project/helpers/rsa_encryption_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DecryptScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DecryptScreenState();
  }
}

class _DecryptScreenState extends State<DecryptScreen> {
  Uint8List _encryptedMessage;
  Uint8List _decryptedMessage;
  final _key = GlobalKey();

  void _decrypt() async {
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('private_key');
    var test = RSAEncryptionHelper.rsaDecrypt(privateKey, _encryptedMessage);
    setState(() {
      _decryptedMessage = test;
    });
    (_key.currentState as ScaffoldState).showSnackBar(SnackBar(
      content: Text("Encrypted message decrypted !"),
    ));
  }

  void _openEncryptedMessage() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path);
      var tmp = await file.readAsBytes();
      setState(() {
        _encryptedMessage = tmp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text('Decrypt Text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
                onPressed: () {
                  _openEncryptedMessage();
                },
                child: Text('Open encrypted message')),
            RaisedButton(
                onPressed: _encryptedMessage != null
                    ? () {
                        _decrypt();
                      }
                    : null,
                child: Text('Decrypt !')),
            Divider(),
            Flexible(
              child: SingleChildScrollView(
                  child: Text(
                    String.fromCharCodes(_decryptedMessage ?? [0]),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25),
              )),
            )
          ],
        ),
      ),
    );
  }
}
