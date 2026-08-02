import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/models.dart';
import 'fake_database.dart';
import 'providers.dart';
import 'repositories.dart';

// ─── Store-scoped data ────────────────────────────────────

final currentStoreProvider = Provider<Store?>((ref) {
  ref.watch(databaseProvider);
  final user = ref.watch(authProvider).user;
  if (user == null || user.storeId == null) return null;
  return FakeDatabase.instance.stores.cast<Store?>().firstWhere(
    (s) => s!.id == user.storeId,
    orElse: () => null,
  );
});

final storeDressesProvider = Provider<List<Dress>>((ref) {
  ref.watch(databaseProvider);
  final store = ref.watch(currentStoreProvider);
  if (store == null) return [];
  return FakeDatabase.instance.dresses
      .where((d) => d.storeId == store.id)
      .toList()
    ..sort(
      (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
        a.createdAt ?? DateTime(2000),
      ),
    );
});

final storeBookingsProvider = Provider<List<Booking>>((ref) {
  ref.watch(databaseProvider);
  final store = ref.watch(currentStoreProvider);
  if (store == null) return [];
  final dressIds = FakeDatabase.instance.dresses
      .where((d) => d.storeId == store.id)
      .map((d) => d.id)
      .toSet();
  return FakeDatabase.instance.bookings
      .where((b) => dressIds.contains(b.dressId))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final storeTransactionsProvider = Provider<List<AppTransaction>>((ref) {
  ref.watch(databaseProvider);
  final bookings = ref.watch(storeBookingsProvider);
  final bookingIds = bookings.map((b) => b.id).toSet();
  return FakeDatabase.instance.transactions
      .where((t) => bookingIds.contains(t.bookingId))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

class StoreDashboardStats {
  const StoreDashboardStats({
    this.totalDresses = 0,
    this.activeRentals = 0,
    this.pendingBookings = 0,
    this.monthlyRevenue = 0,
    this.totalRevenue = 0,
    this.completedRentals = 0,
    this.averageRating = 0,
    this.pendingPayments = 0,
    this.completedTransactions = 0,
  });

  final int totalDresses;
  final int activeRentals;
  final int pendingBookings;
  final double monthlyRevenue;
  final double totalRevenue;
  final int completedRentals;
  final double averageRating;
  final double pendingPayments;
  final int completedTransactions;
}

final storeStatsProvider = Provider<StoreDashboardStats>((ref) {
  final dresses = ref.watch(storeDressesProvider);
  final bookings = ref.watch(storeBookingsProvider);
  final txs = ref.watch(storeTransactionsProvider);
  final now = DateTime.now();

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

  final paidStatuses = {
    BookingStatus.accepted,
    BookingStatus.preparing,
    BookingStatus.delivered,
    BookingStatus.returned,
    BookingStatus.completed,
  };

  final totalRevenue = bookings
      .where((b) => paidStatuses.contains(b.status))
      .fold<double>(0, (s, b) => s + b.totalPrice);

  final monthlyRevenue = bookings
      .where(
        (b) =>
            paidStatuses.contains(b.status) &&
            b.createdAt.year == now.year &&
            b.createdAt.month == now.month,
      )
      .fold<double>(0, (s, b) => s + b.totalPrice);

  final avgRating = dresses.isEmpty
      ? 0.0
      : dresses.fold<double>(0, (s, d) => s + d.rating) / dresses.length;

  final pendingPayments = txs
      .where((t) => t.status == TransactionStatus.pending)
      .fold<double>(0, (s, t) => s + t.amount);

  final completedTx = txs
      .where((t) => t.status == TransactionStatus.completed)
      .length;

  return StoreDashboardStats(
    totalDresses: dresses.where((d) => d.status != DressStatus.archived).length,
    activeRentals: active,
    pendingBookings: pending,
    monthlyRevenue: monthlyRevenue,
    totalRevenue: totalRevenue,
    completedRentals: completed,
    averageRating: avgRating,
    pendingPayments: pendingPayments,
    completedTransactions: completedTx,
  );
});

class StoreAnalytics {
  const StoreAnalytics({
    this.mostRented,
    this.totalRentals = 0,
    this.monthlyBars = const [],
    this.categoryCounts = const {},
    this.averageRating = 0,
  });

  final Dress? mostRented;
  final int totalRentals;
  final List<double> monthlyBars;
  final Map<DressCategory, int> categoryCounts;
  final double averageRating;
}

final storeAnalyticsProvider = Provider<StoreAnalytics>((ref) {
  final dresses = ref.watch(storeDressesProvider);
  final bookings = ref.watch(storeBookingsProvider);
  final stats = ref.watch(storeStatsProvider);

  Dress? most;
  for (final d in dresses) {
    if (most == null || d.rentalCount > most.rentalCount) most = d;
  }

  final now = DateTime.now();
  final bars = List<double>.generate(6, (i) {
    final month = DateTime(now.year, now.month - (5 - i), 1);
    return bookings
        .where(
          (b) =>
              b.createdAt.year == month.year &&
              b.createdAt.month == month.month &&
              (b.status == BookingStatus.accepted ||
                  b.status == BookingStatus.returned ||
                  b.status == BookingStatus.completed ||
                  b.status == BookingStatus.delivered ||
                  b.status == BookingStatus.preparing),
        )
        .fold<double>(0, (s, b) => s + b.totalPrice);
  });

  // Ensure chart has visible data for demo
  final hasData = bars.any((v) => v > 0);
  final displayBars = hasData
      ? bars
      : <double>[12000, 18000, 9000, 22000, 15000, stats.monthlyRevenue];

  final cats = <DressCategory, int>{};
  for (final d in dresses) {
    cats[d.category] = (cats[d.category] ?? 0) + d.rentalCount;
  }

  return StoreAnalytics(
    mostRented: most,
    totalRentals: dresses.fold(0, (s, d) => s + d.rentalCount),
    monthlyBars: displayBars,
    categoryCounts: cats,
    averageRating: stats.averageRating,
  );
});

// ─── StoreNotifier ────────────────────────────────────────

class StoreNotifier extends Notifier<Store?> {
  @override
  Store? build() {
    return ref.watch(currentStoreProvider);
  }

  StoreRepository get _stores => ref.read(storeRepositoryProvider);
  DressRepository get _dresses => ref.read(dressRepositoryProvider);
  BookingRepository get _bookings => ref.read(bookingRepositoryProvider);

  Future<void> updateStore(Store store) async {
    await _stores.update(store);
  }

  Future<void> changeSubscription(SubscriptionPlan plan) async {
    final store = state;
    if (store == null) return;
    final now = DateTime.now();
    final expires = plan == SubscriptionPlan.yearly
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));
    await _stores.update(
      store.copyWith(
        subscriptionPlan: plan,
        subscriptionStatus: SubscriptionStatus.active,
        subscriptionStartedAt: now,
        subscriptionExpiresAt: expires,
      ),
    );
  }

  Future<Dress> addDress(Dress dress) async {
    final store = state;
    final user = ref.read(authProvider).user;
    if (store == null || user == null) {
      throw Exception('Store not found');
    }
    return _dresses.create(
      dress.copyWith(
        ownerId: user.id,
        storeId: store.id,
      ),
    );
  }

  Future<Dress> updateDress(Dress dress) => _dresses.update(dress);

  Future<void> deleteDress(String id) => _dresses.delete(id);

  Future<void> archiveDress(String id) => _dresses.archive(id);

  Future<void> setDressAvailability(String dressId, bool available) async {
    final dress = FakeDatabase.instance.dresses.cast<Dress?>().firstWhere(
      (d) => d!.id == dressId,
      orElse: () => null,
    );
    if (dress == null) return;
    await _dresses.update(
      dress.copyWith(
        status: available ? DressStatus.available : DressStatus.rented,
      ),
    );
  }

  Future<void> updateDressPrice(
    String dressId, {
    required double pricePerDay,
    required double deposit,
  }) async {
    final dress = FakeDatabase.instance.dresses.cast<Dress?>().firstWhere(
      (d) => d!.id == dressId,
      orElse: () => null,
    );
    if (dress == null) return;
    await _dresses.update(
      dress.copyWith(pricePerDay: pricePerDay, deposit: deposit),
    );
  }

  Future<void> updateBookingStatus(String id, BookingStatus status) {
    return _bookings.updateStatus(id, status);
  }
}

final storeNotifierProvider =
    NotifierProvider<StoreNotifier, Store?>(StoreNotifier.new);
