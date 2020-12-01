import 'dart:typed_data';

import 'package:RSAp/helpers/rsa_parser_helper.dart';
import "package:pointycastle/export.dart";

class RSASignHelper {
  static Uint8List rsaSign(String pemPrivateKey, Uint8List dataToSign) {
    final rsaPrivateKey = RSAParserHelper.parsePrivateKeyFromPem(pemPrivateKey);
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(
        true, PrivateKeyParameter<RSAPrivateKey>(rsaPrivateKey));
    final sig = signer.generateSignature(dataToSign);
    return sig.bytes;
  }

  static bool rsaVerify(
      String pemPublicKey, Uint8List signedData, Uint8List signature) {
    final rsaPublicKey = RSAParserHelper.parsePublicKeyFromPem(pemPublicKey);
    final sig = RSASignature(signature);
    final verifier = RSASigner(SHA256Digest(), '0609608648016503040201');
    verifier.init(
        false, PublicKeyParameter<RSAPublicKey>(rsaPublicKey));
    try {
      return verifier.verifySignature(signedData, sig);
    } on ArgumentError {
      return false;
    }
  }
}
