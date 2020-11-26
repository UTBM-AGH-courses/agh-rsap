import 'dart:io';

import 'package:RSAp/helpers/rsa_helper.dart';
import 'package:RSAp/screens/decrypt_screen.dart';
import 'package:RSAp/screens/encrypt_screen.dart';
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
  final _key = GlobalKey();

  void _generateKey() async {
    final pair = RSAHelper.generateRSAKeyPair();
    _savePublicKey(pair.publicKey);
    _savePrivateKey(pair.privateKey);
    setState(() {
      _ok = true;
    });
    (_key.currentState as ScaffoldState).showSnackBar(SnackBar(
      content: Text("Public key saved in the Download directory !"),
    ));
  }

  Future<bool> _privateKeyExists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('private_key');
  }

  Future<void> _savePublicKey(RSAPublicKey rsaPublicKey) async {
    final _fileName = "id_rsa.pub";
    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {
      File('/storage/emulated/0/Download/$_fileName')
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
      key: _key,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('RSAp - Encrypt your messages !'),
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
              child: FutureBuilder<bool>(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  if (snapshot.data) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'A private key is already in use. If you generate a new key pair, it would be override',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return Text('No private key found');
                  }
                },
                future: _privateKeyExists(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () async {
                    _generateKey();
                  },
                  child: Text('Generate keys pair')),
            ),
            Divider(height: 50,),
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
