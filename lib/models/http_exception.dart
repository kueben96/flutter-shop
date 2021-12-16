class HttpException implements Exception {
  // implement: forced to implement all functions the class has
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    // TODO: implement toString
    return message;
  }
}
