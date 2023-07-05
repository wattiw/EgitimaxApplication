import 'package:egitimaxapplication/bloc/event/questions/questionsEvent.dart';
import 'package:egitimaxapplication/bloc/state/questions/questionsState.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/questions/questionsRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class QuestionsBloc extends Bloc<QuestionsEvent, QuestionsState> {
  QuestionsBloc() : super(InitState()) {
    AppRepositories appRepositories = AppRepositories();
    QuestionsRepository questionsRepository;

    on<InitEvent>((event, emit) async {
      questionsRepository = await appRepositories.questionsRepository();
      emit(LoadingState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        emit(LoadedState(questionsPageModel: event.questionsPageModel));
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        emit(ErrorState(errorMessage: e.toString()));
      }
    });
  }
}
