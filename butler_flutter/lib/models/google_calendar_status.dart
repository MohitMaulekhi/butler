class GoogleCalendarStatus {
  final bool isConnected;
  final String? googleEmail;
  final DateTime? connectedAt;
  final DateTime? lastSyncAt;

  GoogleCalendarStatus({
    required this.isConnected,
    this.googleEmail,
    this.connectedAt,
    this.lastSyncAt,
  });

  factory GoogleCalendarStatus.fromMap(Map<String, dynamic> map) {
    return GoogleCalendarStatus(
      isConnected: map['isConnected'] as bool? ?? false,
      googleEmail: map['googleEmail'] as String?,
      connectedAt: map['connectedAt'] != null
          ? DateTime.parse(map['connectedAt'] as String)
          : null,
      lastSyncAt: map['lastSyncAt'] != null
          ? DateTime.parse(map['lastSyncAt'] as String)
          : null,
    );
  }

  bool get hasNeverSynced => lastSyncAt == null;

  String get formattedConnectedTime {
    if (connectedAt == null) return 'Unknown';
    return _formatDateTime(connectedAt!);
  }

  String get formattedLastSync {
    if (lastSyncAt == null) return 'Never';
    return _formatDateTime(lastSyncAt!);
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      }
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}
