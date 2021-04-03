part of ffo;

const int _LAND_0 = 0;
const int _BODY_BACK_1 = 1;
const int _HEAD_BACK_2 = 2;
const int _BODY_BACK2_3 = 3;
const int _BODY_MIDDLE_4 = 4;
const int _HEAD_FRONT_5 = 5;
const int _BODY_FRONT_6 = 6;
const int _LAND_FRONT_7 = 7;

String padSvtId(int id) {
  return id.toString().padLeft(3, '0');
}

//id,servant_id,direction,scale,head_x,head_y,body_x,body_y,head_x2,head_y2
class FFOPart {
  int id;
  int svtId;
  int direction;
  double scale;
  int headX;
  int headY;
  int bodyX;
  int bodyY;
  int headX2;
  int headY2;

  static int _toInt(dynamic v) {
    if (v is String) return int.parse(v);
    if (v is num) return v.toInt();
    throw FormatException('${v.runtimeType} v=$v is not a int value');
  }

  static double _toDouble(dynamic v) {
    if (v is String) return double.parse(v);
    if (v is num) return v.toDouble();
    throw FormatException('${v.runtimeType} v=$v is not a double value');
  }

  FFOPart.fromList(List row)
      : id = _toInt(row[0]),
        svtId = _toInt(row[1]),
        direction = _toInt(row[2]),
        scale = _toDouble(row[3]),
        headX = _toInt(row[4]),
        headY = _toInt(row[5]),
        bodyX = _toInt(row[6]),
        bodyY = _toInt(row[7]),
        headX2 = _toInt(row[8]),
        headY2 = _toInt(row[9]);
}
