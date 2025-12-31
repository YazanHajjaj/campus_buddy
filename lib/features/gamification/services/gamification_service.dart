import 'package:cloud_firestore/cloud_firestore.dart';

class GamificationService {
  final FirebaseFirestore _db;

  GamificationService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // ───────────────── REFERENCES ─────────────────

  DocumentReference<Map<String, dynamic>> _userRef(String uid) {
    return _db.collection('users').doc(uid);
  }

  CollectionReference<Map<String, dynamic>> get _xpLogs =>
      _db.collection('user_xp_logs');

  // ───────────────── PUBLIC API ─────────────────

  /// Awards XP ONCE per action (deduplicated by sourceType + sourceId)
  Future<void> addXp({
    required String uid,
    required int amount,
    required String sourceType, // e.g. "resource_upload"
    required String sourceId,   // e.g. resourceId / requestId
    String? reason,
  }) async {
    if (amount <= 0) return;

    // 1️⃣ Prevent duplicate XP grants
    final existing = await _xpLogs
        .where('uid', isEqualTo: uid)
        .where('sourceType', isEqualTo: sourceType)
        .where('sourceId', isEqualTo: sourceId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    final userRef = _userRef(uid);
    final xpLogRef = _xpLogs.doc();
    final now = Timestamp.now();

    await _db.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      if (!userSnap.exists) return;

      final data = userSnap.data() ?? {};

      final currentXp = _asInt(data['xp']);
      final currentBadges =
      List<String>.from((data['earnedBadges'] ?? const []) as List);

      final newXp = currentXp + amount;

      // 2️⃣ LEVEL CALCULATION
      final oldLevel = _levelForXp(currentXp);
      final newLevel = _levelForXp(newXp);
      final leveledUp = oldLevel != newLevel;

      // 3️⃣ BADGE UNLOCKING
      final unlockedBadges = _computeUnlockedBadges(newXp);
      final mergedBadges = <String>{
        ...currentBadges,
        ...unlockedBadges,
      }.toList();

      // 4️⃣ UPDATE USER DOC
      tx.set(
        userRef,
        {
          'xp': newXp,
          'level': newLevel,
          'earnedBadges': mergedBadges,
          'updatedAt': now,

          // 🔔 UI SIGNALS
          'justLeveledUp': leveledUp,
          'previousLevel': oldLevel,

          // Debug / audit
          'lastXpGain': amount,
          'lastXpReason': reason ?? sourceType,
          'lastXpAt': now,
        },
        SetOptions(merge: true),
      );

      // 5️⃣ XP LOG (DEDUP SOURCE)
      tx.set(xpLogRef, {
        'uid': uid,
        'sourceType': sourceType,
        'sourceId': sourceId,
        'amount': amount,
        'createdAt': now,
      });
    });
  }

  // ───────────────── STREAMS (UI SAFE) ─────────────────

  Stream<int> streamXp(String uid) {
    return _userRef(uid).snapshots().map((doc) {
      final data = doc.data() ?? {};
      return _asInt(data['xp']);
    });
  }

  Stream<String> streamLevel(String uid) {
    return _userRef(uid).snapshots().map((doc) {
      final data = doc.data() ?? {};
      return (data['level'] as String?) ?? 'Bronze';
    });
  }

  Stream<List<String>> streamEarnedBadges(String uid) {
    return _userRef(uid).snapshots().map((doc) {
      final data = doc.data() ?? {};
      return List<String>.from((data['earnedBadges'] ?? const []) as List);
    });
  }

  // ───────────────── BADGE RULES ─────────────────

  List<String> _computeUnlockedBadges(int xp) {
    final out = <String>[];

    if (xp >= 100) out.add('badge_bronze');
    if (xp >= 300) out.add('badge_silver');
    if (xp >= 600) out.add('badge_gold');

    return out;
  }

  // ───────────────── LEVEL RULES ─────────────────

  String _levelForXp(int xp) {
    if (xp >= 1200) return 'Platinum';
    if (xp >= 600) return 'Gold';
    if (xp >= 300) return 'Silver';
    return 'Bronze';
  }

  // ───────────────── HELPERS ─────────────────

  int _asInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return fallback;
  }
}