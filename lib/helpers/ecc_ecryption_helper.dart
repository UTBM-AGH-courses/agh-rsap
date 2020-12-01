import 'dart:core';
import 'dart:math';

class ECCEncryptionHelper {
  final prime = BigInt.parse(
      "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F",
      radix: 16);
  final BigInt aCurve = BigInt.from(0);
  final BigInt bCurve = BigInt.from(7);
  final BigInt gX = BigInt.parse(
      "79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798",
      radix: 16);
  final BigInt gY = BigInt.parse(
      "483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8",
      radix: 16);
  final N = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141";
  final privateKey =
      "51897b64e85c3f714bba707e867914295a1377a7463a9dae8ea6a8b914246319";

  List<BigInt> eccAdd(vectorP, vectorQ) {
    var lambda = ((vectorQ[1] - vectorP[1]) / (vectorQ[0] - vectorP[0])) %
        prime.toDouble();
    var xR = (BigInt.from(lambda.isNaN ? 0 : lambda) *
                BigInt.from(lambda.isNaN ? 0 : lambda) -
            vectorP[0] -
            vectorQ[0]) %
        prime;
    var yR = (BigInt.from(lambda.isNaN ? 0 : lambda) * (vectorP[0] - xR) -
            vectorP[1]) %
        prime;
    return [xR, yR];
  }

  List<BigInt> eccDouble(vectorP) {
    var lambda = ((BigInt.from(3) * vectorP[0] * vectorP[0] + aCurve) /
            ((BigInt.from(2) * vectorP[1]))) %
        prime.toDouble();
    var x = (BigInt.from(lambda.isNaN ? 0 : lambda) *
                BigInt.from(lambda.isNaN ? 0 : lambda) -
            BigInt.from(2) * vectorP[0]) %
        prime;
    var y = (BigInt.from(lambda.isNaN ? 0 : lambda) * (vectorP[0] - x) -
            vectorP[1]) %
        prime;
    return [x, y];
  }

  String hexToBinary(String hex) {
    var intParse = int.tryParse(hex);
    if (intParse == null) {
      switch (hex.toUpperCase()) {
        case 'A':
          intParse = 10;
          break;
        case 'B':
          intParse = 11;
          break;
        case 'C':
          intParse = 12;
          break;
        case 'D':
          intParse = 13;
          break;
        case 'E':
          intParse = 14;
          break;
        case 'F':
          intParse = 15;
          break;
      }
    }
    return intParse.toRadixString(2);
  }

  List eccMultiply(List genPoints, String scalarHex) {
    if (scalarHex == "0" ||
        BigInt.parse(scalarHex, radix: 16) >= BigInt.parse(N, radix: 16)) {
      throw Exception("Invalid Scalar/Private Key");
    }

    var Q = genPoints;
    for (var i = scalarHex.length - 1; i >= 0; i--) {
      var binary = hexToBinary(scalarHex[i]);
      for (var j = binary.length - 1; j >= 0; j--) {
        if (binary[j] == "1") {
          Q = eccAdd(Q, genPoints);
        }
        Q = eccDouble(Q);
      }
    }
    return Q;
  }

  double eccFunction(int x) {
    return sqrt(pow(x, 3) + 7);
  }

  void test() {
    List<BigInt> keyCoords = eccMultiply([gX, gY], privateKey);
    var pubKeyX = keyCoords[0];
    var pubKeyY = keyCoords[1];
    print("Public key : ${keyCoords[0]} ${keyCoords[1]}");
    print("Private key : ${BigInt.parse(privateKey, radix: 16)}");
    var mPlain = 54;
    var MPlain = eccFunction(mPlain);
    var b = "F";
    List<BigInt> keyCoordsEncrypt = eccMultiply([gX, gY], b);
    var B1 = keyCoordsEncrypt[0];
    var B2 = BigInt.from(MPlain) + BigInt.parse(b, radix: 16) * keyCoords[0];
    var M = B2 - BigInt.parse(privateKey, radix: 16) * B1;
    var bG = eccMultiply([gX, gY], b);
    var bA = eccMultiply([pubKeyX, pubKeyY], b);
  }
}
