import 'dart:ui';

import 'package:egitimaxapplication/bloc/event/video/videoEvent.dart';
import 'package:egitimaxapplication/bloc/state/video/videoState.dart';
import 'package:egitimaxapplication/model/video/setVideoObjects.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/video/videoRepository.dart';
import 'package:egitimaxapplication/screen/common/videoItems.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  VideoBloc() : super(InitState()) {
    AppRepositories appRepositories = AppRepositories();
    VideoRepository videoRepository;

    on<InitEvent>((event, emit) async {
      videoRepository = await appRepositories.videoRepository();
      emit(LoadingState());
      await Future.delayed(const Duration(seconds: 1));
      try {

        Locale currentLocale = WidgetsBinding.instance.window.locale;
        String languageCode = currentLocale.languageCode; // 'tr'
        String countryCode = currentLocale.languageCode; // 'TR'

        var tblVidVideoMainDataSet=await appRepositories.tblVidVideoMain('Video/GetObject',['id','video_path', 'is_public', 'title', 'description', 'country', 'academic_year', 'grade_id', 'branch_id', 'subdom_id'],id: event.videoPageModel.videoId);
        var tblVidVideoAchvMapDataSet=await appRepositories.tblVidVideoAchvMap('Video/GetObject',['id','achv_id','video_id'],video_id: event.videoPageModel.videoId);
        var tblUserMainDataSet = await appRepositories.tblUserMain('Video/GetObject',['id','country_id'],id: event.videoPageModel.userId);
        var tblLocL1Country = await appRepositories.tblLocL1Country('Video/GetObject',['id','lang','countrycode']);

        if(event.videoPageModel.videoId!=null && event.videoPageModel.videoId!=0)
          {
            BigInt vId=event.videoPageModel.videoId ?? BigInt.parse('0');
            event.videoPageModel.videoData=await  videoRepository.downloadVideo(videoId: vId);

          }
        else
          {
            event.videoPageModel.videoData=null;
          }

        event.videoPageModel.videoObjectId=tblVidVideoMainDataSet.firstValue('data','video_path');
        VideoControllerProvider.createController(
            videoData: event.videoPageModel.videoData)
            .then((videoPlayerController) {
          event.videoPageModel.videoPlayerController = videoPlayerController;
          if(videoPlayerController!=null)
            {
              event.videoPageModel.isVideoContainerExpanded=false;
              event.videoPageModel.videoUploadStatusText=AppLocalization.instance.translate(
                  'lib.bloc.bloc.video.videoBloc',
                  'InitEvent',
                  'videoUploaded');
            }
          else
            {
              event.videoPageModel.isVideoContainerExpanded=false;
              event.videoPageModel.videoUploadStatusText=AppLocalization.instance.translate(
                  'lib.bloc.bloc.video.videoBloc',
                  'InitEvent',
                  'videoNotExist');
            }
        });


        var isPublic= tblVidVideoMainDataSet.firstValue('data','is_public',insteadOfNull: 1);
        event.videoPageModel.isPublic=isPublic==1 ? true :false;

        if(isPublic==null || isPublic==0 || isPublic=='')
          {
            event.videoPageModel.isPublic=true;
          }

        event.videoPageModel.isAcceptConditions=false;

        event.videoPageModel.videoTitle=tblVidVideoMainDataSet.firstValue('data','title',insteadOfNull: '');
        event.videoPageModel.videoDescriptions=tblVidVideoMainDataSet.firstValue('data','description',insteadOfNull: '');

        event.videoPageModel.selectedCountry=tblVidVideoMainDataSet.firstValue('data','country',insteadOfNull: 0);
        if( event.videoPageModel.selectedCountry==0 ||  event.videoPageModel.selectedCountry==null )
          {
            event.videoPageModel.selectedCountry=tblUserMainDataSet.firstValue('data', 'country_id',insteadOfNull: 0);
            if( event.videoPageModel.selectedCountry==0 ||  event.videoPageModel.selectedCountry==null )
            {
              event.videoPageModel.selectedCountry=tblLocL1Country.firstValue('data', 'id',filterColumn: 'countrycode',filterValue: countryCode.toUpperCase(),insteadOfNull: 0);
              if( event.videoPageModel.selectedCountry==0 ||  event.videoPageModel.selectedCountry==null )
              {
                event.videoPageModel.selectedCountry=tblLocL1Country.firstValue('data', 'id');
              }
            }
          }
        if(event.videoPageModel.selectedCountry!=null && event.videoPageModel.selectedCountry!=0)
          {
            var countries =tblLocL1Country.toKeyValuePairsWithTypes<int, int>('data', 'id',valueColumn: 'lang');
            for (var country in countries.entries) {
              int countryId = country.key;
              int countryLangId = country.value;
              var tblLocL1CountryTrans = await appRepositories.tblLocL1CountryTrans('Video/GetObject',['id','country_name','lang_id'],lang_id: countryLangId);
              var countryName = tblLocL1CountryTrans.firstValue('data', 'country_name', insteadOfNull: 'Unknown');
              event.videoPageModel.countries.putIfAbsent(countryId, () => countryName);
            }
          }


        var tblUtilAcademicYearDataSet=await appRepositories.tblUtilAcademicYear('Video/GetObject',['id','is_default','acad_year']);
        event.videoPageModel.selectedAcademicYear=tblVidVideoMainDataSet.firstValue('data','academic_year',insteadOfNull:0);
        if( event.videoPageModel.selectedAcademicYear==0 ||  event.videoPageModel.selectedAcademicYear==null )
        {

          event.videoPageModel.selectedAcademicYear= tblUtilAcademicYearDataSet.firstValue('data', 'id',filterColumn: 'is_default', filterValue: true, insteadOfNull: 0);

        }
        event.videoPageModel.academicYears=tblUtilAcademicYearDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',valueColumn: 'acad_year');


        var tblClassGradeDataSet =await appRepositories.tblClassGrade('Video/GetObject',['id','grade_name','country_id'],country_id: event.videoPageModel.selectedCountry);
        event.videoPageModel.selectedGrade=tblVidVideoMainDataSet.firstValue('data','grade_id',insteadOfNull: 0);
        if(event.videoPageModel.selectedGrade==0 || event.videoPageModel.selectedGrade==null)
          {
            event.videoPageModel.selectedGrade = tblClassGradeDataSet.firstValue('data', 'id');
          }
        event.videoPageModel.grades = tblClassGradeDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',valueColumn: 'grade_name');



        var tblTheaBranMapDataSet = await appRepositories.tblTheaBranMap('Video/GetObject',['id','branch_id','user_id'],user_id: event.videoPageModel.userId);
        event.videoPageModel.selectedBranch=tblVidVideoMainDataSet.firstValue('data','branch_id',insteadOfNull: 0);
        if(event.videoPageModel.selectedBranch==0 || event.videoPageModel.selectedBranch==null)
        {
          event.videoPageModel.selectedBranch = tblTheaBranMapDataSet.firstValue('data', 'branch_id', insteadOfNull: 0);
        }
        var tblLearnBranch = await appRepositories.tblLearnBranch('Video/GetObject',['id','branch_name','country_id'],country_id: event.videoPageModel.selectedCountry);
        event.videoPageModel.branches = tblLearnBranch.toKeyValuePairsWithTypes<int, String>('data', 'id',valueColumn: 'branch_name');


        event.videoPageModel.selectedSubDomain=tblVidVideoMainDataSet.firstValue('data','subdom_id',insteadOfNull: 0);
        if(event.videoPageModel.selectedSubDomain==0 || event.videoPageModel.selectedSubDomain==null)
        {

        }
        else
          {
            var tblLearnSubdomainDataSet=await appRepositories.tblLearnSubdomain('Video/GetObject',['id','domain_id']);
            event.videoPageModel.selectedDomain=tblLearnSubdomainDataSet.firstValue('data', 'domain_id',filterColumn: 'id',filterValue: event.videoPageModel.selectedSubDomain);

          }

        if(event.videoPageModel.selectedBranch!=0 && event.videoPageModel.selectedBranch!=null)
          {
            var tblLearnDomainDataSet=await appRepositories.tblLearnDomain('Video/GetObject',['id','domain_name','branch_id'],branch_id: event.videoPageModel.selectedBranch);
            event.videoPageModel.domains=tblLearnDomainDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',valueColumn: 'domain_name');
          }

        if(event.videoPageModel.selectedDomain!=0 && event.videoPageModel.selectedDomain!=null)
        {
          var tblLearnSubdomainDataSet=await appRepositories.tblLearnSubdomain('Video/GetObject',['id','subdom_name','domain_id'],domain_id: event.videoPageModel.selectedDomain);
          event.videoPageModel.subDomains=tblLearnSubdomainDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',valueColumn: 'subdom_name');
        }

        var videoAchievements = tblVidVideoAchvMapDataSet
            .toKeyValuePairsWithTypes<int, int>('data', 'achv_id',
            valueColumn: 'achv_id',
            filterColumn: 'video_id',
            filterValue: event.videoPageModel.videoId);
        for (var achvId in videoAchievements.entries) {
          event.videoPageModel.selectedAchievements.add(achvId.value);
        }

        if(event.videoPageModel.selectedSubDomain!=0 && event.videoPageModel.selectedSubDomain!=null)
        {
          var tblLearnAchivementDataSet =await videoRepository.getAchievementsFromSubDomainId(['id','achivement_text','subdom_id','country_id'],subdom_id: event.videoPageModel.selectedSubDomain, country_id: event.videoPageModel.selectedCountry);
          event.videoPageModel.achievements = tblLearnAchivementDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',valueColumn: 'achivement_text');
        }
        event.videoPageModel.achievementsBulk=await videoRepository.getAchievementsFromSubDomainId(['id','achivement_text','subdom_id','country_id']);



        var learnId=tblVidVideoMainDataSet.firstValue('data', 'subdom_id', insteadOfNull: 0);
        event.videoPageModel.selectedLearn=learnId;

        if(event.videoPageModel.selectedLearn==0 || event.videoPageModel.selectedLearn==null)
        {

        }
        else
        {
          //Get Achievements
          var tblLearnMainDataSet=await appRepositories.tblLearnMain('Video/GetObject',['id','name','branch_id','parent_id','country_id','type'],parent_id: event.videoPageModel.selectedLearn,country_id: event.videoPageModel.selectedCountry,type: 'ct_achv');
          var achievements = tblLearnMainDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',valueColumn: 'name');
          event.videoPageModel.achievements = achievements;

          var firtsAchievementId=achievements.entries.first.key;
          var branchId=tblLearnMainDataSet.firstValue('data', 'branch_id',insteadOfNull: event.videoPageModel.selectedBranch);
          event.videoPageModel.selectedBranch = branchId;

          //Yukarıdakiler kaldırılacak sonra
          Set<int> achievementIds={};
          var questionAchievemetns = tblVidVideoAchvMapDataSet
              .toKeyValuePairsWithTypes<int, int>('data', 'achv_id',
              valueColumn: 'achv_id',
              filterColumn: 'video_id',
              filterValue: event.videoPageModel.videoId);
          for (var achvId in questionAchievemetns.entries) {
            achievementIds.add(achvId.value);
          }
          event.videoPageModel.selectedAchievements = achievementIds;

        }

        emit(LoadedState(videoPageModel: event.videoPageModel));
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        emit(ErrorState(errorMessage: e.toString()));
      }
    });

    on<Step1Event>((event, emit) async {
      videoRepository = await appRepositories.videoRepository();
      emit(LoadingStep1State());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedStep1State(videoPageModel: event.videoPageModel));
      } catch (e) {
        emit(ErrorStep1State(errorMessage: e.toString()));
      }
    });

    on<Step2Event>((event, emit) async {
      videoRepository = await appRepositories.videoRepository();
      emit(LoadingStep2State());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedStep2State(videoPageModel: event.videoPageModel));
      } catch (e) {
        emit(ErrorStep2State(errorMessage: e.toString()));
      }
    });

    on<Step3Event>((event, emit) async {
      videoRepository = await appRepositories.videoRepository();
      emit(LoadingStep3State());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedStep3State(videoPageModel: event.videoPageModel));
      } catch (e) {
        emit(ErrorStep3State(errorMessage: e.toString()));
      }
    });

    on<LoadPmEvent>((event, emit) async {
      videoRepository = await appRepositories.videoRepository();
      emit(LoadingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(LoadedPmState(videoPageModel: event.videoPageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });

    on<DeletePmEvent>((event, emit) async {
      videoRepository = await appRepositories.videoRepository();
      emit(DeletingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(DeletedPmState(videoPageModel: event.videoPageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });

    on<RemovePmEvent>((event, emit) async {
      videoRepository = await appRepositories.videoRepository();
      emit(RemovingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {
        // Some async operation
        emit(RemovedPmState(videoPageModel: event.videoPageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });

    on<SavePmEvent>((event, emit) async {
      videoRepository = await appRepositories.videoRepository();
      emit(SavingPmState());
      await Future.delayed(const Duration(seconds: 1));
      try {

        var tblUserSubuserDataSet=await appRepositories.tblUserSubuser('Question/GetObject',['id','main_user_id','sub_user_id'],sub_user_id: event.videoPageModel.userId);
        var mainUserId=tblUserSubuserDataSet.firstValueWithType<BigInt>('data', 'main_user_id',insteadOfNull: BigInt.parse('0'));
        bool isCorporateUser;
        if (mainUserId!=BigInt.parse(mainUserId.toString()) && mainUserId!=null) {
          isCorporateUser = true;
        } else {
          isCorporateUser = false;
        }

        var tblVidVideoMainDataSet = await appRepositories.tblVidVideoMain('Video/GetObject',['id','created_by','updated_by','created_on'],id: event.videoPageModel.videoId);

        BigInt? videoId=tblVidVideoMainDataSet.firstValueWithType<BigInt>('data', 'id', insteadOfNull: 0);//  if Question not exist to insert new one.
        event.videoPageModel.videoId=videoId;

        BigInt? createdBy = tblVidVideoMainDataSet.firstValueWithType<BigInt>('data', 'created_by', insteadOfNull: BigInt.parse('0'));
        BigInt? updatedBy = tblVidVideoMainDataSet.firstValueWithType<BigInt>('data', 'updated_by', insteadOfNull: BigInt.parse('0'));
        DateTime? createdOn = tblVidVideoMainDataSet.firstValueWithType<DateTime>('data', 'created_on', insteadOfNull:DateTime.now() );
     double? aggRating = tblVidVideoMainDataSet.firstValueWithType<double?>('data', 'aggRating', insteadOfNull:double.parse('0') );

        SetVideoObjects setObject = SetVideoObjects();
        setObject.isDelete=false;
        setObject.isPassive=false;
        setObject.isActive=false;
        setObject.videoId = event.videoPageModel.videoId;
        setObject.userId = isCorporateUser ? mainUserId :event.videoPageModel.userId;
        setObject.videoObjectId=event.videoPageModel.videoObjectId;

        setObject.tblVidVideoMain = TblVidVideoMain(
          id: event.videoPageModel.videoId ?? BigInt.parse('0'),
          academicYear: event.videoPageModel.selectedAcademicYear,
          country: event.videoPageModel.selectedCountry,
          userId: isCorporateUser ? mainUserId :event.videoPageModel.userId,
          branchId: event.videoPageModel.selectedBranch,
          gradeId: event.videoPageModel.selectedGrade,
          subdomId: event.videoPageModel.selectedSubDomain,
          title: event.videoPageModel.videoTitle ?? '',
          description: event.videoPageModel.videoDescriptions ?? '',
          videoPath: event.videoPageModel.videoObjectId ?? '',
          isPublic: event.videoPageModel.isPublic == true ? 1 : 0,
          isActive: 0,
          isApproved: 0,
          aggRating: aggRating,
          createdBy: createdBy == BigInt.parse('0')
              ? event.videoPageModel.userId
              : createdBy,
          createdOn: event.videoPageModel.videoId==0 ? DateTime.now() :createdOn,
          updatedBy: event.videoPageModel.userId,
          updatedOn: DateTime.now(),
        );


        setObject.tblVidVideoAchvMaps = [];

        if (event.videoPageModel.selectedAchievements!.isNotEmpty) {
          var achvs = event.videoPageModel.selectedAchievements;
          for (var achv in achvs!) {
            var newAchv = TblVidVideoAchvMap(
              id: BigInt.parse('0'), // Her güncelleme ve yeni oluşturmada id'ler değişir (Api tarafında)
              videoId: event.videoPageModel.videoId,
              achvId: achv,
              isActive: 0,
            );
            setObject.tblVidVideoAchvMaps!.add(newAchv);
          }
        }

        var IsSaved =await videoRepository.setDataSet(setObject: setObject);
        int bekle = 0;


        emit(SavedPmState(videoPageModel: event.videoPageModel));
      } catch (e) {
        emit(ErrorPmState(errorMessage: e.toString()));
      }
    });
  }
}
