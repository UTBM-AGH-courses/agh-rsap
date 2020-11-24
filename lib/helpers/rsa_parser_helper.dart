import 'dart:convert';

import "package:asn1lib/asn1lib.dart";
import "package:pointycastle/export.dart";

class RSAParserHelper {

  static RSAPrivateKey parsePrivateKeyFromPem(String pemString) {
    List<int> privateKeyDER = _decodePEM(pemString);
    var asn1Parser = new ASN1Parser(privateKeyDER);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    var privateKey = topLevelSeq.elements[2];

    asn1Parser = new ASN1Parser(privateKey.contentBytes());
    var pkSeq = asn1Parser.nextObject() as ASN1Sequence;
    var modulus = pkSeq.elements[1] as ASN1Integer;
    var privateExponent = pkSeq.elements[3] as ASN1Integer;
    var p = pkSeq.elements[4] as ASN1Integer;
    var q = pkSeq.elements[5] as ASN1Integer;

    RSAPrivateKey rsaPrivateKey = RSAPrivateKey(
        modulus.valueAsBigInteger,
        privateExponent.valueAsBigInteger,
        p.valueAsBigInteger,
        q.valueAsBigInteger);

    return rsaPrivateKey;
  }

  static RSAPublicKey parsePublicKeyFromPem(String pemString) {
    List<int> publicKeyDER = _decodePEM(pemString);
    var asn1Parser = new ASN1Parser(publicKeyDER);
    var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    var publicKeyBitString = topLevelSeq.elements[1];

    var publicKeyAsn = new ASN1Parser(publicKeyBitString.contentBytes());
    ASN1Sequence publicKeySeq = publicKeyAsn.nextObject();
    var modulus = publicKeySeq.elements[0] as ASN1Integer;
    var exponent = publicKeySeq.elements[1] as ASN1Integer;

    RSAPublicKey rsaPublicKey =
    RSAPublicKey(modulus.valueAsBigInteger, exponent.valueAsBigInteger);

    return rsaPublicKey;
  }

  static List<int> _decodePEM(String pem) {
    var startsWith = [
      "-----BEGIN PUBLIC KEY-----",
      "-----BEGIN PRIVATE KEY-----",
      "-----BEGIN PGP PUBLIC KEY BLOCK-----\r\nVersion: React-Native-OpenPGP.js 0.1\r\nComment: http://openpgpjs.org\r\n\r\n",
      "-----BEGIN PGP PRIVATE KEY BLOCK-----\r\nVersion: React-Native-OpenPGP.js 0.1\r\nComment: http://openpgpjs.org\r\n\r\n",
    ];
    var endsWith = [
      "-----END PUBLIC KEY-----",
      "-----END PRIVATE KEY-----",
      "-----END PGP PUBLIC KEY BLOCK-----",
      "-----END PGP PRIVATE KEY BLOCK-----",
    ];
    bool isOpenPgp = pem.indexOf('BEGIN PGP') != -1;

    for (var s in startsWith) {
      if (pem.startsWith(s)) {
        pem = pem.substring(s.length);
      }
    }

    for (var s in endsWith) {
      if (pem.endsWith(s)) {
        pem = pem.substring(0, pem.length - s.length);
      }
    }

    if (isOpenPgp) {
      var index = pem.indexOf('\r\n');
      pem = pem.substring(0, index);
    }

    pem = pem.replaceAll('\n', '');
    pem = pem.replaceAll('\r', '');

    return base64.decode(pem);
  }
}