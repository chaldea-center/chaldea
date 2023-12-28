abstract class PaddingBase {
  int blockSize;

  PaddingBase(this.blockSize);

  List<int> encode(List<int> source);
  List<int> decode(List<int> source);
}

class ZeroPadding extends PaddingBase {
  ZeroPadding(super.blockSize);

  @override
  List<int> encode(List<int> source) {
    int padSize = blockSize - ((source.length + blockSize - 1) % blockSize + 1);
    return [...source, ...List.filled(padSize, 0)];
  }

  @override
  List<int> decode(List<int> source) {
    assert(source.length % blockSize == 0);
    int offset = source.length;
    if (offset == 0) {
      return [];
    }
    int end = offset - blockSize + 1;

    while (offset > end) {
      offset -= 1;
      if (source[offset] != 0) {
        return source.sublist(0, offset + 1);
      }
    }

    return source.sublist(0, end);
  }
}

class Pkcs7Padding extends PaddingBase {
  Pkcs7Padding(super.blockSize);

  @override
  List<int> encode(List<int> source) {
    int amountToPad = blockSize - (source.length % blockSize);
    if (amountToPad == 0) {
      amountToPad = blockSize;
    }
    List<int> pad = List.filled(amountToPad, amountToPad);
    return [...source, ...pad];
  }

  @override
  List<int> decode(List<int> source) {
    return source.sublist(0, source.length - source.last);
  }
}
