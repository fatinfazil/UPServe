# Chat Feature - Quick Start Guide

## What's New

The app has been refactored to include a complete user-to-user chat feature with Firebase Firestore integration. The AI chatbot page has been replaced with a real-time messaging system.

## New Files Created

### Models
- `lib/models/chat_message.dart` - Message data model
- `lib/models/chat_conversation.dart` - Conversation data model

### Services
- `lib/services/chat_service.dart` - Firestore operations for chat

### Pages
- `lib/screens/chat_page.dart` - One-on-one chat interface (refactored from message_page.dart)
- `lib/screens/conversation_list_page.dart` - List of all conversations
- `lib/screens/user_list_page.dart` - List of users to start chatting with

## Getting Started

### 1. Run the app
```bash
flutter pub get
flutter run
```

### 2. Navigate to Chat Feature

Add navigation to your app (e.g., from home page or navigation drawer):

```dart
import 'package:upserve_flutter/screens/conversation_list_page.dart';

// In your navigation code:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ConversationListPage(),
  ),
);
```

### 3. How to Use

1. **View Conversations**: The `ConversationListPage` shows all your active chats
2. **Start New Chat**: Tap the + button to see all available users
3. **Select User**: Choose a user from the list to start or continue a chat
4. **Send Messages**: Type and send messages in real-time
5. **Track Unread**: See unread message counts on the conversation list

## Features Overview

### ✅ Real-time messaging
- Messages appear instantly using Firestore streams
- No refresh needed

### ✅ Conversation management
- List of all conversations sorted by most recent
- Unread message counts
- Last message preview

### ✅ User selection
- Search for users by name or email
- Start new conversations easily

### ✅ Message status
- See when messages are delivered (single check)
- See when messages are read (double check)

### ✅ Clean UI
- Material Design 3
- Consistent color scheme
- Smooth animations
- Empty state messages

## Firestore Setup (Important!)

The chat feature requires proper Firestore security rules. Add these to your Firebase Console:

1. Go to Firebase Console → Firestore Database → Rules
2. Add the following rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read all user profiles
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Users can only access conversations they're part of
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null &&
        request.auth.uid in resource.data.participantIds;
    }

    // Users can access messages in their conversations
    match /messages/{messageId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null &&
        request.auth.uid == request.resource.data.senderId;
      allow update: if request.auth != null;
    }
  }
}
```

3. Click "Publish"

## Integration Examples

### Add to Bottom Navigation
```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
  onTap: (index) {
    if (index == 1) {
      Navigator.push(context,
        MaterialPageRoute(builder: (_) => ConversationListPage()));
    }
  },
)
```

### Add to Drawer
```dart
ListTile(
  leading: Icon(Icons.chat),
  title: Text('Messages'),
  onTap: () {
    Navigator.push(context,
      MaterialPageRoute(builder: (_) => ConversationListPage()));
  },
)
```

### Add to App Bar
```dart
AppBar(
  actions: [
    IconButton(
      icon: Icon(Icons.chat),
      onPressed: () {
        Navigator.push(context,
          MaterialPageRoute(builder: (_) => ConversationListPage()));
      },
    ),
  ],
)
```

## Testing the Feature

1. **Create Test Users**:
   - Sign up with 2+ different accounts
   - Log in with each account on different devices/emulators

2. **Start a Conversation**:
   - User A: Tap + button, select User B, send a message
   - User B: See the conversation appear, receive the message

3. **Test Real-time Updates**:
   - Send messages from both accounts
   - Observe instant delivery
   - Check read receipts

4. **Test Unread Counts**:
   - Send messages while other user is not in chat
   - Check unread badge appears
   - Open chat and see unread count reset

## Troubleshooting

### Messages not appearing
- Check Firebase Console for data in `messages` collection
- Verify Firestore rules are published
- Ensure user is authenticated

### Errors on send
- Check internet connection
- Verify Firebase configuration
- Look at console logs for error details

### Real-time updates not working
- Ensure using StreamBuilder correctly
- Check Firestore security rules
- Verify Firebase project is set up correctly

## Next Steps

Consider adding:
- Push notifications for new messages
- Image/file attachments
- Group chats
- Typing indicators
- Message reactions
- Voice messages

See `CHAT_FEATURE_README.md` for detailed documentation.
