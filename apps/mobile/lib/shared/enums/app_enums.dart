/// User role within the Diah marketplace.
/// Kept as the *active experience* for routing; multi-mode lives in [AccountMode].
enum UserRole {
  guest,
  customer,
  individualOwner,
  storeOwner,
}

/// Modes a single account can activate (multi-select).
enum AccountMode {
  customer,
  individualOwner,
  storeOwner,
}

/// Mock identity / business verification lifecycle.
enum VerificationStatus {
  none,
  pending,
  verified,
  rejected,
}

/// Dress category taxonomy.
enum DressCategory {
  wedding,
  evening,
  traditional,
  accessories,
}

/// Occasion for which a dress is suitable.
enum DressOccasion {
  wedding,
  engagement,
  soiree,
  traditionalCeremony,
  graduation,
  other,
}

/// Lifecycle status of a dress listing.
enum DressStatus {
  pending,
  approved,
  rejected,
  archived,
  rented,
  available,
}

/// Booking lifecycle.
enum BookingStatus {
  pending,
  accepted,
  rejected,
  preparing,
  delivered,
  returned,
  cancelled,
  completed,
}

/// Transaction kinds.
enum TransactionType {
  rentalPayment,
  deposit,
  refund,
  commission,
}

/// Transaction status.
enum TransactionStatus {
  pending,
  completed,
  failed,
  refunded,
}

/// Notification kinds.
enum NotificationType {
  newBooking,
  bookingAccepted,
  bookingRejected,
  dressApproved,
  dressRejected,
  dressReturned,
  paymentCompleted,
  reminder,
  general,
}

/// Store / activity type.
enum StoreType {
  wedding,
  evening,
  traditional,
  multi,
}

/// Subscription plan for stores.
enum SubscriptionPlan {
  monthly,
  yearly,
  none,
}

/// Store subscription status.
enum SubscriptionStatus {
  active,
  expired,
  trial,
  cancelled,
  none,
}

/// Sort options for search.
enum DressSortOption {
  newest,
  priceLowToHigh,
  priceHighToLow,
  rating,
  popular,
}
