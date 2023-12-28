// ignore_for_file: non_constant_identifier_names

import 'constants.dart' show C;
import 'padding.dart';

export 'padding.dart';

class Rijndael {
  late List<List<int>> Ke;
  late List<List<int>> Kd;
  late List<int> key;
  late int blockSize;

  Rijndael({required this.key, this.blockSize = 16}) {
    if (![16, 24, 32].contains(blockSize)) {
      throw ArgumentError('Invalid block size: $blockSize');
    }

    if (![16, 24, 32].contains(key.length)) {
      throw ArgumentError('Invalid key size: ${key.length}');
    }

    int rounds = C.num_rounds[key.length]![blockSize]!;
    int b_c = blockSize ~/ 4;
    List<List<int>> k_e = List.generate(rounds + 1, (index) => List.filled(b_c, 0));
    List<List<int>> k_d = List.generate(rounds + 1, (index) => List.filled(b_c, 0));
    int round_key_count = (rounds + 1) * b_c;
    int k_c = key.length ~/ 4;

    List<int> tk = [];
    for (int i = 0; i < k_c; i++) {
      tk.add((key[i * 4] << 24) ^ (key[i * 4 + 1] << 16) ^ (key[i * 4 + 2] << 8) ^ key[i * 4 + 3]);
    }

    int t = 0;
    int j = 0;
    while (j < k_c && t < round_key_count) {
      k_e[t ~/ b_c][t % b_c] = tk[j];
      k_d[rounds - (t ~/ b_c)][t % b_c] = tk[j];
      j++;
      t++;
    }
    int r_con_pointer = 0;
    while (t < round_key_count) {
      int tt = tk[k_c - 1];
      tk[0] ^= (C.S[(tt >> 16) & 0xFF] & 0xFF) << 24 ^
          (C.S[(tt >> 8) & 0xFF] & 0xFF) << 16 ^
          (C.S[tt & 0xFF] & 0xFF) << 8 ^
          (C.S[(tt >> 24) & 0xFF] & 0xFF) ^
          (C.r_con[r_con_pointer] & 0xFF) << 24;
      r_con_pointer++;
      if (k_c != 8) {
        for (int i = 1; i < k_c; i++) {
          tk[i] ^= tk[i - 1];
        }
      } else {
        for (int i = 1; i < k_c ~/ 2; i++) {
          tk[i] ^= tk[i - 1];
        }
        tt = tk[k_c ~/ 2 - 1];
        tk[k_c ~/ 2] ^= (C.S[tt & 0xFF] & 0xFF) ^
            (C.S[(tt >> 8) & 0xFF] & 0xFF) << 8 ^
            (C.S[(tt >> 16) & 0xFF] & 0xFF) << 16 ^
            (C.S[(tt >> 24) & 0xFF] & 0xFF) << 24;
        for (int i = k_c ~/ 2 + 1; i < k_c; i++) {
          tk[i] ^= tk[i - 1];
        }
      }
      j = 0;
      while (j < k_c && t < round_key_count) {
        k_e[t ~/ b_c][t % b_c] = tk[j];
        k_d[rounds - (t ~/ b_c)][t % b_c] = tk[j];
        j++;
        t++;
      }
    }
    for (int r = 1; r < rounds; r++) {
      for (int j = 0; j < b_c; j++) {
        int tt = k_d[r][j];
        k_d[r][j] = C.U1[(tt >> 24) & 0xFF] ^ C.U2[(tt >> 16) & 0xFF] ^ C.U3[(tt >> 8) & 0xFF] ^ C.U4[tt & 0xFF];
      }
    }
    Ke = k_e;
    Kd = k_d;
  }

