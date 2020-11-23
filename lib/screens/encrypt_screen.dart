import 'dart:io';
import 'dart:typed_data';

import 'package:cyber_secu_project/helpers/rsa_helper.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

class EncryptScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EncryptScreenState();
  }
}

class _EncryptScreenState extends State<EncryptScreen> {
  var _textFieldController = TextEditingController();
  var _pemPublicKey = "";
  var _encryptedMessage = "";
  var _decryptedMessage = "";

  void _generateKey() async {
    final pair = RSAHelper.generateRSAKeyPair();

    final public = await RSAHelper.encodePublicKeyToPem(pair.publicKey);
    final private = await RSAHelper.encodePrivateKeyToPem(pair.privateKey);
    print(public);
    print(private);
    _savePublicKey(pair.publicKey);
    if (await _checkPrivateKey()) {
      print("KEY EXISTS");
    }
    //_savePrivateKey(pair.privateKey);
  }

  Future<void> _savePublicKey(RSAPublicKey rsaPublicKey) async {
    final _fileName = "id_rsa.pub";
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {
      File('${dir.path}/$_fileName')
          .writeAsString(await RSAHelper.encodePublicKeyToPem(rsaPublicKey));
      print('OK');
    } else {
      // handle the scenario when user declines the permissions
    }
  }

  void _savePrivateKey(RSAPrivateKey rsaPrivateKey) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'private_key', await RSAHelper.encodePrivateKeyToPem(rsaPrivateKey));
  }

  Future<bool> _checkPrivateKey() async {
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('private_key');
    return privateKey != null;
  }

  Future<Directory> _getDownloadDirectory() async {
    return await DownloadsPathProvider.downloadsDirectory;
  }

  void _encrypt() {
    if (_pemPublicKey != "") {
      var test = encrypt(_textFieldController.text, RsaKeyHelper().parsePublicKeyFromPem(_pemPublicKey));
      setState(() {
        _encryptedMessage = test;
      });
    }
  }

  void _decrypt() async {
    final prefs = await SharedPreferences.getInstance();
    final privateKey = prefs.getString('private_key');
    var test = decrypt(_encryptedMessage, RsaKeyHelper().parsePrivateKeyFromPem(privateKey));
    setState(() {
      _decryptedMessage = test;
    });
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

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textFieldController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Encrypt Text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
                onPressed: () {
                  _generateKey();
                },
                child: Text('Generate RSA key pair')),
            RaisedButton(
                onPressed: () {
                  _openPublicKeyFile();
                },
                child: Text('Open public key file')),
            TextField(controller: _textFieldController),
            RaisedButton(onPressed: () {_encrypt();}, child: Text('Encrypt !')),
            RaisedButton(onPressed: () {_decrypt();}, child: Text('D !')),
            Text(_encryptedMessage),
            Divider(),
            Text(_decryptedMessage)
          ],
        ),
      ),
    );
  }
}
