import 'dart:io';
import 'dart:typed_data';

import 'package:RSAp/helpers/rsa_encryption_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class EncryptScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EncryptScreenState();
  }
}

class _EncryptScreenState extends State<EncryptScreen> {
  var _textFieldController = TextEditingController();
  var _pemPublicKey = "";
  Uint8List _encryptedMessage;
  String _plainText;
  final _key = GlobalKey();

  Future<void> _saveEncryptedMessage() async {
    final _fileName = "encrypted_message.txt";
    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {
      File('/storage/emulated/0/Download/$_fileName').writeAsBytes(_encryptedMessage);
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

  void _encrypt(BuildContext context) async {
    if (_pemPublicKey != "") {
      var cipher = RSAEncryptionHelper.rsaEncrypt(
          _pemPublicKey, Uint8List.fromList(_plainText.codeUnits));
      setState(() {
        _encryptedMessage = cipher;
      });
      await _saveEncryptedMessage();
      (_key.currentState as ScaffoldState).showSnackBar(SnackBar(
        content: Text("Encrypted message saved !"),
      ));
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
        title: Text('Encrypt Text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  _encrypt(context);
                },
                child: Text('Encrypt !')),
          ],
        ),
      ),
    );
  }
}
