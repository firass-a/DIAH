import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/fake_backend/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../shared/models/models.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({super.key, required this.dressId});

  final String dressId;

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  int _step = 0;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime _focused = DateTime.now();
  String? _size;
  bool _contract = false;
  bool _loading = false;
  String? _error;
  Address? _address;
  final _street = TextEditingController();
  final _city = TextEditingController(text: 'الجزائر العاصمة');
  final _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _phone.text = user.phone;
      if (user.addresses.isNotEmpty) {
        final a = user.addresses.first;
        _street.text = a.street;
        _city.text = a.city;
        _address = a;
      }
    }
    final dress = ref.read(dressByIdProvider(widget.dressId));
    if (dress != null && dress.sizes.isNotEmpty) {
      _size = dress.sizes.first;
    }
  }

  @override
  void dispose() {
    _street.dispose();
    _city.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final dress = ref.read(dressByIdProvider(widget.dressId));
    if (dress == null) return;
    setState(() => _error = null);

    if (_step == 0) {
      if (_rangeStart == null || _rangeEnd == null || _size == null) {
        setState(() => _error = 'يرجى اختيار التاريخ والمقاس');
        return;
      }
      if (!dress.isAvailableForRange(_rangeStart!, _rangeEnd!)) {
        setState(() => _error = 'الفستان غير متاح في هذه الفترة');
        return;
      }
      ref.read(bookingDraftProvider.notifier).setDates(_rangeStart!, _rangeEnd!);
      ref.read(bookingDraftProvider.notifier).setSize(_size!);
      setState(() => _step = 1);
      return;
    }

    if (_step == 1) {
      if (_street.text.trim().isEmpty || _city.text.trim().isEmpty) {
        setState(() => _error = 'يرجى إدخال عنوان التوصيل');
        return;
      }
      final addr = Address(
        id: _address?.id ?? 'temp',
        label: 'التوصيل',
        street: _street.text.trim(),
        city: _city.text.trim(),
        phone: _phone.text.trim(),
      );
      ref.read(bookingDraftProvider.notifier).setAddress(addr);
      setState(() {
        _address = addr;
        _step = 2;
      });
      return;
    }

    if (_step == 2) {
      if (!_contract) {
        setState(() => _error = 'يجب الموافقة على عقد الإيجار');
        return;
      }
      ref.read(bookingDraftProvider.notifier).setContract(true);
      setState(() => _step = 3);
      return;
    }

    // Step 3: mock payment + submit
    setState(() => _loading = true);
    try {
      final booking = await ref.read(bookingDraftProvider.notifier).submit();
      if (mounted) {
        context.go('/booking-confirmation/${booking.id}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final dress = ref.watch(dressByIdProvider(widget.dressId));

    if (dress == null) {
      return Scaffold(appBar: AppBar(), body: ErrorState(message: s.error));
    }

    final days = (_rangeStart != null && _rangeEnd != null)
        ? _rangeEnd!.difference(_rangeStart!).inDays + 1
        : 0;
    final total = days * dress.pricePerDay;

    final titles = [
      s.availability,
      s.deliveryAddress,
      s.contract,
      s.payment,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_step])),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? DiahColors.primary
                          : DiahColors.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: SingleChildScrollView(
                key: ValueKey(_step),
                padding: const EdgeInsets.all(20),
                child: _buildStep(dress, s, total, days),
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(_error!, style: const TextStyle(color: DiahColors.error)),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: PrimaryButton(
                label: _step == 3 ? s.confirm : s.continueText,
                isLoading: _loading,
                onPressed: _next,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(Dress dress, AppStrings s, double total, int days) {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dress.name, style: GoogleFonts.cormorantGaramond(fontSize: 24)),
            const SizedBox(height: 16),
            LuxuryCard(
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: _focused,
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                rangeSelectionMode: RangeSelectionMode.enforced,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                enabledDayPredicate: (day) => dress.isAvailableOn(day),
                onRangeSelected: (start, end, focused) {
                  setState(() {
                    _rangeStart = start;
                    _rangeEnd = end ?? start;
                    _focused = focused;
                  });
                },
                onPageChanged: (f) => _focused = f,
              ),
            ),
            const SizedBox(height: 20),
            Text(s.size, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: dress.sizes
                  .map(
                    (sz) => DiahFilterChip(
                      label: sz,
                      selected: _size == sz,
                      onSelected: (_) => setState(() => _size = sz),
                    ),
                  )
                  .toList(),
            ),
            if (days > 0) ...[
              const SizedBox(height: 20),
              LuxuryCard(
                color: DiahColors.softLavender,
                child: Row(
                  children: [
                    Text('$days ${s.days}'),
                    const Spacer(),
                    PriceWidget(amount: total, large: true),
                  ],
                ),
              ),
            ],
          ],
        );
      case 1:
        return Column(
          children: [
            TextField(
              controller: _street,
              decoration: InputDecoration(
                labelText: s.t('الشارع', 'Rue', 'Rue'),
                prefixIcon: const Icon(Icons.home_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _city,
              decoration: InputDecoration(
                labelText: s.t('المدينة', 'Ville', 'Ville'),
                prefixIcon: const Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: s.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LuxuryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.bookingSummary,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(height: 24),
                  _SummaryRow(s.t('الفستان', 'Robe', 'Robe'), dress.name),
                  _SummaryRow(s.size, _size ?? ''),
                  _SummaryRow(
                    s.t('الفترة', 'Période', 'Période'),
                    '$_rangeStart → $_rangeEnd'.split(' ').take(1).join(),
                  ),
                  _SummaryRow(
                    s.t('من', 'Du', 'Du'),
                    _rangeStart?.toString().substring(0, 10) ?? '',
                  ),
                  _SummaryRow(
                    s.t('إلى', 'Au', 'Au'),
                    _rangeEnd?.toString().substring(0, 10) ?? '',
                  ),
                  _SummaryRow('$days ${s.days}', s.formatPrice(total)),
                  _SummaryRow(s.deposit, s.formatPrice(dress.deposit)),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Text(s.total, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      PriceWidget(amount: total + dress.deposit, large: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            LuxuryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.contract,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.t(
                      'أوافق على استلام الفستان بحالة جيدة وإرجاعه في الموعد المحدد. أتحمل مسؤولية أي ضرر يلحق بالفستان. العربون غير قابل للاسترداد في حال الإلغاء خلال أقل من 48 ساعة.',
                      "J'accepte de recevoir la robe en bon état et de la retourner à temps. Je suis responsable de tout dommage. La caution est non remboursable en cas d'annulation sous 48h.",
                      'I agree to receive the dress in good condition and return it on time. I am responsible for any damage. The deposit is non-refundable if cancelled within 48 hours.',
                    ),
                    style: const TextStyle(
                      height: 1.5,
                      color: DiahColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  CheckboxListTile(
                    value: _contract,
                    onChanged: (v) => setState(() => _contract = v ?? false),
                    title: Text(s.acceptContract, style: const TextStyle(fontSize: 14)),
                    activeColor: DiahColors.primary,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
          ],
        );
      case 3:
      default:
        return Column(
          children: [
            LuxuryCard(
              color: DiahColors.softLavender,
              child: Column(
                children: [
                  const Icon(Icons.credit_card, size: 48, color: DiahColors.primary),
                  const SizedBox(height: 12),
                  Text(
                    s.mockPayment,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.t(
                      'سيتم خصم العربون فقط كتأكيد للحجز',
                      'Seule la caution sera débitée pour confirmer',
                      'Only the deposit will be charged to confirm the booking',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: DiahColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  PriceWidget(amount: dress.deposit, large: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: s.t('رقم البطاقة', 'N° de carte', 'N° de carte'),
                hintText: '4242 •••• •••• 4242',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'MM/YY', hintText: '12/28'),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'CVV', hintText: '123'),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: DiahColors.textSecondary)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final bookings = ref.watch(customerBookingsProvider);
    final booking = bookings.cast<Booking?>().firstWhere(
      (b) => b!.id == bookingId,
      orElse: () => null,
    );
    final dress = booking != null
        ? ref.watch(dressByIdProvider(booking.dressId))
        : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: const BoxDecoration(
                  color: DiahColors.softLavender,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 64,
                  color: DiahColors.success,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 28),
              Text(
                s.bookingConfirmed,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                dress?.name ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: DiahColors.textSecondary),
              ),
              if (booking != null) ...[
                const SizedBox(height: 24),
                LuxuryCard(
                  child: Column(
                    children: [
                      _SummaryRow(
                        s.t('من', 'Du', 'Du'),
                        booking.startDate.toString().substring(0, 10),
                      ),
                      _SummaryRow(
                        s.t('إلى', 'Au', 'Au'),
                        booking.endDate.toString().substring(0, 10),
                      ),
                      _SummaryRow(s.total, s.formatPrice(booking.totalPrice)),
                      _SummaryRow(s.deposit, s.formatPrice(booking.deposit)),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              PrimaryButton(
                label: s.myBookings,
                onPressed: () => context.go('/profile/bookings'),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: s.home,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
