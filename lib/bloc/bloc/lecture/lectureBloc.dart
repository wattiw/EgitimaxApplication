import 'dart:ui';

import 'package:egitimaxapplication/bloc/event/lecture/lectureEvent.dart';
import 'package:egitimaxapplication/bloc/state/lecture/lectureState.dart';
import 'package:egitimaxapplication/model/lecture/setLectureObjects.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/lecture/lectureRepository.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LectureBloc extends Bloc<LectureEvent, LectureState> {
  LectureBloc() : super(InitState()) {
    AppRepositories appRepositories = AppRepositories();
    LectureRepository lectureRepository;

    on<InitEvent>((event, emit) async {
      lectureRepository = await appRepositories.lectureRepository();
      emit(LoadingState());
      await Future.delayed(const Duration(seconds: 1));
      try {

        //Burada kullanıcın en son giridği seçimleri set etmek için video id en son kullanıcı tarafından girilen video id'e set edilir.
        //sonra tekrar 0'a set edilir çok önemlidir.

        bool setAgainRootIdAsZero=false;
        if(event.lecturePageModel.lectureId==BigInt.parse('0'))
        {
          var lastActionIdDataSet=await lectureRepository.lastActionId(['*'], event.lecturePageModel.userId);
          event.lecturePageModel.lectureId=lastActionIdDataSet.firstValueWithType<BigInt>('data', 'id',insteadOfNull: BigInt.parse('0'));
          setAgainRootIdAsZero=true;
        }

        Locale currentLocale = WidgetsBinding.instance.window.locale;
        String languageCode = currentLocale.languageCode; // 'tr'
        String countryCode = currentLocale.languageCode; // 'TR'

        event.lecturePageModel.setLectureObjects = SetLectureObjects(
            isDelete: false,
            isPassive: false,
            isActive: false,
            lectureId: event.lecturePageModel.lectureId ?? BigInt.parse('0'),
            userId: event.lecturePageModel.userId ?? BigInt.parse('0'),);

        var tblCrsCourseMainDataSet=await appRepositories.tblCrsCourseMain('Lecture/GetObject', ['*'],getNoSqlData: 0,id:event.lecturePageModel.lectureId ?? BigInt.parse('0'));
        var tblUserMainDataSet = await appRepositories.tblUserMain('Lecture/GetObject', ['id', 'country_id','grade_id'],id: event.lecturePageModel.userId);
        var tblTheaBranMapDataSet = await appRepositories.tblTheaBranMap('Lecture/GetObject', ['id', 'user_id','branch_id'],user_id: event.lecturePageModel.userId);

        var tblLocL1Country = await appRepositories.tblLocL1Country(
          'Lecture/GetObject',
          ['id', 'countrycode', 'lang'],
        );

        int countryId =tblCrsCourseMainDataSet.firstValue('data', 'country', insteadOfNull: 0);

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
                'Lecture/GetObject', ['id', 'country_name', 'lang_id'],
                lang_id: countryLangId);
            var countryName = tblLocL1CountryTrans
                .firstValue('data', 'country_name', insteadOfNull: 'Unknown');
            event.lecturePageModel.countries
                .putIfAbsent(countryId, () => countryName);
          }
        }

        int acadYear = tblCrsCourseMainDataSet.firstValue('data', 'academic_year', insteadOfNull: 0);
        var tblUtilAcademicYearDataSet = await appRepositories.tblUtilAcademicYear('Lecture/GetObject', ['id', 'acad_year','is_default']);
        if (acadYear == 0 || acadYear == null) {
          acadYear = tblUtilAcademicYearDataSet.firstValue('data', 'id',
              filterColumn: 'is_default', filterValue: true, insteadOfNull: 0);
        }

        BigInt? user_Id = tblCrsCourseMainDataSet.firstValueWithType<BigInt>(
            'data', 'user_id',
            insteadOfNull: event.lecturePageModel.userId ?? BigInt.parse('0'));

        int branch_id = tblCrsCourseMainDataSet.firstValue('data', 'branch_id', insteadOfNull: 0);
        if (branch_id == 0 || branch_id == null) {
          branch_id = tblTheaBranMapDataSet.firstValue('data', 'branch_id',insteadOfNull: 0);
        }

        int learn_id = tblCrsCourseMainDataSet.firstValue('data', 'learn_id', insteadOfNull: 0);

        int grade_id = tblCrsCourseMainDataSet.firstValue('data', 'grade_id', insteadOfNull: 0);
        if (grade_id == 0 || grade_id == null) {
          grade_id = tblUserMainDataSet.firstValue('data', 'grade_id',insteadOfNull: 0);
        }



        BigInt id = event.lecturePageModel.lectureId ?? BigInt.parse('0');
        int country = countryId;
        int academicYear = acadYear;
        BigInt userId = user_Id ?? BigInt.parse('0');
        int branchId = branch_id;
        int learnId = learn_id;
        int gradeId = grade_id;
        String title = tblCrsCourseMainDataSet.firstValue('data', 'title', insteadOfNull: '');
        String description = tblCrsCourseMainDataSet.firstValue('data', 'description', insteadOfNull: '');
        String welcomeMsg = tblCrsCourseMainDataSet.firstValue('data', 'welcome_msg', insteadOfNull: '');
        String goodbyeMsg =  tblCrsCourseMainDataSet.firstValue('data', 'goodbye_msg', insteadOfNull: '');
        int isPublic = tblCrsCourseMainDataSet.firstValue('data', 'is_public', insteadOfNull: 1);
        int isActive = tblCrsCourseMainDataSet.firstValue('data', 'is_active', insteadOfNull: 0);
        int isApproved =  tblCrsCourseMainDataSet.firstValue('data', 'is_approved', insteadOfNull: 0);
        double aggRating = tblCrsCourseMainDataSet.firstValue('data', 'agg_rating', insteadOfNull: 0.0);
        BigInt createdBy = tblCrsCourseMainDataSet.firstValueWithType<BigInt>('data', 'created_by', insteadOfNull: event.lecturePageModel.userId) ?? event.lecturePageModel.userId;
        DateTime? createdOn =  tblCrsCourseMainDataSet.firstValueWithType<DateTime>('data', 'created_on', insteadOfNull: DateTime.now());
        BigInt updatedBy =tblCrsCourseMainDataSet.firstValueWithType<BigInt>('data', 'created_by', insteadOfNull: event.lecturePageModel.userId) ?? event.lecturePageModel.userId;
        DateTime? updatedOn = tblCrsCourseMainDataSet.firstValueWithType<DateTime>('data', 'updated_on', insteadOfNull: DateTime.now());

        event.lecturePageModel.setLectureObjects!.tblCrsCourseMain =
            TblCrsCourseMain(
                id: id,
              country: country,
              academicYear: academicYear,
              userId: userId,
              branchId: branchId,
              learnId: learnId,
              gradeId: gradeId,
              title: title,
              description: description,
              welcomeMsg: welcomeMsg,
              goodbyeMsg: goodbyeMsg,
              isPublic: isPublic,
              isActive: isActive,
              isApproved: isApproved,
              aggRating: aggRating,
              createdBy: createdBy,
              createdOn: createdOn,
              updatedBy: updatedBy,
              updatedOn: updatedOn
            );

        event.lecturePageModel.setLectureObjects!.tblCrsCourseMain!.tblCrsCourseFlows=List.empty(growable: true);

        var tblCrsCourseFlowDataSet=await appRepositories.tblCrsCourseFlow('Lecture/GetObject', ['*'],course_id: event.lecturePageModel.lectureId ?? BigInt.parse('0'));

        bool addedAtLeastOne=false;
        for(var flow in tblCrsCourseFlowDataSet.selectDataTable('data'))
          {
            TblCrsCourseFlow newFlow = TblCrsCourseFlow(
                id:BigInt.parse((flow['id'] ?? 0).toString()),
                courseId: BigInt.parse((flow['course_id'] ?? 0).toString()),
              orderNo: flow['order_no'],
              videoId: BigInt.parse((flow['video_id'] ?? 0).toString()),
              quizId: BigInt.parse((flow['quiz_id'] ?? 0).toString()),
              docId: BigInt.parse((flow['doc_id'] ?? 0).toString()),
              questId: BigInt.parse((flow['quest_id'] ?? 0).toString()),
              isActive: flow['is_active'],
            );
            event.lecturePageModel.setLectureObjects!.tblCrsCourseMain!.tblCrsCourseFlows!.add(newFlow);
            addedAtLeastOne=true;
        }

        if(!addedAtLeastOne)
          {
            TblCrsCourseFlow newFlow = TblCrsCourseFlow(
              id:BigInt.parse('0'),
              courseId: BigInt.parse('0'),
              orderNo: 0,
              videoId: BigInt.parse('0'),
              quizId:BigInt.parse('0'),
              docId: BigInt.parse('0'),
              questId: BigInt.parse('0'),
              isActive: 0,
            );
            event.lecturePageModel.setLectureObjects!.tblCrsCourseMain!.tblCrsCourseFlows!.add(newFlow);
          }

        String pleaseSelect=AppLocalization.instance.translate(
            'lib.bloc.bloc.lecture.lectureBloc',
            'initEvent',
            'pleaseSelect');
        event.lecturePageModel.academicYears=tblUtilAcademicYearDataSet.toKeyValuePairsWithTypes<int,String>('data', 'id',valueColumn: 'acad_year');
        event.lecturePageModel.academicYears[0]=pleaseSelect;

        var tblClassGradeDataSet=await appRepositories.tblClassGrade('Lecture/GetObject', ['id','grade_name','country_id'],country_id: countryId);
        event.lecturePageModel.grades=tblClassGradeDataSet.toKeyValuePairsWithTypes<int,String>('data', 'id',valueColumn: 'grade_name');
        event.lecturePageModel.grades[0]=pleaseSelect;

        var tblLearnBranchDataSet=await appRepositories.tblLearnBranch('Lecture/GetObject', ['id','branch_name','country_id'],country_id: countryId);
        event.lecturePageModel.branches=tblLearnBranchDataSet.toKeyValuePairsWithTypes<int,String>('data', 'id',valueColumn: 'branch_name');
        event.lecturePageModel.branches[0]=pleaseSelect;

        if(setAgainRootIdAsZero)
        {
          event.lecturePageModel.lectureId=BigInt.parse('0');
          setAgainRootIdAsZero=false;
        }

        emit(LoadedState(lecturePageModel: event.lecturePageModel));
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        emit(ErrorState(errorMessage: e.toString()));
      }
    });

    on<Step1Event>((event, emit) async {
      lectureRepository = await appRepositories.lectureRepository();
      emit(LoadingStep1State());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedStep1State(lecturePageModel: event.lecturePageModel));
      } catch (e) {
        emit(ErrorStep1State(errorMessage: e.toString()));
      }
    });

    on<Step2Event>((event, emit) async {
      lectureRepository = await appRepositories.lectureRepository();
      emit(LoadingStep2State());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedStep2State(lecturePageModel: event.lecturePageModel));
      } catch (e) {
        emit(ErrorStep2State(errorMessage: e.toString()));
      }
    });

    on<Step3Event>((event, emit) async {
      lectureRepository = await appRepositories.lectureRepository();
      emit(LoadingStep3State());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedStep3State(lecturePageModel: event.lecturePageModel));
      } catch (e) {
        emit(ErrorStep3State(errorMessage: e.toString()));
      }
    });

    on<LoadPmEvent>((event, emit) async {
      lectureRepository = await appRepositories.lectureRepository();
      emit(LoadingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedPmState(lecturePageModel: event.lecturePageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });

    on<DeletePmEvent>((event, emit) async {
      lectureRepository = await appRepositories.lectureRepository();
      emit(DeletingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(DeletedPmState(lecturePageModel: event.lecturePageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });

    on<RemovePmEvent>((event, emit) async {
      lectureRepository = await appRepositories.lectureRepository();
      emit(RemovingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(RemovedPmState(lecturePageModel: event.lecturePageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });

    on<SavePmEvent>((event, emit) async {
      lectureRepository = await appRepositories.lectureRepository();
      emit(SavingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        var tblUserSubuserDataSet = await appRepositories.tblUserSubuser(
            'Lecture/GetObject', ['id', 'main_user_id', 'sub_user_id'],
            sub_user_id: event.lecturePageModel.userId);
        var mainUserId = tblUserSubuserDataSet.firstValueWithType<BigInt>(
            'data', 'main_user_id',
            insteadOfNull: BigInt.parse('0'));
        bool isCorporateUser;
        if (event.lecturePageModel.userId != BigInt.parse(mainUserId.toString()) &&
            mainUserId != null && mainUserId!=BigInt.parse('0')) {
          isCorporateUser = true;
        } else {
          isCorporateUser = false;
        }

        var tblCrsCourseMainDataSet = await appRepositories.tblCrsCourseMain(
            'Lecture/GetObject', ['id', 'created_by', 'updated_by', 'created_on'],
            id: event.lecturePageModel.lectureId);

        BigInt? lectureId = tblCrsCourseMainDataSet.firstValueWithType<BigInt>(
            'data', 'id',
            insteadOfNull: 0); //  if Question not exist to insert new one.
        event.lecturePageModel.lectureId = lectureId;

        BigInt? createdBy = tblCrsCourseMainDataSet.firstValueWithType<BigInt>(
            'data', 'created_by',
            insteadOfNull: BigInt.parse('0'));

        BigInt? updatedBy = tblCrsCourseMainDataSet.firstValueWithType<BigInt>(
            'data', 'updated_by',
            insteadOfNull: BigInt.parse('0'));

        DateTime? createdOn = tblCrsCourseMainDataSet.firstValueWithType<DateTime>(
            'data', 'created_on',
            insteadOfNull: DateTime.now());

        event.lecturePageModel.setLectureObjects?.tblCrsCourseMain?.createdBy= createdBy == BigInt.parse('0')
            ? event.lecturePageModel.userId
            : createdBy;

        event.lecturePageModel.setLectureObjects?.tblCrsCourseMain?.createdOn=event.lecturePageModel.lectureId == BigInt.parse('0') ? DateTime.now() : createdOn;

        event.lecturePageModel.setLectureObjects?.tblCrsCourseMain?.updatedBy=event.lecturePageModel.userId;
        event.lecturePageModel.setLectureObjects?.tblCrsCourseMain?.updatedOn= DateTime.now();
        event.lecturePageModel.setLectureObjects?.tblCrsCourseMain?.userId= isCorporateUser ? mainUserId : event.lecturePageModel.userId;

        var IsSaved =  await lectureRepository.setDataSet(setObject: event.lecturePageModel.setLectureObjects!);
        int bekle = 0;


        emit(SavedPmState(lecturePageModel: event.lecturePageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });
  }
}
