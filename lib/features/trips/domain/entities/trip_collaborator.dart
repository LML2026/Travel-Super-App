enum TripCollaboratorRole {
  owner,
  editor,
  viewer,
}

enum TripCollaboratorStatus {
  invited,
  active,
}

class TripCollaborator {
  const TripCollaborator({
    required this.id,
    required this.tripId,
    required this.email,
    required this.role,
    required this.status,
    this.userId,
    this.displayName,
    this.invitedBy,
    this.invitedAt,
    this.updatedAt,
  });

  final String id;
  final String tripId;
  final String email;
  final TripCollaboratorRole role;
  final TripCollaboratorStatus status;
  final String? userId;
  final String? displayName;
  final String? invitedBy;
  final DateTime? invitedAt;
  final DateTime? updatedAt;

  bool get canEdit =>
      role == TripCollaboratorRole.owner || role == TripCollaboratorRole.editor;

  TripCollaborator copyWith({
    String? id,
    String? tripId,
    String? email,
    TripCollaboratorRole? role,
    TripCollaboratorStatus? status,
    String? userId,
    String? displayName,
    String? invitedBy,
    DateTime? invitedAt,
    DateTime? updatedAt,
  }) {
    return TripCollaborator(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      invitedBy: invitedBy ?? this.invitedBy,
      invitedAt: invitedAt ?? this.invitedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
