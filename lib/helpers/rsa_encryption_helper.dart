import 'dart:typed_data';

import 'package:cyber_secu_project/helpers/rsa_parser_helper.dart';
import "package:pointycastle/export.dart";

class RSAEncryptionHelper {
  static Uint8List rsaEncrypt(String pemPublicKey, Uint8List plainText) {
    final rsaPublicKey = RSAParserHelper.parsePublicKeyFromPem(pemPublicKey);
    final encryptor = RSAEngine()
      ..init(true, PublicKeyParameter<RSAPublicKey>(rsaPublicKey));
    return _processInBlocks(encryptor, plainText);
  }

  static Uint8List rsaDecrypt(String pemPrivateKey, Uint8List cipherText) {
    final rsaPrivateKey = RSAParserHelper.parsePrivateKeyFromPem(pemPrivateKey);
    final decrypter = RSAEngine()
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(rsaPrivateKey));
    return _processInBlocks(decrypter, cipherText);
  }

  static Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
    final numBlocks = input.length ~/ engine.inputBlockSize +
        ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

    final output = Uint8List(numBlocks * engine.outputBlockSize);

    var inputOffset = 0;
    var outputOffset = 0;
    while (inputOffset < input.length) {
      final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
          ? engine.inputBlockSize
          : input.length - inputOffset;

      outputOffset += engine.processBlock(
          input, inputOffset, chunkSize, output, outputOffset);

      inputOffset += chunkSize;
    }

    return (output.length == outputOffset)
        ? output
        : output.sublist(0, outputOffset);
  }
}