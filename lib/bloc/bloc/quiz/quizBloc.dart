import 'dart:ui';
import 'package:egitimaxapplication/bloc/event/quiz/quizEvent.dart';
import 'package:egitimaxapplication/bloc/state/quiz/quizState.dart';
import 'package:egitimaxapplication/model/quiz/quizMain.dart';
import 'package:egitimaxapplication/model/quiz/quizSection.dart';
import 'package:egitimaxapplication/model/quiz/quizSectionQuestionMap.dart';
import 'package:egitimaxapplication/model/quiz/setQuizObjects.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/quiz/quizRepository.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(InitState()) {
    AppRepositories appRepositories = AppRepositories();
    QuizRepository quizRepository;

    on<InitEvent>((event, emit) async {
      quizRepository = await appRepositories.quizRepository();
      emit(LoadingState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        event.quizPageModel.quizMain = QuizMain();

        Locale currentLocale = WidgetsBinding.instance.window.locale;
        String languageCode = currentLocale.languageCode; // 'tr'
        String countryCode = currentLocale.languageCode; // 'TR'

        var tblQuizMainDataSet = await appRepositories.tblQuizMain(
            'Quiz/GetObject',
            [
              'id',
              'country',
              'academic_year',
              'user_id',
              'grade_id',
              'title',
              'description',
              'duration',
              'header_text',
              'footer_text',
              'is_public',
              'is_active',
              'agg_rating',
              'created_by',
              'created_on',
              'updated_by',
              'updated_on'
            ],
            id: event.quizPageModel.quizId);
        var tblQuizSectionDataSet = await appRepositories.tblQuizSection(
            'Quiz/GetObject',
            [
              'id',
              'quiz_id',
              'branch_id',
              'order_no',
              'section_desc',
              'is_active'
            ],
            quiz_id: event.quizPageModel.quizId);
        var tblUserMainDataSet = await appRepositories.tblUserMain(
            'Quiz/GetObject', ['id', 'country_id'],
            id: event.quizPageModel.userId);
        var tblLocL1Country = await appRepositories.tblLocL1Country(
          'Quiz/GetObject',
          ['id', 'countrycode', 'lang'],
        );

        int? countryId =
            tblQuizMainDataSet.firstValue('data', 'country', insteadOfNull: 0);

        if (countryId == 0 || countryId == null) {
          countryId = tblUserMainDataSet.firstValue('data', 'country_id',
              insteadOfNull: 0);
          if (countryId == 0 || countryId == null) {
            countryId = tblLocL1Country.firstValue('data', 'id',
                filterColumn: 'countrycode',
                filterValue: countryCode.toUpperCase(),
                insteadOfNull: 0);
            if (countryId == 0 || countryId == null) {
              countryId = tblLocL1Country.firstValue('data', 'id');
            }
          }
        }
        if (countryId != null && countryId != 0) {
          var countries = tblLocL1Country.toKeyValuePairsWithTypes<int, int>(
              'data', 'id',
              valueColumn: 'lang');
          for (var country in countries.entries) {
            int countryId = country.key;
            int countryLangId = country.value;
            var tblLocL1CountryTrans =
                await appRepositories.tblLocL1CountryTrans(
                    'Quiz/GetObject', ['id', 'country_name', 'lang_id'],
                    lang_id: countryLangId);
            var countryName = tblLocL1CountryTrans
                .firstValue('data', 'country_name', insteadOfNull: 'Unknown');
            event.quizPageModel.countries
                .putIfAbsent(countryId, () => countryName);
          }
        }

        event.quizPageModel.quizMain?.country = countryId;

        int? academicYear = tblQuizMainDataSet
            .firstValue('data', 'academic_year', insteadOfNull: 0);

        var tblUtilAcademicYearDataSet = await appRepositories
            .tblUtilAcademicYear('Quiz/GetObject', ['id', 'acad_year']);
        if (academicYear == 0 || academicYear == null) {
          academicYear = tblUtilAcademicYearDataSet.firstValue('data', 'id',
              filterColumn: 'is_default', filterValue: true, insteadOfNull: 0);
        }
        event.quizPageModel.academicYears = tblUtilAcademicYearDataSet
            .toKeyValuePairsWithTypes<int, String>('data', 'id',
                valueColumn: 'acad_year');
        event.quizPageModel.quizMain?.academicYear = academicYear;

        BigInt? userId = tblQuizMainDataSet.firstValue('data', 'user_id',
            insteadOfNull: BigInt.parse('0'));
        event.quizPageModel.quizMain?.userId = userId;

        var tblClassGradeDataSet = await appRepositories.tblClassGrade(
            'Quiz/GetObject', ['id', 'grade_name', 'country_id'],
            country_id: event.quizPageModel.quizMain?.country);
        int? gradeId =
            tblQuizMainDataSet.firstValue('data', 'grade_id', insteadOfNull: 0);
        if (gradeId == 0 || gradeId == null) {
          gradeId = tblClassGradeDataSet.firstValue('data', 'id');
        }
        event.quizPageModel.grades = tblClassGradeDataSet
            .toKeyValuePairsWithTypes<int, String>('data', 'id',
                valueColumn: 'grade_name');
        event.quizPageModel.quizMain?.gradeId = gradeId;

        String? title =
            tblQuizMainDataSet.firstValue('data', 'title', insteadOfNull: '');
        event.quizPageModel.quizMain?.title = title;

        String? description = tblQuizMainDataSet
            .firstValue('data', 'description', insteadOfNull: '');
        event.quizPageModel.quizMain?.description = description;

        int? duration =
            tblQuizMainDataSet.firstValue('data', 'duration', insteadOfNull: 0);
        event.quizPageModel.quizMain?.duration = duration;

        String? headerText = tblQuizMainDataSet
            .firstValue('data', 'header_text', insteadOfNull: '');
        event.quizPageModel.quizMain?.headerText = headerText;

        String? footerText = tblQuizMainDataSet
            .firstValue('data', 'footer_text', insteadOfNull: '');
        event.quizPageModel.quizMain?.footerText = footerText;

        var isPublic = tblQuizMainDataSet.firstValue('data', 'is_public',
            insteadOfNull: 1);
        event.quizPageModel.quizMain?.isPublic = isPublic;

        var isActive = tblQuizMainDataSet.firstValue('data', 'is_active',
            insteadOfNull: 0);
        event.quizPageModel.quizMain?.isActive = isActive;

        var aggRating = tblQuizMainDataSet.firstValue('data', 'agg_rating',
            insteadOfNull: 0.0);
        event.quizPageModel.quizMain?.aggRating = aggRating;

        var createdBy = tblQuizMainDataSet.firstValue('data', 'created_by',
            insteadOfNull: BigInt.parse('0'));
        event.quizPageModel.quizMain?.createdBy = createdBy;

        var createdOn = tblQuizMainDataSet.firstValue('data', 'created_on',
            insteadOfNull: DateTime.now());
        event.quizPageModel.quizMain?.createdOn = createdOn;

        var updatedBy = tblQuizMainDataSet.firstValue('data', 'updated_by',
            insteadOfNull: BigInt.parse('0'));
        event.quizPageModel.quizMain?.updatedBy = updatedBy;

        var updatedOn = tblQuizMainDataSet.firstValue('data', 'updated_on',
            insteadOfNull: DateTime.now());
        event.quizPageModel.quizMain?.updatedOn = updatedOn;

        event.quizPageModel.quizMain!.quizSections = List.empty(growable: true);
        for (var section
            in tblQuizSectionDataSet.selectDataTable('data').toList()) {
          QuizSection qs = QuizSection();

          try {
            qs.id = section['id'];
            qs.quizId = section['quiz_id'];
            qs.branchId = section['branch_id'];
            qs.orderNo = section['order_no'];
            qs.sectionDesc = section['section_desc'];
            qs.isActive = section['is_active'];
            qs.quizSectionQuestionMaps = List.empty(growable: true);

            try {
              var tblQuizSectQuestMapDataSet =
                  await appRepositories.tblQuizSectQuestMap(
                      'Quiz/GetObject',
                      [
                        'id',
                        'section_id',
                        'question_id',
                        'order_no',
                        'is_active'
                      ],
                      section_id: qs.id);
              for (var map in tblQuizSectQuestMapDataSet
                  .selectDataTable('data')
                  .toList()) {
                QuizSectionQuestionMap qsqm = QuizSectionQuestionMap();
                qsqm.id = map['id'];
                qsqm.sectionId = map['section_id'];
                qsqm.questionId = map['question_id'];
                qsqm.orderNo = map['order_no'];
                qsqm.isActive = map['is_active'];

                qs.quizSectionQuestionMaps?.add(qsqm);
              }
            } catch (e) {
              debugPrint(e.toString());
            }
          } catch (e) {
            debugPrint(e.toString());
          }

          event.quizPageModel.quizMain!.quizSections?.add(qs);
        }

        var tblTheaBranMapDataSet = await appRepositories.tblTheaBranMap(
            'Quiz/GetObject', ['id', 'branch_id', 'user_id'],
            user_id: event.quizPageModel.userId);
        var userBranchId = tblTheaBranMapDataSet.firstValue('data', 'branch_id',
            insteadOfNull: 0);

        if (event.quizPageModel.quizMain!.quizSections == null ||
            event.quizPageModel.quizMain!.quizSections!
                .isEmpty) // Default : Main Section Added if not any section
        {
          QuizSection qs = QuizSection();
          qs.id = BigInt.parse('0');
          qs.quizId = event.quizPageModel.quizId;
          qs.branchId = userBranchId;
          qs.orderNo = 1;
          qs.sectionDesc = 'Main Section 1';
          qs.isActive = 0;
          qs.quizSectionQuestionMaps = List.empty(growable: true);

          QuizSection qs1 = QuizSection();
          qs1.id = BigInt.parse('0');
          qs1.quizId = event.quizPageModel.quizId;
          qs1.branchId = 2;
          qs1.orderNo = 2;
          qs1.sectionDesc = 'Section 2';
          qs1.isActive = 0;
          qs.quizSectionQuestionMaps = List.empty(growable: true);

          QuizSection qs2 = QuizSection();
          qs2.id = BigInt.parse('0');
          qs2.quizId = event.quizPageModel.quizId;
          qs2.branchId = 3;
          qs2.orderNo = 3;
          qs2.sectionDesc = 'Section 3';
          qs2.isActive = 0;
          qs.quizSectionQuestionMaps = List.empty(growable: true);

          QuizSection qs3 = QuizSection();
          qs3.id = BigInt.parse('0');
          qs3.quizId = event.quizPageModel.quizId;
          qs3.branchId = 4;
          qs3.orderNo = 4;
          qs3.sectionDesc = 'Section 4';
          qs3.isActive = 0;
          qs.quizSectionQuestionMaps = List.empty(growable: true);

          QuizSection qs4 = QuizSection();
          qs4.id = BigInt.parse('0');
          qs4.quizId = event.quizPageModel.quizId;
          qs4.branchId = 1;
          qs4.orderNo = 5;
          qs4.sectionDesc = 'Section 5';
          qs4.isActive = 0;
          qs.quizSectionQuestionMaps = List.empty(growable: true);

          QuizSection qs5 = QuizSection();
          qs5.id = BigInt.parse('0');
          qs5.quizId = event.quizPageModel.quizId;
          qs5.branchId = userBranchId;
          qs5.orderNo = 6;
          qs5.sectionDesc = 'Section 6';
          qs5.isActive = 0;
          qs.quizSectionQuestionMaps = List.empty(growable: true);

          QuizSection qs6 = QuizSection();
          qs6.id = BigInt.parse('0');
          qs6.quizId = event.quizPageModel.quizId;
          qs6.branchId = 3;
          qs6.orderNo = 7;
          qs6.sectionDesc = 'Section 7';
          qs6.isActive = 0;
          qs.quizSectionQuestionMaps = List.empty(growable: true);

          event.quizPageModel.quizMain!.quizSections?.add(qs);
          event.quizPageModel.quizMain!.quizSections?.add(qs1);
          event.quizPageModel.quizMain!.quizSections?.add(qs2);
          event.quizPageModel.quizMain!.quizSections?.add(qs3);
          event.quizPageModel.quizMain!.quizSections?.add(qs4);
          event.quizPageModel.quizMain!.quizSections?.add(qs5);
          event.quizPageModel.quizMain!.quizSections?.add(qs6);
        }

        var tblLearnBranch = await appRepositories.tblLearnBranch(
            'Quiz/GetObject', ['id', 'branch_name', 'country_id'],
            country_id: event.quizPageModel.quizMain?.country);
        event.quizPageModel.branches =
            tblLearnBranch.toKeyValuePairsWithTypes<int, String>('data', 'id',
                valueColumn: 'branch_name');

        emit(LoadedState(quizPageModel: event.quizPageModel));
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        emit(ErrorState(errorMessage: e.toString()));
      }
    });

    on<Step1Event>((event, emit) async {
      quizRepository = await appRepositories.quizRepository();
      emit(LoadingStep1State());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedStep1State(quizPageModel: event.quizPageModel));
      } catch (e) {
        emit(ErrorStep1State(errorMessage: e.toString()));
      }
    });

    on<Step2Event>((event, emit) async {
      quizRepository = await appRepositories.quizRepository();
      emit(LoadingStep2State());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedStep2State(quizPageModel: event.quizPageModel));
      } catch (e) {
        emit(ErrorStep2State(errorMessage: e.toString()));
      }
    });

    on<Step3Event>((event, emit) async {
      quizRepository = await appRepositories.quizRepository();
      emit(LoadingStep3State());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedStep3State(quizPageModel: event.quizPageModel));
      } catch (e) {
        emit(ErrorStep3State(errorMessage: e.toString()));
      }
    });

    on<LoadPmEvent>((event, emit) async {
      quizRepository = await appRepositories.quizRepository();
      emit(LoadingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedPmState(quizPageModel: event.quizPageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });

    on<DeletePmEvent>((event, emit) async {
      quizRepository = await appRepositories.quizRepository();
      emit(DeletingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(DeletedPmState(quizPageModel: event.quizPageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });

    on<RemovePmEvent>((event, emit) async {
      quizRepository = await appRepositories.quizRepository();
      emit(RemovingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(RemovedPmState(quizPageModel: event.quizPageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });

    on<SavePmEvent>((event, emit) async {
      quizRepository = await appRepositories.quizRepository();
      emit(SavingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        var tblUserSubuserDataSet = await appRepositories.tblUserSubuser(
            'Question/GetObject', ['id', 'main_user_id', 'sub_user_id'],
            sub_user_id: event.quizPageModel.userId);
        var mainUserId = tblUserSubuserDataSet.firstValueWithType<BigInt>(
            'data', 'main_user_id',
            insteadOfNull: BigInt.parse('0'));
        bool isCorporateUser;
        if (mainUserId != BigInt.parse(mainUserId.toString()) &&
            mainUserId != null) {
          isCorporateUser = true;
        } else {
          isCorporateUser = false;
        }

        var tblQuizMainDataSet = await appRepositories.tblQuizMain(
            'Video/GetObject', ['id', 'created_by', 'updated_by', 'created_on'],
            id: event.quizPageModel.quizId);

        BigInt? quizId = tblQuizMainDataSet.firstValueWithType<BigInt>(
            'data', 'id',
            insteadOfNull: 0); //  if Question not exist to insert new one.
        event.quizPageModel.quizId = quizId;

        BigInt? createdBy = tblQuizMainDataSet.firstValueWithType<BigInt>(
            'data', 'created_by',
            insteadOfNull: BigInt.parse('0'));
        BigInt? updatedBy = tblQuizMainDataSet.firstValueWithType<BigInt>(
            'data', 'updated_by',
            insteadOfNull: BigInt.parse('0'));
        DateTime? createdOn = tblQuizMainDataSet.firstValueWithType<DateTime>(
            'data', 'created_on',
            insteadOfNull: DateTime.now());

        List<TblQuizSection> tblQuizSections = List.empty(growable: true);
        if (event.quizPageModel.quizMain != null) {
          if (event.quizPageModel.quizMain!.quizSections != null) {
            for (var section in event.quizPageModel.quizMain!.quizSections!) {
              List<TblQuizSectQuestMap> tblQuizSectQuestMap =
                  List.empty(growable: true);
              if (section != null) {
                for (var map in section.quizSectionQuestionMaps!) {
                  tblQuizSectQuestMap.add(TblQuizSectQuestMap(
                      id: map.id,
                      sectionId: section.id,
                      orderNo: map.orderNo,
                      isActive: 0,
                      questionId: map.questionId));
                }
              }

              tblQuizSections.add(TblQuizSection(
                  id: section.id,
                  sectionDesc: section.sectionDesc ?? '',
                  branchId: section.branchId,
                  isActive: 0,
                  orderNo: section.orderNo,
                  quizId: event.quizPageModel.quizMain!.id,
                  tblQuizSectQuestMaps: tblQuizSectQuestMap));
            }
          }
        }

        SetQuizObjects setQuizObjects = SetQuizObjects(
            isDelete: false,
            isActive: false,
            quizId: event.quizPageModel.quizId,
            isPassive: false,
            quizObjectId: null,
            userId: event.quizPageModel.userId,
            tblQuizMain: TblQuizMain(
              id: event.quizPageModel.quizMain!.id ?? BigInt.parse('0'),
              title: event.quizPageModel.quizMain!.title ?? '',
              description: event.quizPageModel.quizMain!.description ?? '',
              headerText: event.quizPageModel.quizMain!.headerText ?? '',
              footerText: event.quizPageModel.quizMain!.footerText ?? '',
              tblQuizSections: tblQuizSections,
              academicYear: event.quizPageModel.quizMain!.academicYear,
              aggRating:
                  (event.quizPageModel.quizMain!.aggRating ?? 0).toDouble(),
              country: event.quizPageModel.quizMain!.country,
              duration: event.quizPageModel.quizMain!.duration,
              gradeId: event.quizPageModel.quizMain!.gradeId,
              isActive: 0,
              isPublic: event.quizPageModel.quizMain!.isPublic,
              createdBy: createdBy == BigInt.parse('0')
                  ? event.quizPageModel.userId
                  : createdBy,
              createdOn: event.quizPageModel.quizId == 0
                  ? DateTime.now()
                  : createdOn,
              updatedBy: event.quizPageModel.userId,
              updatedOn: DateTime.now(),
                userId: isCorporateUser ? mainUserId :event.quizPageModel.userId,
            ));

                var IsSaved =await quizRepository.setDataSet(setObject: setQuizObjects);
        int bekle = 0;

        emit(SavedPmState(quizPageModel: event.quizPageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });
  }
}
