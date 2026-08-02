import '../../shared/enums/app_enums.dart';
import '../../shared/models/models.dart';
import 'fake_database.dart';
import 'repositories.dart';

class FakeBookingRepository implements BookingRepository {
  FakeBookingRepository({FakeDatabase? db})
    : _db = db ?? FakeDatabase.instance;

  final FakeDatabase _db;

  @override
  Future<List<Booking>> getAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.from(_db.bookings);
  }

  @override
  Future<Booking?> getById(String id) async {
    return _db.bookings.cast<Booking?>().firstWhere(
      (b) => b!.id == id,
      orElse: () => null,
    );
  }

  @override
  Future<List<Booking>> getByCustomer(String customerId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _db.bookings.where((b) => b.customerId == customerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Booking>> getByOwner(String ownerId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final dressIds = _db.dresses
        .where((d) => d.ownerId == ownerId)
        .map((d) => d.id)
        .toSet();
    return _db.bookings.where((b) => dressIds.contains(b.dressId)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Booking>> getByStore(String storeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final dressIds = _db.dresses
        .where((d) => d.storeId == storeId)
        .map((d) => d.id)
        .toSet();
    return _db.bookings.where((b) => dressIds.contains(b.dressId)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Booking> create({
    required String dressId,
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
    required String size,
    required Address deliveryAddress,
    required bool contractAccepted,
    String? notes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!contractAccepted) {
      throw Exception('يجب الموافقة على عقد الإيجار');
    }

    final dress = _db.dresses.cast<Dress?>().firstWhere(
      (d) => d!.id == dressId,
      orElse: () => null,
    );
    if (dress == null) throw Exception('الفستان غير موجود');

    if (!dress.isAvailableForRange(startDate, endDate)) {
      throw Exception('الفستان غير متاح في هذه الفترة');
    }

    final days = endDate.difference(startDate).inDays + 1;
    final totalPrice = dress.pricePerDay * days;

    final booking = Booking(
      id: _db.newId(),
      dressId: dressId,
      customerId: customerId,
      startDate: startDate,
      endDate: endDate,
      totalPrice: totalPrice,
      deposit: dress.deposit,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      deliveryAddress: deliveryAddress,
      size: size,
      contractAccepted: true,
      notes: notes,
    );

    _db.bookings.insert(0, booking);

    // Block dates
    var cursor = DateTime(startDate.year, startDate.month, startDate.day);
    final last = DateTime(endDate.year, endDate.month, endDate.day);
    final blocked = <DateTime>[...dress.unavailableDates];
    while (!cursor.isAfter(last)) {
      blocked.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    dress.unavailableDates = blocked;
    dress.rentalCount += 1;

    // Customer booking ids
    final customer = _db.users.cast<AppUser?>().firstWhere(
      (u) => u!.id == customerId,
      orElse: () => null,
    );
    if (customer != null) {
      customer.bookingIds = [...customer.bookingIds, booking.id];
    }

    // Deposit transaction
    final tx = AppTransaction(
      id: _db.newId(),
      bookingId: booking.id,
      amount: dress.deposit,
      type: TransactionType.deposit,
      status: TransactionStatus.completed,
      date: DateTime.now(),
      userId: customerId,
      description: 'عربون حجز - ${dress.name}',
    );
    _db.transactions.insert(0, tx);

    // Rental payment transaction (pending remaining)
    _db.transactions.insert(
      0,
      AppTransaction(
        id: _db.newId(),
        bookingId: booking.id,
        amount: totalPrice,
        type: TransactionType.rentalPayment,
        status: TransactionStatus.pending,
        date: DateTime.now(),
        userId: customerId,
        description: 'دفعة إيجار - ${dress.name}',
      ),
    );

    // Notifications
    _db.notifications.insert(
      0,
      AppNotification(
        id: _db.newId(),
        userId: customerId,
        title: 'تم تأكيد طلب الحجز',
        body: 'تم إنشاء حجزك لـ ${dress.name}. في انتظار موافقة المؤجر.',
        type: NotificationType.newBooking,
        createdAt: DateTime.now(),
        relatedId: booking.id,
      ),
    );
    _db.notifications.insert(
      0,
      AppNotification(
        id: _db.newId(),
        userId: dress.ownerId,
        title: 'حجز جديد',
        body: 'طلب حجز جديد لفستان ${dress.name}',
        type: NotificationType.newBooking,
        createdAt: DateTime.now(),
        relatedId: booking.id,
      ),
    );
    _db.notifications.insert(
      0,
      AppNotification(
        id: _db.newId(),
        userId: customerId,
        title: 'تم الدفع بنجاح',
        body: 'تم استلام عربون الحجز بمبلغ ${dress.deposit.toStringAsFixed(0)} دج',
        type: NotificationType.paymentCompleted,
        createdAt: DateTime.now(),
        relatedId: tx.id,
      ),
    );

    _db.notify();
    return booking;
  }

  @override
  Future<Booking> updateStatus(String id, BookingStatus status) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final index = _db.bookings.indexWhere((b) => b.id == id);
    if (index < 0) throw Exception('الحجز غير موجود');
    final booking = _db.bookings[index].copyWith(status: status);
    _db.bookings[index] = booking;

    final dress = _db.dresses.cast<Dress?>().firstWhere(
      (d) => d!.id == booking.dressId,
      orElse: () => null,
    );

    NotificationType notifType;
    String title;
    String body;
    switch (status) {
      case BookingStatus.accepted:
        notifType = NotificationType.bookingAccepted;
        title = 'تم قبول حجزك';
        body = 'تم قبول حجزك لـ ${dress?.name ?? 'الفستان'}';
      case BookingStatus.rejected:
        notifType = NotificationType.bookingRejected;
        title = 'تم رفض الحجز';
        body = 'للأسف تم رفض حجزك لـ ${dress?.name ?? 'الفستان'}';
        // Unblock dates on reject
        if (dress != null) {
          dress.unavailableDates = dress.unavailableDates.where((d) {
            final day = DateTime(d.year, d.month, d.day);
            return day.isBefore(
                  DateTime(
                    booking.startDate.year,
                    booking.startDate.month,
                    booking.startDate.day,
                  ),
                ) ||
                day.isAfter(
                  DateTime(
                    booking.endDate.year,
                    booking.endDate.month,
                    booking.endDate.day,
                  ),
                );
          }).toList();
        }
      case BookingStatus.returned:
      case BookingStatus.completed:
        notifType = NotificationType.dressReturned;
        title = 'تم إرجاع الفستان';
        body = 'تم تأكيد إرجاع ${dress?.name ?? 'الفستان'}';
      default:
        notifType = NotificationType.general;
        title = 'تحديث الحجز';
        body = 'تم تحديث حالة حجزك';
    }

    _db.notifications.insert(
      0,
      AppNotification(
        id: _db.newId(),
        userId: booking.customerId,
        title: title,
        body: body,
        type: notifType,
        createdAt: DateTime.now(),
        relatedId: booking.id,
      ),
    );

    _db.notify();
    return booking;
  }

  @override
  Future<void> delete(String id) async {
    _db.bookings.removeWhere((b) => b.id == id);
    _db.notify();
  }
}

class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository({FakeDatabase? db})
    : _db = db ?? FakeDatabase.instance;

  final FakeDatabase _db;

  @override
  Future<List<AppTransaction>> getAll() async => List.from(_db.transactions);

  @override
  Future<List<AppTransaction>> getByUser(String userId) async {
    return _db.transactions.where((t) => t.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<AppTransaction?> getById(String id) async {
    return _db.transactions.cast<AppTransaction?>().firstWhere(
      (t) => t!.id == id,
      orElse: () => null,
    );
  }

  @override
  Future<AppTransaction> create(AppTransaction transaction) async {
    final tx = transaction.copyWith(
      id: transaction.id.isEmpty ? _db.newId() : transaction.id,
    );
    _db.transactions.insert(0, tx);
    _db.notify();
    return tx;
  }

  @override
  Future<AppTransaction> update(AppTransaction transaction) async {
    final index = _db.transactions.indexWhere((t) => t.id == transaction.id);
    if (index < 0) throw Exception('المعاملة غير موجودة');
    _db.transactions[index] = transaction;
    _db.notify();
    return transaction;
  }

  @override
  Future<void> delete(String id) async {
    _db.transactions.removeWhere((t) => t.id == id);
    _db.notify();
  }
}

class FakeFavoriteRepository implements FavoriteRepository {
  FakeFavoriteRepository({FakeDatabase? db})
    : _db = db ?? FakeDatabase.instance;

  final FakeDatabase _db;

  @override
  Future<List<Favorite>> getByUser(String userId) async {
    return _db.favorites.where((f) => f.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<bool> isFavorite(String userId, String dressId) async {
    return _db.favorites.any(
      (f) => f.userId == userId && f.dressId == dressId,
    );
  }

  @override
  Future<Favorite> add(String userId, String dressId) async {
    final existing = _db.favorites.cast<Favorite?>().firstWhere(
      (f) => f!.userId == userId && f.dressId == dressId,
      orElse: () => null,
    );
    if (existing != null) return existing;
    final fav = Favorite(
      id: _db.newId(),
      userId: userId,
      dressId: dressId,
      createdAt: DateTime.now(),
    );
    _db.favorites.add(fav);
    _db.notify();
    return fav;
  }

  @override
  Future<void> remove(String userId, String dressId) async {
    _db.favorites.removeWhere(
      (f) => f.userId == userId && f.dressId == dressId,
    );
    _db.notify();
  }
}

class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({FakeDatabase? db})
    : _db = db ?? FakeDatabase.instance;

  final FakeDatabase _db;

  @override
  Future<List<AppNotification>> getByUser(String userId) async {
    return _db.notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<int> unreadCount(String userId) async {
    return _db.notifications
        .where((n) => n.userId == userId && !n.isRead)
        .length;
  }

  @override
  Future<AppNotification> create(AppNotification notification) async {
    final n = notification.copyWith(
      id: notification.id.isEmpty ? _db.newId() : notification.id,
    );
    _db.notifications.insert(0, n);
    _db.notify();
    return n;
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _db.notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _db.notifications[index] = _db.notifications[index].copyWith(
        isRead: true,
      );
      _db.notify();
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    for (var i = 0; i < _db.notifications.length; i++) {
      if (_db.notifications[i].userId == userId) {
        _db.notifications[i] = _db.notifications[i].copyWith(isRead: true);
      }
    }
    _db.notify();
  }

  @override
  Future<void> delete(String id) async {
    _db.notifications.removeWhere((n) => n.id == id);
    _db.notify();
  }
}
