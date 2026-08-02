import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/models.dart';
import 'fake_database.dart';
import 'providers.dart';
import 'repositories.dart';

/// Personal wardrobe dresses for the logged-in individual owner.
final individualOwnerDressesProvider = Provider<List<Dress>>((ref) {
  ref.watch(databaseProvider);
  final user = ref.watch(authProvider).user;
  if (user == null || !user.isIndividualOwner) return [];
  return FakeDatabase.instance.dresses
      .where((d) => d.ownerId == user.id && d.storeId == null)
      .toList()
    ..sort(
      (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
        a.createdAt ?? DateTime(2000),
      ),
    );
});

final individualOwnerBookingsProvider = Provider<List<Booking>>((ref) {
  ref.watch(databaseProvider);
  final dresses = ref.watch(individualOwnerDressesProvider);
  final ids = dresses.map((d) => d.id).toSet();
  return FakeDatabase.instance.bookings
      .where((b) => ids.contains(b.dressId))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final individualOwnerTransactionsProvider = Provider<List<AppTransaction>>((
  ref,
) {
  ref.watch(databaseProvider);
  final bookings = ref.watch(individualOwnerBookingsProvider);
  final ids = bookings.map((b) => b.id).toSet();
  return FakeDatabase.instance.transactions
      .where((t) => ids.contains(t.bookingId))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

class OwnerStatistics {
  const OwnerStatistics({
    this.dressCount = 0,
    this.activeRentals = 0,
    this.pendingRequests = 0,
    this.completedRentals = 0,
    this.totalEarnings = 0,
    this.pendingEarnings = 0,
    this.pendingReviewCount = 0,
  });

  final int dressCount;
  final int activeRentals;
  final int pendingRequests;
  final int completedRentals;
  final double totalEarnings;
  final double pendingEarnings;
  final int pendingReviewCount;
}

final ownerStatisticsProvider = Provider<OwnerStatistics>((ref) {
  final dresses = ref.watch(individualOwnerDressesProvider);
  final bookings = ref.watch(individualOwnerBookingsProvider);
  final txs = ref.watch(individualOwnerTransactionsProvider);

  final active = bookings
      .where(
        (b) =>
            b.status == BookingStatus.accepted ||
            b.status == BookingStatus.preparing ||
            b.status == BookingStatus.delivered,
      )
      .length;

  final pending = bookings.where((b) => b.status == BookingStatus.pending).length;

  final completed = bookings
      .where(
        (b) =>
            b.status == BookingStatus.returned ||
            b.status == BookingStatus.completed,
      )
      .length;

  final earnedStatuses = {
    BookingStatus.accepted,
    BookingStatus.preparing,
    BookingStatus.delivered,
    BookingStatus.returned,
    BookingStatus.completed,
  };

  final totalEarnings = bookings
      .where((b) => earnedStatuses.contains(b.status))
      .fold<double>(0, (s, b) => s + b.totalPrice);

  final pendingEarnings = txs
      .where((t) => t.status == TransactionStatus.pending)
      .fold<double>(0, (s, t) => s + t.amount);

  return OwnerStatistics(
    dressCount: dresses.where((d) => d.status != DressStatus.archived).length,
    activeRentals: active,
    pendingRequests: pending,
    completedRentals: completed,
    totalEarnings: totalEarnings,
    pendingEarnings: pendingEarnings,
    pendingReviewCount:
        dresses.where((d) => d.status == DressStatus.pending).length,
  );
});

// ─── Notifiers ────────────────────────────────────────────

class OwnerDressNotifier extends Notifier<List<Dress>> {
  @override
  List<Dress> build() => ref.watch(individualOwnerDressesProvider);

  DressRepository get _repo => ref.read(dressRepositoryProvider);

  Future<Dress> addDress(Dress dress) async {
    final user = ref.read(authProvider).user;
    if (user == null || !user.isIndividualOwner) {
      throw Exception('Owner account required');
    }
    return _repo.create(
      dress.copyWith(ownerId: user.id, storeId: null),
    );
  }

  Future<Dress> updateDress(Dress dress) => _repo.update(dress);

  Future<void> deleteDress(String id) => _repo.delete(id);

  Future<void> archiveDress(String id) => _repo.archive(id);

  Future<void> setAvailability(String id, bool available) async {
    final dress = FakeDatabase.instance.dresses.cast<Dress?>().firstWhere(
      (d) => d!.id == id,
      orElse: () => null,
    );
    if (dress == null) return;
    if (dress.status == DressStatus.pending ||
        dress.status == DressStatus.rejected) {
      return;
    }
    await _repo.update(
      dress.copyWith(
        status: available ? DressStatus.available : DressStatus.archived,
      ),
    );
  }

  /// Prototype: simulate platform review approval.
  Future<void> simulateApprove(String id) => _repo.approve(id);

  /// Prototype: simulate platform rejection.
  Future<void> simulateReject(String id) => _repo.reject(id);
}

final ownerDressNotifierProvider =
    NotifierProvider<OwnerDressNotifier, List<Dress>>(OwnerDressNotifier.new);

class OwnerBookingNotifier extends Notifier<List<Booking>> {
  @override
  List<Booking> build() => ref.watch(individualOwnerBookingsProvider);

  BookingRepository get _repo => ref.read(bookingRepositoryProvider);

  Future<void> accept(String bookingId) =>
      _repo.updateStatus(bookingId, BookingStatus.accepted);

  Future<void> reject(String bookingId) =>
      _repo.updateStatus(bookingId, BookingStatus.rejected);

  Future<void> markReturned(String bookingId) =>
      _repo.updateStatus(bookingId, BookingStatus.returned);
}

final ownerBookingNotifierProvider =
    NotifierProvider<OwnerBookingNotifier, List<Booking>>(
      OwnerBookingNotifier.new,
    );
