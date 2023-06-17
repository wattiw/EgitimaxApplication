import 'package:egitimaxapplication/bloc/event/mainLayout/mainLayoutEvent.dart';
import 'package:egitimaxapplication/bloc/state/mainLayout/mainLayoutState.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/mainLayout/mainLayoutRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainLayoutBloc
    extends Bloc<MainLayoutEvent, MainLayoutState> {
  MainLayoutBloc() : super(InitialState()) {
    AppRepositories appRepositories = AppRepositories();

    on<RenderLayoutEvent>((event, emit) async {
      MainLayoutRepository mainLayoutRepository =
      await appRepositories.mainLayoutRepository();
       //emit(InitialState());
       //await Future.delayed(const Duration(seconds: 1));
       //emit(LoadingState());
        //await Future.delayed(const Duration(seconds: 1));
      try {
         //final result = await mainLayoutRepository.getData();
         emit(LoadedState(dataList: []));
      } catch (e) {
        emit(ErrorState(errorMessage: e.toString()));
      }
    });
  }
}
