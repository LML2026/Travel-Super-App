/// A discriminated union for operation results.
/// Repositories return `Result<T>` instead of throwing exceptions.
///
/// Usage:
/// ```dart
/// final result = await repository.searchFlights(request);
/// switch (result) {
///   case Success(:final data): // use data
///   case Failure(:final message): // show error
/// }
/// ```
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, {this.error});
}
