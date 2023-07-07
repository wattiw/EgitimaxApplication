import 'package:egitimaxapplication/bloc/event/question/questionEvent.dart';
import 'package:egitimaxapplication/bloc/state/question/questionState.dart';
import 'package:egitimaxapplication/model/question/question.dart';
import 'package:egitimaxapplication/model/question/questionPageModel.dart';
import 'package:egitimaxapplication/model/question/setQuestionObjects.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/question/questionRepository.dart';
import 'package:egitimaxapplication/utils/constant/appConstant/generalAppConstant.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/extension/keyValueListTranslateExtension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  QuestionBloc() : super(InitState()) {
    AppRepositories appRepositories = AppRepositories();
    QuestionRepository questionRepository;

    on<InitEvent>((event, emit) async {
      questionRepository = await appRepositories.questionRepository();
      emit(LoadingState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        //Burada kullanıcın en son giridği seçimleri set etmek için question id en son kullanıcı tarafından girilen question id'e set edilir.
        //sonra tekrar 0'a set edilir çok önemlidir.

        bool setAgainRootIdAsZero = false;
        if (event.questionPageModel.questionId == BigInt.parse('0')) {
          var lastActionIdDataSet = await questionRepository.lastActionId(
              ['*'], event.questionPageModel.userId);
          event.questionPageModel.questionId =
              lastActionIdDataSet.firstValueWithType<BigInt>(
                  'data', 'id', insteadOfNull: BigInt.parse('0'));
          setAgainRootIdAsZero = true;
        }

        Locale currentLocale = WidgetsBinding.instance.window.locale;
        String languageCode = currentLocale.languageCode; // 'tr'
        String countryCode = currentLocale.languageCode; // 'TR'

        var tblQueQuestionMainDataSet = await appRepositories
            .tblQueQuestionMain('Question/GetObject', [
          'id',
          'country',
          'grade_id',
          'academic_year',
          'question_type',
          'difficulty_lev',
          'subdom_id'
        ], id: event.questionPageModel.questionId);
        var tblQueQuestOptionDataSet = await appRepositories
            .tblQueQuestOption('Question/GetObject', [
          'id',
          'quest_id',
          'is_active',
          'is_correct',
          'opt_identifier',
          'opt_text',
          'opt_text'
        ], quest_id: event.questionPageModel.questionId);
        var tblQueQuestAchvMapDataSet = await appRepositories
            .tblQueQuestAchvMap(
            'Question/GetObject', ['id', 'quest_id', 'achv_id'],
            quest_id: event.questionPageModel.questionId);
        var tblUserMainDataSet = await appRepositories.tblUserMain(
            'Question/GetObject', ['id', 'country_id', 'grade_id'],
            id: event.questionPageModel.userId);

        int countryId = 0;
        Map<int, String> countries = {};
        if (event.questionPageModel.questionId != null &&
            event.questionPageModel.questionId != BigInt.parse('0')) {
          var questionCountryId = tblQueQuestionMainDataSet
              .firstValue('data', 'country', insteadOfNull: 0);
          if (questionCountryId != null && questionCountryId != 0) {
            countryId = questionCountryId;
          } else {
            var tblLocL1CountryDataSet = await appRepositories
                .tblLocL1Country('Question/GetObject', ['id', 'countrycode'],
                countrycode: countryCode.toUpperCase());
            var deviceCountryId = tblLocL1CountryDataSet
                .firstValue('data', 'id', insteadOfNull: 0);
            countryId = deviceCountryId;
          }
        } else {
          var userCountryId = tblUserMainDataSet
              .firstValue('data', 'country_id', insteadOfNull: 0);
          if (userCountryId != null && userCountryId != 0) {
            countryId = userCountryId;
          } else {
            var tblLocL1Country = await appRepositories.tblLocL1Country(
                'Question/GetObject', ['id', 'countrycode'],
                countrycode: countryCode.toUpperCase());
            var deviceCountryId =
            tblLocL1Country.firstValue('data', 'id', insteadOfNull: 0);
            countryId = deviceCountryId;
          }
        }


        List<Option>? options = [];



        int gradeId = 0;
        Map<int, String> grades = {};
        var tblClassGradeDataSet =
        await appRepositories.tblClassGrade(
            'Question/GetObject', ['id', 'grade_name', 'country_id'],
            country_id: countryId);

        int academicYearId = 0;
        Map<int, String> academicYears = {};
        var tblUtilAcademicYearDataSet =
        await appRepositories.tblUtilAcademicYear(
            'Question/GetObject', ['id', 'is_default', 'acad_year']);

        int questionTypeId = 0;
        Map<int, String> questionTypes = {};
        var tblQueQuestTypeDataSet = await appRepositories
            .tblQueQuestType('Question/GetObject',
            ['id', 'quest_type']); // Json'dan dil değerleri okunacak

        int difficultyLevelId = 0;
        Map<int, String> difficultyLevels = {};
        var tblUtilDifficultyDataSet = await appRepositories
            .tblUtilDifficulty('Question/GetObject',
            ['id', 'dif_level']); // Jsondan dil değrleri okunacak

        int branchId = 0;
        Map<int, String> branches = {};
        var tblLearnBranchDataSet =
        await appRepositories.tblLearnBranch(
            'Question/GetObject', ['id', 'branch_name', 'country_id'],
            country_id: countryId);

        Set<int> achievementIds = {};
        Map<int, String> achievements = {};

        if (event.questionPageModel.questionId != null &&
            event.questionPageModel.questionId != BigInt.parse('0')) {
          event.questionPageModel.question= tblQueQuestionMainDataSet.firstValue(
              'collectiondata_question', 'QuestionDocument',
              insteadOfNull: GeneralAppConstant.Slogan);

          event.questionPageModel.freeTextAnswer = tblQueQuestionMainDataSet
              .firstValue('collectiondata_question', 'QuestionAnswerDocument',
                  insteadOfNull: GeneralAppConstant.Slogan);



          var questionOptionsFromSql = tblQueQuestOptionDataSet.selectDataTable(
              'data',
              filterColumn: 'quest_id',
              filterValue: event.questionPageModel.questionId);

          List<Option>? questionOptions = List.empty(growable: true);
          List<QuestionOptionsController>? questionOptionsController= List.empty(growable: true);
          int i=0;
          for (var qop in questionOptionsFromSql) {
            try {
              Option option = Option();
              QuestionOptionsController opCont=QuestionOptionsController();

              option.id = BigInt.tryParse(qop['id'].toString());
              option.isActive = qop['is_active'] == 1 ? true : false;
              option.isCorrect = qop['is_correct'] == 1 ? true : false;
              option.questId = BigInt.tryParse(qop['quest_id'].toString());
              option.mark = qop['opt_identifier'];
              option.data = qop['opt_text'];
              option.text = qop['opt_text'];

              var qopHtmlString = tblQueQuestionMainDataSet.firstValue(
                  'collectiondata_questionoptions', 'OptionValue',
                  filterColumn: 'OptionId',
                  filterValue: option.id,
                  insteadOfNull: GeneralAppConstant.Slogan);

              option.data = qopHtmlString;
              option.text = qopHtmlString;

              opCont.data=option.data;
              opCont.mark=option.mark;
              opCont.isCorrect=option.isCorrect ?? false;

              questionOptions.add(option);
              questionOptionsController.add(opCont);
            } catch (e) {
              debugPrint(e.toString());
            }
            i++;
          }

          event.questionPageModel.options = questionOptions;
          event.questionPageModel.questionOptionsController=questionOptionsController; // Önemli İnit 'de func tetikleniyor fakat zamanlama  dan dolayı null geliyor.Event'in bitmesi beklenmiyor.

          if (countryId == null || countryId == 0) {
            var tblLocL1Country = await appRepositories.tblLocL1Country('Question/GetObject',['id','lang','countrycode'],
                countrycode: countryCode.toUpperCase());
            var deviceCountries =
            tblLocL1Country.toKeyValuePairsWithTypes<int, int>('data', 'id',
                valueColumn: 'lang');
            for (var country in deviceCountries.entries) {
              int countryId = country.key;
              int countryLangId = country.value;
              var tblLocL1CountryTrans = await appRepositories
                  .tblLocL1CountryTrans('Question/GetObject',['id','country_name','lang_id'],lang_id: countryLangId);
              var countryName = tblLocL1CountryTrans
                  .firstValue('data', 'country_name', insteadOfNull: 'Unknown');
              countries.putIfAbsent(countryId, () => countryName);
            }
          } else {
            var tblLocL1Country =
            await appRepositories.tblLocL1Country('Question/GetObject',['id','lang'],id: countryId);
            var userCountries =
            tblLocL1Country.toKeyValuePairsWithTypes<int, int>('data', 'id',
                valueColumn: 'lang');

            for (var country in userCountries.entries) {
              int countryId = country.key;
              int countryLangId = country.value;
              var tblLocL1CountryTrans = await appRepositories
                  .tblLocL1CountryTrans('Question/GetObject',['id','country_name','lang_id'],lang_id: countryLangId);
              var countryName = tblLocL1CountryTrans
                  .firstValue('data', 'country_name', insteadOfNull: 'Unknown');
              countries.putIfAbsent(countryId, () => countryName);
            }
          }

          event.questionPageModel.countries = countries;

          var questionGradeId = tblQueQuestionMainDataSet
              .firstValue('data', 'grade_id', insteadOfNull: 0);
          gradeId = questionGradeId;

          var questionAcademicYearId = tblQueQuestionMainDataSet
              .firstValue('data', 'academic_year', insteadOfNull: 0);
          academicYearId = questionAcademicYearId;

          var questionQuestionTypeId = tblQueQuestionMainDataSet
              .firstValue('data', 'question_type', insteadOfNull: 0);
          questionTypeId = questionQuestionTypeId;

          var questionDifficultyLevelId = tblQueQuestionMainDataSet
              .firstValue('data', 'difficulty_lev', insteadOfNull: 0);
          difficultyLevelId = questionDifficultyLevelId;


          var questionSubDomainId = tblQueQuestionMainDataSet.firstValue('data', 'subdom_id', insteadOfNull: 0);
          var questionBranchDataSet=await appRepositories.tblLearnMain('Question/GetObject', ['id','branch_id'],id:questionSubDomainId );
          branchId=questionBranchDataSet.firstValue('data', 'branch_id',insteadOfNull: 0);


          var questionAchievemetns = tblQueQuestAchvMapDataSet
              .toKeyValuePairsWithTypes<int, int>('data', 'achv_id',
                  valueColumn: 'achv_id',
                  filterColumn: 'quest_id',
                  filterValue: event.questionPageModel.questionId);
          for (var achvId in questionAchievemetns.entries) {
            achievementIds.add(achvId.value);
          }

        } else {
          if (countryId == null || countryId == 0) {
            var tblLocL1Country = await appRepositories.tblLocL1Country('Question/GetObject',['id','lang','countrycode'],
                countrycode: countryCode.toUpperCase());
            var deviceCountries =
                tblLocL1Country.toKeyValuePairsWithTypes<int, int>('data', 'id',
                    valueColumn: 'lang');
            for (var country in deviceCountries.entries) {
              int countryId = country.key;
              int countryLangId = country.value;
              var tblLocL1CountryTrans = await appRepositories
                  .tblLocL1CountryTrans('Question/GetObject',['id','country_name','lang_id'],lang_id: countryLangId);
              var countryName = tblLocL1CountryTrans
                  .firstValue('data', 'country_name', insteadOfNull: 'Unknown');
              countries.putIfAbsent(countryId, () => countryName);
            }
          } else {
            var tblLocL1Country =
                await appRepositories.tblLocL1Country('Question/GetObject',['id','lang'],id: countryId);
            var userCountries =
                tblLocL1Country.toKeyValuePairsWithTypes<int, int>('data', 'id',
                    valueColumn: 'lang');

            for (var country in userCountries.entries) {
              int countryId = country.key;
              int countryLangId = country.value;
              var tblLocL1CountryTrans = await appRepositories
                  .tblLocL1CountryTrans('Question/GetObject',['id','country_name','lang_id'],lang_id: countryLangId);
              var countryName = tblLocL1CountryTrans
                  .firstValue('data', 'country_name', insteadOfNull: 'Unknown');
              countries.putIfAbsent(countryId, () => countryName);
            }
          }
          event.questionPageModel.countries = countries;

          var userGradeId = tblUserMainDataSet.firstValue('data', 'grade_id',
              insteadOfNull: 0);
          gradeId = userGradeId;

          var userAcademicYearId = tblUtilAcademicYearDataSet.firstValue(
              'data', 'id',
              filterColumn: 'is_default', filterValue: true, insteadOfNull: 0);
          academicYearId = userAcademicYearId;

          var userQuestionTypeId = tblQueQuestTypeDataSet.firstValue(
              'data', 'id',
              filterColumn: 'quest_type',
              filterValue: 'qt_test',
              insteadOfNull: 0);
          questionTypeId = userQuestionTypeId;

          var userDifficultyLevelId = tblUtilDifficultyDataSet.firstValue(
              'data', 'id',
              filterColumn: 'dif_level',
              filterValue: 'dif_medium',
              insteadOfNull: 0);
          difficultyLevelId = userDifficultyLevelId;

          var tblTheaBranMapDataSet = await appRepositories.tblTheaBranMap('Question/GetObject',['id','branch_id','user_id'],
              user_id: event.questionPageModel.userId);
          var userBranchId = tblTheaBranMapDataSet
              .firstValue('data', 'branch_id', insteadOfNull: 0);
          branchId = userBranchId;

          //user için sudbomain ve achievements'e gerek yok
        }

        event.questionPageModel.selectedCountry = countryId;

        grades = tblClassGradeDataSet.toKeyValuePairsWithTypes<int, String>(
            'data', 'id',
            valueColumn: 'grade_name');
        event.questionPageModel.grades = grades;
        event.questionPageModel.selectedGrade = gradeId;

        academicYears = tblUtilAcademicYearDataSet
            .toKeyValuePairsWithTypes<int, String>('data', 'id',
                valueColumn: 'acad_year');
        event.questionPageModel.academicYears = academicYears;
        event.questionPageModel.selectedAcademicYear = academicYearId;

        questionTypes = tblQueQuestTypeDataSet
            .toKeyValuePairsWithTypes<int, String>('data', 'id',
                valueColumn: 'quest_type');
        questionTypes=questionTypes.translate();
        event.questionPageModel.questionTypes = questionTypes;
        event.questionPageModel.selectedQuestionType = questionTypeId;

        difficultyLevels = tblUtilDifficultyDataSet
            .toKeyValuePairsWithTypes<int, String>('data', 'id',
                valueColumn: 'dif_level');

        difficultyLevels=difficultyLevels.translate();
        event.questionPageModel.difficultyLevels = difficultyLevels;
        event.questionPageModel.selectedDifficultyLevel = difficultyLevelId;

        branches = tblLearnBranchDataSet.toKeyValuePairsWithTypes<int, String>(
            'data', 'id',
            valueColumn: 'branch_name');
        event.questionPageModel.branches = branches;
        event.questionPageModel.selectedBranch = branchId;


        var learnId=tblQueQuestionMainDataSet.firstValue('data', 'subdom_id', insteadOfNull: 0);
        event.questionPageModel.selectedLearn=learnId;

        if(event.questionPageModel.selectedLearn==0 || event.questionPageModel.selectedLearn==null)
          {

          }
        else
          {
            //Get Achievements
            var tblLearnMainDataSet=await appRepositories.tblLearnMain('Question/GetObject',['id','name','branch_id','country_id','parent_id','type'],parent_id: event.questionPageModel.selectedLearn,country_id: countryId,type: 'ct_achv');
            achievements = tblLearnMainDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',valueColumn: 'name');
            event.questionPageModel.achievements = achievements;

            var firtsAchievementId=achievements.entries.first.key;
            branchId=tblLearnMainDataSet.firstValue('data', 'branch_id',insteadOfNull: branchId);
            event.questionPageModel.selectedBranch = branchId;

            //Yukarıdakiler kaldırılacak sonra
            achievementIds={};
            var questionAchievemetns = tblQueQuestAchvMapDataSet
                .toKeyValuePairsWithTypes<int, int>('data', 'achv_id',
                valueColumn: 'achv_id',
                filterColumn: 'quest_id',
                filterValue: event.questionPageModel.questionId);
            for (var achvId in questionAchievemetns.entries) {
              achievementIds.add(achvId.value);
            }
            event.questionPageModel.selectedAchievements = achievementIds;

          }


        if(setAgainRootIdAsZero)
        {
          event.questionPageModel.question='';


          for(var op in event.questionPageModel.options!)
            {
              op.data='';
              op.text='';
              op.questId=BigInt.parse('0');
              op.isCorrect=false;
            }

          if(event.questionPageModel!=null && event.questionPageModel.questionOptionsController!=null &&  event.questionPageModel.questionOptionsController!.isNotEmpty)
            {
              for(var opC in event.questionPageModel.questionOptionsController!)
              {
                opC.data='';
                opC.textController.setText('');
                opC.isCorrect=false;
              }
            }


          event.questionPageModel.selectedAchievements= {};

          event.questionPageModel.questionId=BigInt.parse('0');
          setAgainRootIdAsZero=false;
        }


        emit(LoadedState(questionPageModel: event.questionPageModel));
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        emit(ErrorState(errorMessage: e.toString()));
      }
    });

    on<Step1Event>((event, emit) async {
      emit(LoadingStep1State());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedStep1State(questionPageModel: event.questionPageModel));
      } catch (e) {
        emit(ErrorStep1State(errorMessage: e.toString()));
      }
    });

    on<Step2Event>((event, emit) async {
      emit(LoadingStep2State());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedStep2State(questionPageModel: event.questionPageModel));
      } catch (e) {
        emit(ErrorStep2State(errorMessage: e.toString()));
      }
    });

    on<Step3Event>((event, emit) async {
      emit(LoadingStep3State());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedStep3State(questionPageModel: event.questionPageModel));
      } catch (e) {
        emit(ErrorStep3State(errorMessage: e.toString()));
      }
    });

    on<LoadPmEvent>((event, emit) async {
      emit(LoadingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedPmState(questionPageModel: event.questionPageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });

    on<DeletePmEvent>((event, emit) async {
      emit(DeletingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(DeletedPmState(questionPageModel: event.questionPageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });

    on<RemovePmEvent>((event, emit) async {
      emit(RemovingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(RemovedPmState(questionPageModel: event.questionPageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });

    on<SavePmEvent>((event, emit) async {
      questionRepository = await appRepositories.questionRepository();
      emit(SavingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {


        var tblUserSubuserDataSet=await appRepositories.tblUserSubuser('Question/GetObject',['id','main_user_id','sub_user_id'],sub_user_id: event.questionPageModel.userId);
        var mainUserId=tblUserSubuserDataSet.firstValueWithType<BigInt>('data', 'main_user_id',insteadOfNull: BigInt.parse('0'));
        bool isCorporateUser;
        if (event.questionPageModel.userId!=BigInt.parse(mainUserId.toString()) && mainUserId!=null && mainUserId!=BigInt.parse('0')) {
          isCorporateUser = true;
        } else {
          isCorporateUser = false;
        }

        var tblQueQuestionMainDataSet = await appRepositories.tblQueQuestionMain('Question/GetObject',['id','created_by','updated_by','created_on'],id: event.questionPageModel.questionId);

        BigInt? questionId=tblQueQuestionMainDataSet.firstValueWithType<BigInt>('data', 'id', insteadOfNull: 0);//  if Question not exist to insert new one.
        event.questionPageModel.questionId=questionId;

        BigInt? createdBy = tblQueQuestionMainDataSet.firstValueWithType<BigInt>('data', 'created_by', insteadOfNull: BigInt.parse('0'));
        BigInt? updatedBy = tblQueQuestionMainDataSet.firstValueWithType<BigInt>('data', 'updated_by', insteadOfNull: BigInt.parse('0'));
        DateTime? createdOn = tblQueQuestionMainDataSet.firstValueWithType<DateTime>('data', 'created_on', insteadOfNull:DateTime.now() );

        SetQuestionObjects setObject = SetQuestionObjects();
        setObject.questionId = event.questionPageModel.questionId;
        setObject.userId = isCorporateUser ? mainUserId :event.questionPageModel.userId;
        setObject.tblQueQuestionMain = TblQueQuestionMain(
          id: event.questionPageModel.questionId ?? BigInt.parse('0'),
          questionType: event.questionPageModel.options!.isNotEmpty ? 1 : 2,
          academicYear: event.questionPageModel.selectedAcademicYear,
          difficultyLev: event.questionPageModel.selectedDifficultyLevel,
          country: event.questionPageModel.selectedCountry,
          userId: isCorporateUser ? mainUserId :event.questionPageModel.userId,
          gradeId: event.questionPageModel.selectedGrade,
          subdomId: event.questionPageModel.selectedLearn,
          questionText: event.questionPageModel.question,
          questionImage: null,
          resolution: event.questionPageModel.freeTextAnswer,
          isPublic: event.questionPageModel.isPublic == true ? 1 : 0,
          isActive: 0,
          isApproved: 0,
          createdBy: createdBy == BigInt.parse('0')
              ? event.questionPageModel.userId
              : createdBy,
          createdOn: event.questionPageModel.questionId==BigInt.parse('0') ? DateTime.now() :createdOn,
          updatedBy: event.questionPageModel.userId,
          updatedOn: DateTime.now(),
        );

        setObject.tblQueQuestOptions = [];

        if (event.questionPageModel.options!.isNotEmpty) {
          var ops = event.questionPageModel.options;
          if (ops != null) {
            for (var option in ops!) {
              var newOp = TblQueQuestOptions(
                id: BigInt.parse(option.id!=null ? option.id.toString():'0'),
                questId: option.questId,
                optIdentifier: option.mark,
                optText: option.data,
                isCorrect: option.isCorrect == true ? 1 : 0,
                isActive: 0,
              );

              setObject.tblQueQuestOptions!.add(newOp);
            }
          }
        }

        setObject.tblQueQuestAchvMaps = [];

        if (event.questionPageModel.selectedAchievements!.isNotEmpty) {
          var achvs = event.questionPageModel.selectedAchievements;
          for (var achv in achvs!) {
            var newAchv = TblQueQuestAchvMaps(
              id: BigInt.parse('0'),
              // Her güncelleme ve yeni oluşturmada id'ler değişir (Api tarafında)
              questId: event.questionPageModel.questionId,
              achvId: achv,
              isActive: 0,
            );
            setObject.tblQueQuestAchvMaps!.add(newAchv);
          }
        }

        var IsSaved =await questionRepository.setDataSet(setObject: setObject);
        int bekle = 0;

        emit(SavedPmState(questionPageModel: event.questionPageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });
  }
}
