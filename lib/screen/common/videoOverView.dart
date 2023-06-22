import 'dart:typed_data';

import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/video/videoRepository.dart';
import 'package:egitimaxapplication/screen/common/collapsibleItemBuilder.dart';
import 'package:egitimaxapplication/screen/common/videoItems.dart';
import 'package:egitimaxapplication/screen/common/webViewPage.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/helper/getDeviceType.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoOverView extends StatefulWidget {
  final BigInt videoId;
  final BigInt userId;
  bool isFavorite = false;
  bool isLiked = false;
  bool isDisLiked = false;
  int likeCount = 0;
  Function(BigInt? videoId)? onAddedVideo;
  final AppRepositories appRepositories = AppRepositories();
  final VideoRepository videoRepository = VideoRepository();
  Uint8List? videoData;

  VideoOverView({
    required this.videoId,
    required this.userId,
    this.onAddedVideo
  });

  @override
  _VideoOverViewState createState() => _VideoOverViewState();
}

class _VideoOverViewState extends State<VideoOverView> {
  @override
  void initState() {
    widget.videoRepository
        .downloadVideo(videoId: widget.videoId)
        .then((videoData) {
      setState(() {
        widget.videoData = videoData;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(context);

    if (deviceType == DeviceType.mobileSmall ||
        deviceType == DeviceType.mobileLarge ||
        deviceType == DeviceType.mobileMedium) {}

    return AlertDialog(
      title: SizedBox(
        height: 40, // Başlık bölümünün yüksekliğini artırın
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                AppLocalization.instance.translate(
                    'lib.screen.common.videoOverView', 'build', 'viewVideo'),
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      content: Container(
        width: double.infinity,
        height: 600,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LikeCountWidget(
                      videoId: widget.videoId,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        UserTotalLikesWidget(
                          videoId: widget.videoId,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        userTotalStudentWidget(
                          videoId: widget.videoId,
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<Widget>(
                  future: getVideoOverView(widget.videoId),
                  builder: (BuildContext context,
                      AsyncSnapshot<Widget> innerSnapshot) {
                    if (innerSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (innerSnapshot.hasError) {
                      return Text(
                          '${AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'error')}: ${innerSnapshot.error}');
                    } else if (innerSnapshot.hasData) {
                      return innerSnapshot.data!;
                    } else {
                      return Container();
                    }
                  },
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.close),
                          SizedBox(width: 8),
                          // Adding some spacing between the icon and text
                          Text(AppLocalization.instance.translate(
                              'lib.screen.common.videoOverView', 'build', 'cancel')),
                        ],
                      ),
                    ),
                      ElevatedButton(
                        onPressed: () {
                          if(widget.onAddedVideo!=null)
                            {
                              widget.onAddedVideo!(widget.videoId);
                            }

                          Navigator.pop(context);
                        },
                        child:  Row(
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 8),
                            // Adding some spacing between the icon and text
                            Text(AppLocalization.instance.translate(
                                'lib.screen.common.videoOverView', 'build', 'add')),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Widget> getVideoOverView(BigInt videoId) async {
    var tblVidVideoMainDataSet = await widget.appRepositories.tblVidVideoMain(
        'Video/GetObject', ['*'],
        id: widget.videoId, getNoSqlData: 0);
    BigInt? videoCreatorUserId =
        tblVidVideoMainDataSet.firstValueWithType<BigInt>('data', 'user_id',
            insteadOfNull: BigInt.parse('0'));
    var tblUserMainDataSet = await widget.appRepositories.tblUserMain(
        'Lecture/GetObject', ['id', 'name', 'surname'],
        id: videoCreatorUserId, getNoSqlData: 0);

    String videoTitle =
        tblVidVideoMainDataSet.firstValue('data', 'title', insteadOfNull: '');
    String videoPreparedBy = tblUserMainDataSet.firstValue('data', 'name') +
        ' ' +
        tblUserMainDataSet.firstValue('data', 'surname');

    var videoOverViewDataSet = await widget.appRepositories
        .videoOverView('Lecture/GetObject', ['*'], widget.videoId);
    String videoDescriptions = videoOverViewDataSet
        .firstValue('data', 'description', insteadOfNull: '');
    var branchName = videoOverViewDataSet.firstValue('data', 'branch_name',
        insteadOfNull: '');
    var gradeName = videoOverViewDataSet.firstValue('data', 'grade_name',
        insteadOfNull: '');
    var acadYearName =
        videoOverViewDataSet.firstValue('data', 'acad_year', insteadOfNull: '');

    var learData = videoOverViewDataSet.firstValue('data', 'learn_data',
        insteadOfNull: '');

    String learnInfo = learData;

    List<String> firstSplit = learnInfo.split("|");
    String firstPart = firstSplit[0];
    String secondPart = firstSplit[1];

    List<String> secondSplit = secondPart.split(";");

    List<Map<String, String>> keyValueList = [];

    for (String item in secondSplit) {
      List<String> itemSplit = item.split(":");
      String key = itemSplit[0];
      String value = itemSplit[1];
      keyValueList.add({key: value});
    }

    var libType = {
      "ct_dom": AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'domain'),
      "ct_subdom": AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'subdomain'),
      "ct_achv": AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'achievement'),
      "ct_subject": AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'subject')
    };

    List<Widget> details = keyValueList.map((item) {
      String key = libType[item.keys.first] ?? "";
      String value = item.values.first;
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            '$key:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value)
        ],
      );
    }).toList();

    details = details.reversed.toList();

    var achievements = videoOverViewDataSet.firstValue('data', 'achievements',
        insteadOfNull: '');
    List<String> achievementsList = achievements.split("|");

    var result=Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: details,
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'achievements'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: achievementsList.map((achievement) {
            return Text(achievement);
          }).toList(),
        ),
      ],
    );



    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
             Text('${AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'videoTitle')} :'
               ,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(videoTitle)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              '${AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'videoPreparedBy')} :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(videoPreparedBy)
          ],
        ),
        if (widget.videoData != null)
          VideoPlayerObject(
              autoplay: false,
              looping: false,
              videoPlayerController: null,
              videoData: widget.videoData,
              isFullScreen: (isFullScreen) {
                if (!isFullScreen) {
                  setState(() {});
                }
              }),
        const SizedBox(height: 5),
        LikeDislikeFavShareButtons(
          userId: widget.userId,
          videoId: widget.videoId,
        ),
        CollapsibleItemBuilder(items: [
          CollapsibleItemData(
              header: Text(AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'videoDetails')),
              content:result,
              padding: 5,
              onStateChanged: (bool) {})
        ], padding: 10, onStateChanged: (value) {}),
      ],
    );
  }
}

