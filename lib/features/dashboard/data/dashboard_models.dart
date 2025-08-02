class Shift {
  final int id;
  final String title;
  final String facility;
  final String location;
  final String startTime;
  final String endTime;
  final double payRate;
  final String status;
  final double durationHrs;
  final double expectedPay;
  final int? earnings;
  final String? applicationStatus;

  Shift({
    required this.id,
    required this.title,
    required this.facility,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.payRate,
    required this.status,
    required this.durationHrs,
    required this.expectedPay,
    this.earnings,
    this.applicationStatus,
  });

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    facility: json['facility'] ?? '',
    location: json['location'] ?? '',
    startTime: json['startTime'] ?? '',
    endTime: json['endTime'] ?? '',
    payRate: (json['payRate'] ?? 0).toDouble(),
    status: json['status'] ?? '',
    durationHrs: (json['durationHrs'] as num?)?.toDouble() ?? 0.0,
    expectedPay: (json['expectedPay'] ?? 0).toDouble(),
    earnings: json['earnings'],
    applicationStatus: json['applicationStatus'],
  );
}

class InstantRequest {
  final int requestId;
  final String facility;
  final String shiftTime;
  final String expiresAt;
  final String status;

  InstantRequest({
    required this.requestId,
    required this.facility,
    required this.shiftTime,
    required this.expiresAt,
    required this.status,
  });

  factory InstantRequest.fromJson(Map<String, dynamic> json) => InstantRequest(
    requestId: json['requestId'] ?? 0,
    facility: json['facility'] ?? '',
    shiftTime: json['shiftTime'] ?? '',
    expiresAt: json['expiresAt'] ?? '',
    status: json['status'] ?? '',
  );
}

class BidInvitation {
  final int invitationId;
  final String facility;
  final String shiftTime;
  final int minimumBid;
  final String status;
  final String title;

  BidInvitation({
    required this.invitationId,
    required this.facility,
    required this.shiftTime,
    required this.minimumBid,
    required this.status,
    required this.title,
  });

  factory BidInvitation.fromJson(Map<String, dynamic> json) => BidInvitation(
    invitationId: json['invitationId'] ?? 0,
    facility: json['facility'] ?? '',
    shiftTime: json['shiftTime'] ?? '',
    minimumBid: json['minimumBid'] ?? 0,
    status: json['status'] ?? '',
    title: json['title'] ?? '',
  );
}

class DashboardData {
  final List<Shift> upcomingShifts;
  final List<InstantRequest> instantRequests;
  final List<BidInvitation> bidInvitations;
  final List<Shift> shiftHistory;

  DashboardData({
    required this.upcomingShifts,
    required this.instantRequests,
    required this.bidInvitations,
    required this.shiftHistory,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    upcomingShifts: (json['upcoming_shifts'] as List<dynamic>?)?.map((e) => Shift.fromJson(e)).toList() ?? [],
    instantRequests: (json['instant_requests'] as List<dynamic>?)?.map((e) => InstantRequest.fromJson(e)).toList() ?? [],
    bidInvitations: (json['bidInvitations'] as List<dynamic>?)?.map((e) => BidInvitation.fromJson(e)).toList() ?? [],
    shiftHistory: (json['shift_history'] as List<dynamic>?)?.map((e) => Shift.fromJson(e)).toList() ?? [],
  );
}
