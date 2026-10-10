import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../models/chat_conversation.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get or create a conversation between two users
  Future<String> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
    String currentUserName,
    String otherUserName,
  ) async {
    try {
      // Create a consistent conversation ID by sorting user IDs
      List<String> sortedIds = [currentUserId, otherUserId]..sort();
      String conversationId = '${sortedIds[0]}_${sortedIds[1]}';

      DocumentSnapshot conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!conversationDoc.exists) {
        // Create new conversation
        await _firestore.collection('conversations').doc(conversationId).set({
          'participantIds': [currentUserId, otherUserId],
          'participantNames': {
            currentUserId: currentUserName,
            otherUserId: otherUserName,
          },
          'lastMessage': '',
          'lastMessageSenderId': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': {currentUserId: 0, otherUserId: 0},
        });
      }

      return conversationId;
    } catch (e) {
      throw 'Error creating conversation: $e';
    }
  }

  // Send a message
  Future<void> sendMessage(
    String conversationId,
    String senderId,
    String senderName,
    String text,
    String receiverId,
  ) async {
    try {
      // Add message to messages collection
      await _firestore.collection('messages').add({
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Update conversation with last message and increment unread count
      DocumentSnapshot conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (conversationDoc.exists) {
        Map<String, dynamic> conversationData =
            conversationDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> unreadCount = Map<String, dynamic>.from(
          conversationData['unreadCount'] ?? {},
        );

        // Increment unread count for receiver
        unreadCount[receiverId] = (unreadCount[receiverId] ?? 0) + 1;

        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .update({
              'lastMessage': text,
              'lastMessageSenderId': senderId,
              'lastMessageTime': FieldValue.serverTimestamp(),
              'unreadCount': unreadCount,
            });
      }
    } catch (e) {
      throw 'Error sending message: $e';
    }
  }

  // Get messages stream for a conversation
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList();
        });
  }

  // Get conversations stream for a user
  Stream<List<ChatConversation>> getConversationsStream(String userId) {
    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatConversation.fromFirestore(doc))
              .toList();
        });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      // Get all unread messages in the conversation sent by the other user
      QuerySnapshot unreadMessages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId)
          .get();

      // Update all unread messages
      WriteBatch batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Reset unread count for this user in the conversation
      await _firestore.collection('conversations').doc(conversationId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Get all users except current user
  Stream<List<Map<String, dynamic>>> getUsersStream(String currentUserId) {
    return _firestore
        .collection('users')
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['uid'] = doc.id;
            return data;
          }).toList();
        });
  }

  // Delete a conversation and all its messages
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete all messages in the conversation
      QuerySnapshot messages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Delete the conversation
      await _firestore.collection('conversations').doc(conversationId).delete();
    } catch (e) {
      throw 'Error deleting conversation: $e';
    }
  }
}