class LikeDislikeFavShareButtons extends StatefulWidget {
  final AppRepositories appRepositories = AppRepositories();
  final VideoRepository videoRepository = VideoRepository();
  final BigInt videoId;
  final BigInt userId;

  LikeDislikeFavShareButtons({required this.userId, required this.videoId});

  @override
  _LikeDislikeFavShareButtonsState createState() =>
      _LikeDislikeFavShareButtonsState();
}

class _LikeDislikeFavShareButtonsState
    extends State<LikeDislikeFavShareButtons> {
  bool isLiked = false;
  bool isDisLiked = false;
  bool isFavorite = false;
  bool hideText = false;

  Future<void> setIsLikedByMe() async {
    var nullVoid = await widget.videoRepository.videoSetIsLikeOrNot(
        ['*'], widget.videoId, isLiked ? 1 : 0, widget.userId,
        getNoSqlData: 0);
    setState(() {});
  }

  Future<void> setIsDisLikedByMe() async {
    var nullVoid = await widget.videoRepository.videoSetIsLikeOrNot(
        ['*'], widget.videoId, isDisLiked ? 2 : 0, widget.userId,
        getNoSqlData: 0);
    setState(() {});
  }

  Future<void> setIsMyFavorite() async {
    var nullVoid = await widget.videoRepository.videoSetMyFavorite(
        ['*'], widget.videoId, isFavorite ? 1 : 0, widget.userId,
        getNoSqlData: 0);
    setState(() {});
  }

  void sharevideo() {}

  Future<bool> updateButtonStatus() async {
    var videoLikeDataSet = await widget.appRepositories.tblVidVideoLike(
        'Video/GetObject', ['id', 'video_id', 'user_id', 'like_type'],
        video_id: widget.videoId, user_id: widget.userId);
    var vL = videoLikeDataSet.firstValue('data', 'like_type', insteadOfNull: 0);

    if (vL == 1) {
      isLiked = true;
      isDisLiked = false;
    } else if (vL == 2) {
      isLiked = false;
      isDisLiked = true;
    } else {
      isLiked = false;
      isDisLiked = false;
    }

    var tblFavvideoDataSet = await widget.appRepositories.tblFavVideo(
        'Video/GetObject', ['id', 'video_id', 'user_id'],
        video_id: widget.videoId, user_id: widget.userId);

    var qF =
        tblFavvideoDataSet.firstValue('data', 'video_id', insteadOfNull: 0);

    if (qF > 0) {
      isFavorite = true;
    } else {
      isFavorite = false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(context);

    if (deviceType == DeviceType.mobileSmall ||
        deviceType == DeviceType.mobileLarge ||
        deviceType == DeviceType.mobileMedium) {
      hideText = true;
    }
    return FutureBuilder<bool>(
      future: updateButtonStatus(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isLiked = !isLiked;
                        if (isLiked) {
                          isDisLiked = false;
                        }
                        setIsLikedByMe();
                      });
                    },
                    icon: Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    ),
                    tooltip: isLiked
                        ? AppLocalization.instance.translate(
                            'lib.screen.common.videoOverView',
                            'build',
                            'unlike')
                        : AppLocalization.instance.translate(
                            'lib.screen.common.videoOverView', 'build', 'like'),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isDisLiked = !isDisLiked;
                        if (isDisLiked) {
                          isLiked = false;
                        }
                        setIsDisLikedByMe();
                      });
                    },
                    icon: Icon(
                      isDisLiked
                          ? Icons.thumb_down
                          : Icons.thumb_down_alt_outlined,
                    ),
                    tooltip: isDisLiked
                        ? AppLocalization.instance.translate(
                            'lib.screen.common.videoOverView',
                            'build',
                            'removeDisLike')
                        : AppLocalization.instance.translate(
                            'lib.screen.common.videoOverView',
                            'build',
                            'disLike'),
                  ),
                  if (hideText)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                          setIsMyFavorite();
                        });
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      tooltip: isFavorite
                          ? AppLocalization.instance.translate(
                              'lib.screen.common.videoOverView',
                              'build',
                              'removeFav')
                          : AppLocalization.instance.translate(
                              'lib.screen.common.videoOverView',
                              'build',
                              'addFav'),
                    ),
                  if (hideText)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          sharevideo();
                        });
                      },
                      icon: const Icon(Icons.ios_share),
                      tooltip: AppLocalization.instance.translate(
                          'lib.screen.common.videoOverView',
                          'build',
                          'shareVideo'),
                    ),
                  if (!hideText)
                    Tooltip(
                      message: isFavorite
                          ? AppLocalization.instance.translate(
                              'lib.screen.common.videoOverView',
                              'build',
                              'removeFav')
                          : AppLocalization.instance.translate(
                              'lib.screen.common.videoOverView',
                              'build',
                              'addFav'),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                            setIsMyFavorite();
                          });
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        label: Text(
                          isFavorite
                              ? AppLocalization.instance.translate(
                                  'lib.screen.common.videoOverView',
                                  'build',
                                  'removeFav')
                              : AppLocalization.instance.translate(
                                  'lib.screen.common.videoOverView',
                                  'build',
                                  'addFav'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (!hideText)
                    Tooltip(
                      message: AppLocalization.instance.translate(
                          'lib.screen.common.videoOverView',
                          'build',
                          'shareVideo'),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            sharevideo();
                          });
                        },
                        icon: const Icon(Icons.ios_share),
                        label: Text(
                          AppLocalization.instance.translate(
                              'lib.screen.common.videoOverView',
                              'build',
                              'share'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text(
              '${AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'error')}: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator(); // or any other loading indicator
        }
      },
    );
  }
}

