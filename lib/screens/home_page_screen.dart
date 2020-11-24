import 'dart:io';

import 'package:cyber_secu_project/helpers/rsa_helper.dart';
import 'package:cyber_secu_project/screens/decrypt_screen.dart';
import 'package:cyber_secu_project/screens/encrypt_screen.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageScreenState();
  }
}

class _HomePageScreenState extends State<HomePageScreen> {
  bool _ok = false;
  String _message = "Keys generated";

  void _generateKey() async {
    final pair = RSAHelper.generateRSAKeyPair();
    _savePublicKey(pair.publicKey);
    _savePrivateKey(pair.privateKey);
    setState(() {
      _ok = true;
    });
  }

  Future<bool> _privateKeyExists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('private_key');
  }

  Future<void> _savePublicKey(RSAPublicKey rsaPublicKey) async {
    final _fileName = "id_rsa.pub";
    final dir = await DownloadsPathProvider.downloadsDirectory;
    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {
      File('${dir.path}/$_fileName')
          .writeAsString(await RSAHelper.encodePublicKeyToPem(rsaPublicKey));
    }
  }

  void _savePrivateKey(RSAPrivateKey rsaPrivateKey) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'private_key', await RSAHelper.encodePrivateKeyToPem(rsaPrivateKey));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Hello'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_ok)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.check), Text(_message)],
              ),
            Container(
              height: 20,
              child: FutureBuilder<bool>(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  if (snapshot.data) {
                    return Text('Private key already exists');
                  } else {
                    return Text('No private key found');
                  }
                },
                future: _privateKeyExists(),
              ),
            ),
            RaisedButton(
                onPressed: () async {
                  _generateKey();
                },
                child: Text('Generate keys pair')),
            RaisedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DecryptScreen()));
                },
                child: Text('Decrypt')),
            RaisedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EncryptScreen()));
                },
                child: Text('Encrypt'))
          ],
        ),
      ),
    );
  }
}
