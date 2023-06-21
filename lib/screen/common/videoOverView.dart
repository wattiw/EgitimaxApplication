
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/video/videoRepository.dart';
import 'package:egitimaxapplication/screen/common/webViewPage.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/helper/getDeviceType.dart';
import 'package:flutter/material.dart';

class VideoOverView extends StatefulWidget {
  final BigInt videoId;
  final BigInt userId;
  bool isFavorite = false;
  bool isLiked = false;
  bool isDisLiked = false;
  int likeCount = 0;
  AppRepositories appRepositories = AppRepositories();
  VideoRepository videoRepository = VideoRepository();

  VideoOverView({
    required this.videoId,
    required this.userId,
  });

  @override
  _VideoOverViewState createState() => _VideoOverViewState();
}

class _VideoOverViewState extends State<VideoOverView> {

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

    }

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
                LikeCountWidget(
                  videoId: widget.videoId,
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
                      return Text('${AppLocalization.instance.translate(
                          'lib.screen.common.videoOverView', 'build',
                          'error')}: ${innerSnapshot.error}');
                    } else if (innerSnapshot.hasData) {
                      return innerSnapshot.data!;
                    } else {
                      return Container();
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (false)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.close),
                            SizedBox(width: 8),
                            // Adding some spacing between the icon and text
                            Text('Close'),
                          ],
                        ),
                      ),
                    const SizedBox(
                      height: 15,
                    )
                  ],
                ),
                const SizedBox(height: 5),
                LikeDislikeFavShareButtons(userId:widget.userId ,videoId: widget.videoId,)
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<Widget> getVideoOverView(BigInt videoId) async {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

      ],
    );
  }
}



class LikeDislikeFavShareButtons extends StatefulWidget {
  AppRepositories appRepositories = AppRepositories();
  VideoRepository videoRepository = VideoRepository();
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
    setState(() {

    });
  }

  Future<void> setIsDisLikedByMe() async {
    var nullVoid = await widget.videoRepository.videoSetIsLikeOrNot(
        ['*'], widget.videoId, isDisLiked ? 2 : 0, widget.userId,
        getNoSqlData: 0);
    setState(() {

    });
  }

  Future<void> setIsMyFavorite() async {
    var nullVoid = await widget.videoRepository.videoSetMyFavorite(
        ['*'], widget.videoId, isFavorite ? 1 : 0, widget.userId,
        getNoSqlData: 0);
    setState(() {

    });
  }

  void sharevideo() {}

  Future<bool> updateButtonStatus() async {
    var videoLikeDataSet = await widget.appRepositories.tblVidVideoLike(
        'video/GetObject', ['id', 'quest_id', 'user_id', 'like_type'],
        video_id: widget.videoId, user_id: widget.userId);
    var vL =
        videoLikeDataSet.firstValue('data', 'like_type', insteadOfNull: 2);

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
        'video/GetObject', ['id', 'video_id', 'user_id'],
        video_id: widget.videoId, user_id: widget.userId);

    var qF = tblFavvideoDataSet.firstValue('data', 'video_id',
        insteadOfNull: 0);

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
                    tooltip: isLiked ? AppLocalization.instance.translate(
                        'lib.screen.common.videoOverView',
                        'build',
                        'unlike') : AppLocalization.instance.translate(
                        'lib.screen.common.videoOverView',
                        'build',
                        'like') ,
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
                    tooltip: isDisLiked ?  AppLocalization.instance.translate(
                        'lib.screen.common.videoOverView',
                        'build',
                        'removeDisLike')  :  AppLocalization.instance.translate(
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
                          'sharevideo'),
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
                          'sharevideo'),
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
          return Text('${AppLocalization.instance.translate(
              'lib.screen.common.videoOverView',
              'build',
              'error')}: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator(); // or any other loading indicator
        }
      },
    );
  }
}

class LikeCountWidget extends StatefulWidget {
  int likeCount = 0;
  AppRepositories appRepositories = AppRepositories();
  VideoRepository videoRepository = VideoRepository();
  final BigInt videoId;

  LikeCountWidget({Key? key, required this.videoId}) : super(key: key);

  @override
  _LikeCountWidgetState createState() => _LikeCountWidgetState();
}

class _LikeCountWidgetState extends State<LikeCountWidget> {
  Future<int> getTotalLikes() async {

    var getTotalLikesDataSet = await widget.videoRepository.videoTotalLikes(['*'], widget.videoId, getNoSqlData: 0);

    widget.likeCount = getTotalLikesDataSet.firstValue('data', 'like_count', insteadOfNull: 0);

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
                      Text('(${widget.likeCount} ${AppLocalization.instance.translate(
                          'lib.screen.common.videoOverView',
                          'build',
                          'likes')})'),
                    ],
                  ),
                ],
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${AppLocalization.instance.translate(
              'lib.screen.common.videoOverView',
              'build',
              'error')}: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator(); // or any other loading indicator
        }
      },
    );
  }
}
