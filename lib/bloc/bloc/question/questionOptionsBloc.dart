import 'package:egitimaxapplication/bloc/event/question/questionOptionsEvent.dart';
import 'package:egitimaxapplication/bloc/state/question/questionOptionsState.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/question/questionRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuestionOptionsBloc
    extends Bloc<QuestionOptionsEvent, QuestionOptionsState> {
  QuestionOptionsBloc() : super(InitialInitState()) {
    AppRepositories appRepositories = AppRepositories();

    on<QuestionOptionsInitEvent>((event, emit) async {
      late List<String> result;
      QuestionRepository questionRepository =
      await appRepositories.questionRepository();
      emit(InitialInitState());
      await Future.delayed(const Duration(seconds: 1));
      emit(LoadingInitState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        emit(LoadedInitState());
      } catch (e) {
        emit(ErrorInitState(errorMessage: e.toString()));
      }
    });
  }
}