class LikeCountWidget extends StatefulWidget {
  int likeCount = 0;
  final AppRepositories appRepositories = AppRepositories();
  final VideoRepository videoRepository = VideoRepository();
  final BigInt videoId;

  LikeCountWidget({Key? key, required this.videoId}) : super(key: key);

  @override
  _LikeCountWidgetState createState() => _LikeCountWidgetState();
}

class _LikeCountWidgetState extends State<LikeCountWidget> {
  Future<int> getTotalLikes() async {
    var getTotalLikesDataSet = await widget.videoRepository
        .videoTotalLikes(['*'], widget.videoId, getNoSqlData: 0);

    widget.likeCount =
        getTotalLikesDataSet.firstValue('data', 'like_count', insteadOfNull: 0);

    return widget.likeCount;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getTotalLikes(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.thumb_up,
                        color: Colors.yellow,
                      ),
                      Text(
                          '(${widget.likeCount} ${AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'likes')})'),
                    ],
                  ),
                ],
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text(
              '${AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'error')}: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator(); // or any other loading indicator
        }
      },
    );
  }
}

class UserTotalLikesWidget extends StatefulWidget {
  int userTotalLikes = 0;
  final AppRepositories appRepositories = AppRepositories();
  final VideoRepository videoRepository = VideoRepository();
  late BigInt userId;
  final BigInt videoId;

