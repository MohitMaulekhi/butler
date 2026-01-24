import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class ProfileEndpoint extends Endpoint {
  /// Get the authenticated user's profile. Creates one if it doesn't exist.
  Future<UserProfile> getProfile(Session session) async {
    final userId = session.authenticated?.userIdentifier.toString();
    if (userId == null) throw Exception('User not authenticated');

    var profile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );

    if (profile == null) {
      profile = UserProfile(
        userId: userId,
        name: 'User', // Default name
      );
      await UserProfile.db.insertRow(session, profile);
    }

    return profile;
  }

  /// Update user profile fields.
  Future<UserProfile> updateProfile(
    Session session,
    UserProfile profile,
  ) async {
    final userId = session.authenticated?.userIdentifier.toString();
    if (userId == null) throw Exception('User not authenticated');

    if (profile.userId != userId) {
      throw Exception('Unauthorized profile update');
    }

    // Ensure we are updating the existing row
    final existing = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );

    if (existing == null) {
      // Should rely on getProfile to create, but we can handle it.
      await UserProfile.db.insertRow(session, profile);
      return profile;
    }

    // Copy ID from existing to ensure update works correctly on the row
    // (Though client should send the ID if it fetched it)
    // Safer to merge fields? No, client sends full object typically.
    // But we must preserve the ID of the row (not user ID, but table ID) if Serverpod uses it.
    // Serverpod objects created via constructor don't have 'id' set unless specified.
    // If 'profile' from client has 'id', we are good.

    // We trust client to send back the object it got from getProfile, which has the ID.
    // But we verify ownership above.

    // Fix: Client might send a fresh object without ID. We must ensure ID is set to existing row ID.
    profile.id = existing.id;

    await UserProfile.db.updateRow(session, profile);
    return profile;
  }
}
