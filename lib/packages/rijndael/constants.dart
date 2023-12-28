// ignore_for_file: non_constant_identifier_names

class _C {
  int mul(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return a_log[(log[a & 0xFF] + log[b & 0xFF]) % 255];
  }

  int mul4(int a, List<int> bs) {
    if (a == 0) return 0;
    int rr = 0;
    for (final b in bs) {
      rr <<= 8;
      if (b != 0) {
        rr = rr | mul(a, b);
      }
    }
    return rr;
  }

  final List<List<List<int>>> shifts = const [
    [
      [0, 0],
      [1, 3],
      [2, 2],
      [3, 1]
    ],
    [
      [0, 0],
      [1, 5],
      [2, 4],
      [3, 3]
    ],
    [
      [0, 0],
      [1, 7],
      [3, 5],
      [4, 4]
    ]
  ];
  final num_rounds = {
    16: {16: 10, 24: 12, 32: 14},
    24: {16: 12, 24: 12, 32: 14},
    32: {16: 14, 24: 14, 32: 14}
  };
  final List<List<int>> A = [
    [1, 1, 1, 1, 1, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 0],
    [0, 0, 0, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 1, 1, 1, 1],
    [1, 1, 0, 0, 0, 1, 1, 1],
    [1, 1, 1, 0, 0, 0, 1, 1],
    [1, 1, 1, 1, 0, 0, 0, 1]
  ];
  final List<int> a_log = [1];
  final List<int> log = List.filled(256, 0);
  final List<List<int>> box = List.generate(256, (index) => List.filled(8, 0));
  final List<int> B = [0, 1, 1, 0, 0, 0, 1, 1];
  final List<List<int>> cox = List.generate(256, (index) => List.filled(8, 0));
  final List<int> S = List.filled(256, 0);
  final List<int> Si = List.filled(256, 0);
  final List<List<int>> G = [
    [2, 1, 1, 3],
    [3, 2, 1, 1],
    [1, 3, 2, 1],
    [1, 1, 3, 2]
  ];
  final List<List<int>> AA = List.generate(4, (index) => List.filled(8, 0));
  final List<List<int>> iG = List.generate(4, (index) => List.filled(4, 0));
  final List<int> T1 = [];
  final List<int> T2 = [];
  final List<int> T3 = [];
  final List<int> T4 = [];
  final List<int> T5 = [];
  final List<int> T6 = [];
  final List<int> T7 = [];
  final List<int> T8 = [];
  final List<int> U1 = [];
  final List<int> U2 = [];
  final List<int> U3 = [];
  final List<int> U4 = [];

  final r_con = [1];
  int r = 1;

  _C._() {
    // a_log
    for (int _ = 0; _ < 255; _++) {
      int j = (a_log.last << 1) ^ a_log.last;
      if (j & 0x100 != 0) {
        j ^= 0x11B;
      }
      a_log.add(j);
    }
    // log
    for (int i = 1; i < 255; i++) {
      log[a_log[i]] = i;
    }
    // box
    box[1][7] = 1;
    for (int i = 2; i < 256; i++) {
      int j = a_log[255 - log[i]];
      for (int t = 0; t < 8; t++) {
        box[i][t] = (j >> (7 - t)) & 0x01;
      }
    }
    // cox
    for (int i = 0; i < 256; i++) {
      for (int t = 0; t < 8; t++) {
        cox[i][t] = B[t];
        for (int j = 0; j < 8; j++) {
          cox[i][t] ^= A[t][j] * box[i][j];
        }
      }
    }
    // S
    for (int i = 0; i < 256; i++) {
      S[i] = cox[i][0] << 7;
      for (int t = 1; t < 8; t++) {
        S[i] ^= cox[i][t] << (7 - t);
      }
      Si[S[i] & 0xFF] = i;
    }
    // T-box
    // AA
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        AA[i][j] = G[i][j];
        AA[i][i + 4] = 1;
      }
    }
    for (int i = 0; i < 4; i++) {
      final pivot = AA[i][i];
      for (int j = 0; j < 8; j++) {
        if (AA[i][j] != 0) {
          AA[i][j] = a_log[(255 + log[AA[i][j] & 0xFF] - log[pivot & 0xFF]) % 255];
        }
      }
      for (int t = 0; t < 4; t++) {
        if (i != t) {
          for (int j = i + 1; j < 8; j++) {
            AA[t][j] ^= mul(AA[i][j], AA[t][i]);
          }
          AA[t][i] = 0;
        }
      }
    }
    // iG
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        iG[i][j] = AA[i][j + 4];
      }
    }
    // T U
    for (int t = 0; t < 256; t++) {
      int s = S[t];
      T1.add(mul4(s, G[0]));
      T2.add(mul4(s, G[1]));
      T3.add(mul4(s, G[2]));
      T4.add(mul4(s, G[3]));

      s = Si[t];
      T5.add(mul4(s, iG[0]));
      T6.add(mul4(s, iG[1]));
      T7.add(mul4(s, iG[2]));
      T8.add(mul4(s, iG[3]));

      U1.add(mul4(t, iG[0]));
      U2.add(mul4(t, iG[1]));
      U3.add(mul4(t, iG[2]));
      U4.add(mul4(t, iG[3]));
    }

    // round constants
    for (int i = 1; i < 30; i++) {
      r = mul(2, r);
      r_con.add(r);
    }
  }
}

final C = _C._();
