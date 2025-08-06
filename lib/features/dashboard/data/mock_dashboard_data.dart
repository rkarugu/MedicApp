class MockDashboardData {
  static const upcomingShifts = [
    {
      'title': 'Night Shift',
      'facility': 'Sunrise Hospital',
      'startTime': '2025-06-19 19:00',
      'endTime': '2025-06-20 07:00',
      'status': 'confirmed',
    },
    {
      'title': 'Day Shift',
      'facility': 'Green Valley Clinic',
      'startTime': '2025-06-21 08:00',
      'endTime': '2025-06-21 16:00',
      'status': 'confirmed',
    },
  ];

  static const instantRequests = [
    {
      'requestId': 101,
      'facility': 'City Medical Center',
      'shiftTime': '2025-06-18 18:00',
      'expiresAt': '2025-06-18 17:30',
      'status': 'pending',
    }
  ];

  static const bidInvitations = [
    {
      'invitationId': '501',
      'facility': 'Hope Hospital',
      'shiftTime': '2025-06-22 09:00',
      'minimumBid': 2500,
      'status': 'open',
    }
  ];

  static const shiftHistory = [
    {
      'title': 'Morning Shift',
      'facility': 'Sunrise Hospital',
      'startTime': '2025-06-10 08:00',
      'endTime': '2025-06-10 16:00',
      'earnings': 2000,
      'status': 'completed',
    }
  ];
}