  List<int> encrypt(List<int> source) {
    if (source.length != blockSize) {
      throw ArgumentError('Wrong block length, expected $blockSize got ${source.length}');
    }

    List<List<int>> k_e = Ke;

    int b_c = blockSize ~/ 4;
    int rounds = k_e.length - 1;
    int s_c = (b_c == 4) ? 0 : ((b_c == 6) ? 1 : 2);
    int s1 = C.shifts[s_c][1][0];
    int s2 = C.shifts[s_c][2][0];
    int s3 = C.shifts[s_c][3][0];
    List<int> a = List.filled(b_c, 0);
    List<int> t = [];
    for (int i = 0; i < b_c; i++) {
      t.add((source[i * 4] << 24 | source[i * 4 + 1] << 16 | source[i * 4 + 2] << 8 | source[i * 4 + 3]) ^ k_e[0][i]);
    }
    for (int r = 1; r < rounds; r++) {
      for (int i = 0; i < b_c; i++) {
        a[i] = (C.T1[(t[i] >> 24) & 0xFF] ^
                C.T2[(t[(i + s1) % b_c] >> 16) & 0xFF] ^
                C.T3[(t[(i + s2) % b_c] >> 8) & 0xFF] ^
                C.T4[t[(i + s3) % b_c] & 0xFF]) ^
            k_e[r][i];
      }
      t = List.from(a);
    }
    List<int> result = [];
    for (int i = 0; i < b_c; i++) {
      int tt = k_e[rounds][i];
      result.add((C.S[(t[i] >> 24) & 0xFF] ^ (tt >> 24)) & 0xFF);
      result.add((C.S[(t[(i + s1) % b_c] >> 16) & 0xFF] ^ (tt >> 16)) & 0xFF);
      result.add((C.S[(t[(i + s2) % b_c] >> 8) & 0xFF] ^ (tt >> 8)) & 0xFF);
      result.add((C.S[t[(i + s3) % b_c] & 0xFF] ^ tt) & 0xFF);
    }
    return result;
  }

  List<int> decrypt(List<int> cipher) {
    if (cipher.length != blockSize) {
      throw ArgumentError('wrong block length, expected $blockSize got ${cipher.length}');
    }

    List<List<int>> k_d = Kd;
    int b_c = blockSize ~/ 4;
    int rounds = k_d.length - 1;
    int s_c = (b_c == 4) ? 0 : ((b_c == 6) ? 1 : 2);
    int s1 = C.shifts[s_c][1][1];
    int s2 = C.shifts[s_c][2][1];
    int s3 = C.shifts[s_c][3][1];
    List<int> a = List.filled(b_c, 0);
    List<int> t = List.filled(b_c, 0);
    for (int i = 0; i < b_c; i++) {
      t[i] = (cipher[i * 4] << 24 | cipher[i * 4 + 1] << 16 | cipher[i * 4 + 2] << 8 | cipher[i * 4 + 3]) ^ k_d[0][i];
    }
    for (int r = 1; r < rounds; r++) {
      for (int i = 0; i < b_c; i++) {
        a[i] = (C.T5[(t[i] >> 24) & 0xFF] ^
                C.T6[(t[(i + s1) % b_c] >> 16) & 0xFF] ^
                C.T7[(t[(i + s2) % b_c] >> 8) & 0xFF] ^
                C.T8[t[(i + s3) % b_c] & 0xFF]) ^
            k_d[r][i];
      }
      t = List.from(a);
    }
    List<int> result = [];
    for (int i = 0; i < b_c; i++) {
      int tt = k_d[rounds][i];
      result.add((C.Si[(t[i] >> 24) & 0xFF] ^ (tt >> 24)) & 0xFF);
      result.add((C.Si[(t[(i + s1) % b_c] >> 16) & 0xFF] ^ (tt >> 16)) & 0xFF);
      result.add((C.Si[(t[(i + s2) % b_c] >> 8) & 0xFF] ^ (tt >> 8)) & 0xFF);
      result.add((C.Si[t[(i + s3) % b_c] & 0xFF] ^ tt) & 0xFF);
    }
    return result;
  }
}

class RijndaelCbc extends Rijndael {
  late List<int> iv;
  late PaddingBase padding;

  RijndaelCbc({
    required super.key,
    required this.iv,
    required this.padding,
    super.blockSize = 16,
  });

  @override
  List<int> encrypt(List<int> source) {
    List<int> ppt = padding.encode(source);
    int offset = 0;

    List<int> ct = [];
    List<int> v = iv;
    while (offset < ppt.length) {
      List<int> block = ppt.sublist(offset, offset + blockSize);
      block = xorBlock(block, v);
      block = super.encrypt(block);
      ct.addAll(block);
      offset += blockSize;
      v = block;
    }
    return ct;
  }

  @override
  List<int> decrypt(List<int> cipher) {
    assert(cipher.length % blockSize == 0);
    List<int> ppt = [];
    int offset = 0;
    List<int> v = iv;
    while (offset < cipher.length) {
      List<int> block = cipher.sublist(offset, offset + blockSize);
      List<int> decrypted = super.decrypt(block);
      ppt.addAll(xorBlock(decrypted, v));
      offset += blockSize;
      v = block;
    }
    List<int> pt = padding.decode(ppt);
    return pt;
  }

  List<int> xorBlock(List<int> b1, List<int> b2) {
    List<int> result = List.filled(blockSize, 0);
    for (int i = 0; i < blockSize; i++) {
      result[i] = b1[i] ^ b2[i];
    }
    return result;
  }
}
