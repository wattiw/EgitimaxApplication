abstract class MainLayoutState {}

class InitialState extends MainLayoutState {}

class LoadingState extends MainLayoutState {}

class LoadedState extends MainLayoutState {
  final List<String> dataList;

  LoadedState({required this.dataList});
}

class ErrorState extends MainLayoutState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}
