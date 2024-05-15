import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/notifications.dart';
import 'package:social_media_app/services/users/user.services.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';
import 'package:social_media_app/utils/my_enum.dart';

class NotificationServices {
  final UserServices _userServices = UserServices();
  final _notificationsCollection = FirebaseFirestore.instance
      .collection(FirestoreCollectionNames.notifications);
  final _currentUser = FirebaseAuth.instance.currentUser;
  Future<void> sendNotificationFriendRequest(String receiverId) async {
    Notifications notification = Notifications(
      uid: receiverId,
      notificationType: NotificationTypeEnum.friendRequest.getString,
      notificationReferenceId: _currentUser!.uid,
      notificationContent: 'You have received a friend request.',
      notificationCreatedDate: Timestamp.now(),
      notificationStatus: false,
    );
    await _notificationsCollection.add(notification.asMap());
  }

  Query _getNotificationQuery({
    required String uid,
    required String referenceId,
    required String type,
  }) {
    return _notificationsCollection
        .where(DocumentFieldNames.uid, isEqualTo: uid)
        .where(DocumentFieldNames.notificationReferenceId,
            isEqualTo: referenceId)
        .where(DocumentFieldNames.notificationType, isEqualTo: type);
  }

  Future<void> cancelNotificationFriendRequest(String receiverId) async {
    try {
      QuerySnapshot querySnapshot = await _getNotificationQuery(
        uid: receiverId,
        referenceId: _currentUser!.uid,
        type: NotificationTypeEnum.friendRequest.getString,
      ).get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (error) {
      //ignore:avoid_print
      print("cancelNotificationFriendRequest ERROR ---> $error");
    }
  }

  Future<void> deleteNotificationFriendRequest(String senderId) async {
    try {
      QuerySnapshot querySnapshot = await _getNotificationQuery(
        uid: _currentUser!.uid,
        referenceId: senderId,
        type: NotificationTypeEnum.friendRequest.getString,
      ).get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (error) {
      //ignore:avoid_print
      print("deleteNotificationFriendRequest ERROR ---> $error");
    }
  }

  Future<void> acceptNotificationFriendRequest(String senderId) async {
    try {
      QuerySnapshot querySnapshot = await _getNotificationQuery(
        uid: _currentUser!.uid,
        referenceId: senderId,
        type: NotificationTypeEnum.friendRequest.getString,
      ).get();
      for (var doc in querySnapshot.docs) {
        String docId = doc.id;
        final user = await _userServices.getUserDetailsByID(_currentUser.uid);
        await updateNotification(docId, user!.username!, senderId);
      }
    } catch (error) {
      //ignore:avoid_print
      print("acceptNotificationFriendRequest ERROR ---> $error");
    }
  }

  Future<void> updateNotification(
      String docId, String username, String receiverId) async {
    final Notifications notification = Notifications(
      uid: receiverId,
      notificationReferenceId: _currentUser!.uid,
      notificationContent: '$username has accepted your friend request',
      notificationCreatedDate: Timestamp.now(),
      notificationType: NotificationTypeEnum.acceptFriend.getString,
      notificationStatus: false,
    );
    await _notificationsCollection.doc(docId).update(notification.asMap());
  }

  Stream<List<Notifications>> getNotificationsForFriendRequest() {
    return _notificationsCollection
        .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
        .where(DocumentFieldNames.notificationType,
            isEqualTo: NotificationTypeEnum.friendRequest.getString)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notifications.fromMap(doc.data()))
            .toList());
  }

  Stream<QuerySnapshot> getNotifications() {
    return _notificationsCollection
        .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
        .where(DocumentFieldNames.notificationType,
            isNotEqualTo: NotificationTypeEnum.friendRequest.getString)
        .orderBy(DocumentFieldNames.notificationCreatedDate, descending: true)
        .snapshots();
  }

  Stream<bool> checkNotifications() {
    return _notificationsCollection
        .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
        .where(DocumentFieldNames.notificationStatus, isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Future<void> updateStatusNotificationTypeFriendRequests() async {
    try {
      QuerySnapshot querySnapshot = await _notificationsCollection
          .where(DocumentFieldNames.uid, isEqualTo: _currentUser!.uid)
          .where(DocumentFieldNames.notificationType,
              isEqualTo: NotificationTypeEnum.friendRequest.getString)
          .where(DocumentFieldNames.notificationStatus, isEqualTo: false)
          .get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          DocumentFieldNames.notificationStatus: true,
        });
      }
    } catch (error) {
      //ignore:avoid_print
      print("updateStatusNotification ERROR ---> $error");
    }
  }

  Future<void> sendNotificationTypeComment(
      String username, String uidOfPost) async {
    final Notifications notification = Notifications(
      uid: uidOfPost,
      notificationType: NotificationTypeEnum.comment.getString,
      notificationReferenceId: _currentUser!.uid,
      notificationContent: '$username commented on your post.',
      notificationCreatedDate: Timestamp.now(),
      notificationStatus: false,
    );
    await _notificationsCollection.add(notification.asMap());
  }

  Future<void> markAsSeenNotifications(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      DocumentFieldNames.notificationStatus: true,
    });
  }
}