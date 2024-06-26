import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/components/list/list_friend_request.component.dart';
import 'package:social_media_app/components/loading/shimmer_comment.component.dart';
import 'package:social_media_app/models/notifications.dart';
import 'package:social_media_app/models/users.dart';
import 'package:social_media_app/screens/home_main/home_screen/message_screen/chat_screen.dart';
import 'package:social_media_app/screens/home_main/home_screen/notifications_screen/list_friend_request_screen.dart';
import 'package:social_media_app/services/notifications/notifications.services.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/my_enum.dart';
import 'package:social_media_app/utils/navigate.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationServices _notificationServices = NotificationServices();
  final UserServices _userServices = UserServices();

  Future<void> _onNavigateToListFriendRequests() async {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const ListFriendRequestScreen(),
    //   ),
    // );
    navigateToScreenAnimationRightToLeft(
        context, const ListFriendRequestScreen());
    await _notificationServices.updateStatusNotificationTypeFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            child: StreamBuilder<List<Notifications>>(
              stream: _notificationServices.getNotificationsForFriendRequest(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ShimmerCommentComponent();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        'ERROR getNotificationsForFriendRequest: ---> ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  final List<Notifications> dataNotifications =
                      snapshot.data ?? [];
                  if (dataNotifications.isNotEmpty) {
                    final countFriendRequest = dataNotifications
                        .where((element) =>
                            element.notificationType ==
                            NotificationTypeEnum.friendRequest.name)
                        .toList();
                    final userFirst =
                        dataNotifications.first.notificationReferenceId;
                    final userLast =
                        dataNotifications.last.notificationReferenceId;
                    if (dataNotifications.isNotEmpty &&
                        countFriendRequest.length > 1) {
                      return FutureBuilder<List<Users?>>(
                        future: Future.wait([
                          _userServices.getUserDetailsByID(userFirst!),
                          _userServices.getUserDetailsByID(userLast!)
                        ]),
                        builder: (context, usersSnapshot) {
                          final dataUsers = usersSnapshot.data;
                          if (dataUsers != null) {
                            return GestureDetector(
                              onTap: _onNavigateToListFriendRequests,
                              child: ListTileFriendRequestComponent(
                                title: dataNotifications.first.notificationType,
                                subtitle:
                                    '${dataUsers.first?.username} + ${countFriendRequest.length > 2 ? '${countFriendRequest.length - 1} others' : '${countFriendRequest.length - 1} other'}',
                                listImages: [
                                  dataUsers.first?.imageProfile,
                                  dataUsers.last?.imageProfile,
                                ],
                                listTrailing: const [
                                  Icon(Icons.keyboard_arrow_right_rounded)
                                ],
                              ),
                            );
                          } else {
                            return const ShimmerCommentComponent();
                          }
                        },
                      );
                    } else if (countFriendRequest.isNotEmpty) {
                      return FutureBuilder<Users?>(
                        future: _userServices
                            .getUserDetailsByID(userLast ?? userFirst!),
                        builder: (context, usersSnapshot) {
                          final dataUsers = usersSnapshot.data;
                          if (dataUsers != null) {
                            return GestureDetector(
                              onTap: _onNavigateToListFriendRequests,
                              child: ListTileFriendRequestComponent(
                                title: dataNotifications.first.notificationType,
                                subtitle: dataUsers.username,
                                listImages: [
                                  dataUsers.imageProfile,
                                ],
                                listTrailing: const [
                                  Icon(Icons.keyboard_arrow_right_rounded)
                                ],
                              ),
                            );
                          } else {
                            return const ShimmerCommentComponent();
                          }
                        },
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
              },
            ),
          ),
          const Divider(height: 1.0),
          Flexible(
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: _notificationServices.getNotifications(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child:
                        Text('ERROR getNotifications: ---> ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  final List<Notifications> dataNotifications = snapshot.data!
                      .map((doc) => Notifications.fromMap(
                          doc.data() as Map<String, dynamic>))
                      .toList();
                  return ListView.builder(
                    itemCount: dataNotifications.length,
                    itemBuilder: (context, index) {
                      final notificationId = snapshot.data![index].id;
                      final notification = dataNotifications[index];
                      DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
                      String formattedDateTime = dateFormat.format(
                          notification.notificationCreatedDate!.toDate());
                      return VisibilityDetector(
                        key: Key(notificationId),
                        onVisibilityChanged: (visibilityInfo) {
                          var visiblePercentage =
                              visibilityInfo.visibleFraction * 100;
                          if (visiblePercentage == 100) {
                            _notificationServices
                                .markAsSeenNotifications(notificationId);
                          }
                        },
                        child: FutureBuilder(
                          future: _userServices.getUserDetailsByID(
                              notification.notificationReferenceId!),
                          builder: (context, userSnapshot) {
                            final dataUser = userSnapshot.data;
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const ShimmerCommentComponent();
                            }
                            if (notification.notificationType ==
                                NotificationTypeEnum.message.name) {
                              return GestureDetector(
                                onTap: () =>
                                    navigateToScreenAnimationRightToLeft(
                                  context,
                                  ChatScreen(
                                    recipientId:
                                        notification.notificationReferenceId!,
                                  ),
                                ),
                                child: ListTileFriendRequestComponent(
                                  title: notification.notificationType,
                                  subtitle:
                                      '${notification.notificationContent} $formattedDateTime',
                                  listImages: [
                                    dataUser?.imageProfile,
                                  ],
                                ),
                              );
                            } else {
                              return ListTileFriendRequestComponent(
                                title: notification.notificationType,
                                subtitle:
                                    '${notification.notificationContent} $formattedDateTime',
                                listImages: [
                                  dataUser?.imageProfile,
                                ],
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
