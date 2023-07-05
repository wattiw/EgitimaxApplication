import 'package:egitimaxapplication/bloc/bloc/questions/questionsBloc.dart';
import 'package:egitimaxapplication/bloc/state/questions/questionsState.dart';
import 'package:egitimaxapplication/model/questions/questionsPageModel.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/widget/appBar/innerAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/event/questions/questionsEvent.dart';

class QuestionsPage extends StatefulWidget {
  final BigInt userId;

  QuestionsPage({required this.userId});

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  late QuestionsBloc questionsBloc;
  late QuestionsPageModel questionsPageModel;

  @override
  void initState() {
    questionsPageModel = QuestionsPageModel(userId: widget.userId);
    questionsBloc = QuestionsBloc();
    questionsBloc.add(InitEvent(questionsPageModel: questionsPageModel));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => questionsBloc,
      child: Scaffold(
        appBar: const InnerAppBar(
          title:'My questions',
          subTitle: 'My questions are listed here',
        ),
        body: BlocBuilder<QuestionsBloc, QuestionsState>(
          builder: (context, state) {
            if (state is InitState) {
              return _buildInit(context, state);
            } else if (state is LoadingState) {
              return _buildLoading(context, state);
            } else if (state is LoadedState) {
              return _buildLoaded(context, state);
            } else if (state is ErrorState) {
              return _buildError(context, state);
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget _buildInit(BuildContext context, InitState state) {
    return Container();
  }

  Widget _buildLoading(BuildContext context, LoadingState state) {
    return Container();
  }

  Widget _buildLoaded(BuildContext context, LoadedState state) {
    return Container();
  }

  Widget _buildError(BuildContext context, ErrorState state) {
    return Container();
  }
}
