class Timer {
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(
        const Duration(seconds: 1), (timer) => ticks + timer + 1);
  }
}