  UserTotalLikesWidget({Key? key, required this.videoId}) : super(key: key);

  @override
  _UserTotalLikesWidgetState createState() => _UserTotalLikesWidgetState();
}

class _UserTotalLikesWidgetState extends State<UserTotalLikesWidget> {
  Future<int> getUserTotalLikes() async {
    var tblVidVideoMainDataSet = await widget.appRepositories.tblVidVideoMain(
        'Lecture/GetObject', ['id', 'user_id'],
        getNoSqlData: 0, id: widget.videoId);
    widget.userId = tblVidVideoMainDataSet.firstValueWithType<BigInt>(
            'data', 'user_id',
            insteadOfNull: BigInt.parse('0')) ??
        BigInt.parse('0');

    var userTotalLikesOrDislikesDataSet = await widget.appRepositories
        .userTotalLikesOrDislikes('Lecture/GetObject', ['*'], widget.userId, 1,
            getNoSqlData: 0);

    widget.userTotalLikes = userTotalLikesOrDislikesDataSet
        .firstValue('data', 'total_like', insteadOfNull: 0);

    return widget.userTotalLikes;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getUserTotalLikes(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person_pin_outlined,
                        color: Colors.orange,
                      ),
                      Text(
                          '(${widget.userTotalLikes} ${AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'teacherLikes')})'),
                    ],
                  ),
                ],
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text(
              '${AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'error')}: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator(); // or any other loading indicator
        }
      },
    );
  }
}

class userTotalStudentWidget extends StatefulWidget {
  int totalStudent = 0;
  final AppRepositories appRepositories = AppRepositories();
  final VideoRepository videoRepository = VideoRepository();
  late BigInt userId;
  final BigInt videoId;

  userTotalStudentWidget({Key? key, required this.videoId}) : super(key: key);

  @override
  _UserTotalStudentWidgetState createState() => _UserTotalStudentWidgetState();
}

class _UserTotalStudentWidgetState extends State<userTotalStudentWidget> {
  Future<int> getTotalStudents() async {
    var tblVidVideoMainDataSet = await widget.appRepositories.tblVidVideoMain(
        'Lecture/GetObject', ['id', 'user_id'],
        getNoSqlData: 0, id: widget.videoId);
    widget.userId = tblVidVideoMainDataSet.firstValueWithType<BigInt>(
            'data', 'user_id',
            insteadOfNull: BigInt.parse('0')) ??
        BigInt.parse('0');

    var userTotalStudentsDataSet = await widget.appRepositories
        .userTotalStudents('Lecture/GetObject', ['*'], widget.userId,
            getNoSqlData: 0);

    widget.totalStudent =
        0; // userTotalStudentsDataSet.firstValue('data', 'total_student', insteadOfNull: 0);

    return widget.totalStudent;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getTotalStudents(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        color: Colors.orange,
                      ),
                      Text(
                          '(${widget.totalStudent} ${AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'students')})'),
                    ],
                  ),
                ],
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text(
              '${AppLocalization.instance.translate('lib.screen.common.videoOverView', 'build', 'error')}: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator(); // or any other loading indicator
        }
      },
    );
  }
}
