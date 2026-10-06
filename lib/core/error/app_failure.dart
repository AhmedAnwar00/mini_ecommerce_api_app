enum AppFailureKind { network, unauthorized, notFound, validation, unknown }

class AppFailure implements Exception {
  const AppFailure(this.kind, this.message);

  final AppFailureKind kind;
  final String message;
}
