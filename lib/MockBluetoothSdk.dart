import 'dart:math';

class MockBluetoothSDK {

  Stream<bool> getConnectionStatusStream() {
    return Stream.periodic(Duration(seconds: 20), (count) {
      return count % 5 == 0; //
    });
  }

  Stream<int> getHeartRateStream() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      yield (60 + (10 * (1 - Random().nextDouble())).toInt());
    }
  }
  Stream<int> getStepCountStream() async* {
    int steps = 0;
    while (true) {
      await Future.delayed(Duration(seconds: 5));
    steps += Random().nextInt(10);
    yield steps;
    }
  }
}