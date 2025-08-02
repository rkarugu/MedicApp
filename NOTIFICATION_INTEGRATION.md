# Notification System Integration Guide

## Overview
The backend notification system is now fully functional. This guide explains how to integrate notifications into the Flutter frontend.

## Backend Status ✅
- **API Endpoints**: All working correctly
- **Authentication**: Using Sanctum tokens
- **Database**: Notifications are being stored and delivered
- **Routes**:
  - `GET /api/worker/notifications` - List notifications
  - `GET /api/worker/notifications/unread-count` - Get unread count
  - `PATCH /api/worker/notifications/{id}/read` - Mark as read
  - `PATCH /api/worker/notifications/mark-all-read` - Mark all as read
  - `DELETE /api/worker/notifications/{id}` - Delete notification

## Frontend Implementation Steps

### 1. Generate Code
Run the following commands to generate the necessary code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Setup Notification Service
Add to your dependency injection or service locator:

```dart
// In your service setup
final dio = Dio();
dio.options.headers['Authorization'] = 'Bearer YOUR_TOKEN_HERE';
final api = MediconnectApi(dio, baseUrl: 'http://127.0.0.1:8000');
final notificationService = NotificationService(api);
```

### 3. Add Provider to Main App
```dart
// In your main.dart or provider setup
ChangeNotifierProvider(
  create: (context) => NotificationProvider(notificationService),
  child: YourApp(),
)
```

### 4. Implement Notification UI
Create a notifications screen:

```dart
// Example usage in a widget
class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Notifications'),
            actions: [
              IconButton(
                icon: Icon(Icons.mark_email_read),
                onPressed: () => provider.markAllAsRead(),
              ),
            ],
          ),
          body: provider.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: provider.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = provider.notifications[index];
                    return ListTile(
                      title: Text(notification.title),
                      subtitle: Text(notification.message),
                      trailing: !notification.isRead
                          ? Icon(Icons.circle, color: Colors.blue, size: 12)
                          : null,
                      onTap: () => provider.markAsRead(notification.id),
                    );
                  },
                ),
        );
      },
    );
  }
}
```

### 5. Add Notification Badge
```dart
// Example for showing unread count
class NotificationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Badge(
          label: Text(provider.unreadCount.toString()),
          child: IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationsScreen()),
              );
            },
          ),
        );
      },
    );
  }
}
```

### 6. Initialize Notifications
In your main dashboard or home screen:

```dart
@override
void initState() {
  super.initState();
  // Load notifications when app starts
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.refreshNotifications();
    
    // Set up periodic refresh (optional)
    Timer.periodic(Duration(minutes: 5), (_) {
      provider.loadUnreadCount();
    });
  });
}
```

## Testing
1. Create a new shift in the backend
2. Check if notifications appear in the Flutter app
3. Verify unread count updates correctly
4. Test marking notifications as read

## Error Handling
The notification system includes comprehensive error handling:
- Network errors are caught and logged
- Authentication failures return 401
- All API endpoints return consistent JSON responses
- Frontend handles errors gracefully with user feedback

## Next Steps
1. Run the code generation command
2. Implement the UI components
3. Test the full notification flow
4. Add real-time updates (optional with WebSockets or polling)
