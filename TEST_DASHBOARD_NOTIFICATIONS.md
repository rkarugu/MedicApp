# 🎯 Dashboard Bid Invitation Notifications - Test Guide

## ✅ Integration Complete

The notification system is now integrated into the dashboard's **bid invitations** section.

## 🔧 How It Works

1. **When you create a shift** → Backend creates notifications
2. **Dashboard loads** → Notifications appear as **bid invitations**
3. **Bid invitation count** shows unread notifications
4. **Tap bid invitation** → Opens shift details

## 📱 What You'll See

**Dashboard will display:**
- **Bid Invitations card** with count = unread notifications
- **New shift notifications** appear as bid invitations
- **Real-time updates** when new shifts are posted

## ✅ Test Steps

1. **Create a locum shift** (via web or API)
2. **Refresh dashboard** in Flutter app
3. **Check bid invitations count** - should increase
4. **Tap bid invitation** - should show shift details

## 🔍 Debug Commands

**Check notifications in database:**
```bash
php artisan tinker --execute="\DB::table('notifications')->where('type', 'like', '%NewShiftAvailable%')->orderBy('created_at', 'desc')->get()->each(function(\$n) { echo \$n->id . ' - ' . \$n->notifiable_id . ' - ' . \$n->created_at . '\n'; });"
```

**Check API response:**
```bash
curl -X GET http://127.0.0.1:8000/api/worker/notifications \
  -H "Authorization: Bearer YOUR_WORKER_TOKEN"
```

## 🎯 Expected Result

After creating a shift, the **bid invitations** card on the dashboard should show an increased count, and new bid invitations should appear representing the new shift notifications.
