import 'dart:math';

part 'mock_data.dart';

const TEST_TIMES = 50;

var _random = Random();
int getRandomInt(int min, [int max]) {
  int num = min;
  if (max != null && max > min) {
    num += _random.nextInt(max - min);
  }
  return num;
}
