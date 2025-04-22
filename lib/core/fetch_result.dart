sealed class FetchResult {}

class FetchSuccess<T> extends FetchResult {
  final T data;
  FetchSuccess(this.data);
}

class FetchFailure extends FetchResult {
  final String message;
  FetchFailure(this.message);
}