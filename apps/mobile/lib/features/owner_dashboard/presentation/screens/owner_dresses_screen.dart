import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/fake_backend/owner_providers.dart';
import '../../../../core/fake_backend/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../core/widgets/dress_image.dart';
import '../../../../shared/enums/app_enums.dart';
import '../../../../shared/models/models.dart';
import '../widgets/owner_widgets.dart';
import 'owner_shell.dart';

class OwnerDressesScreen extends ConsumerWidget {
  const OwnerDressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final dresses = ref.watch(ownerDressNotifierProvider);

    return Scaffold(
      backgroundColor: OwnerColors.canvas,
      appBar: OwnerAppBar(title: s.myDresses),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: OwnerColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/owner/add-dress'),
        icon: const Icon(Icons.add),
        label: Text(s.addDress),
      ),
      body: dresses.isEmpty
          ? EmptyState(
              message: s.t(
                'خزانتك فارغة — أضيفي أول فستان',
                'Garde-robe vide — ajoutez votre première robe',
                'Your wardrobe is empty — add your first dress',
              ),
              icon: Icons.checkroom_outlined,
              actionLabel: s.addDress,
              onAction: () => context.push('/owner/add-dress'),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: dresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final d = dresses[i];
                return OwnerCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DressImage(
                        source: d.images.isNotEmpty ? d.images.first : '',
                        width: 84,
                        height: 100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            PriceWidget(
                              amount: d.pricePerDay,
                              suffix: s.pricePerDay,
                            ),
                            const SizedBox(height: 6),
                            _DressStatusChip(status: d.status, s: s),
                            const SizedBox(height: 4),
                            Text(
                              s.t(
                                '${d.rentalCount} إيجار',
                                '${d.rentalCount} location(s)',
                                '${d.rentalCount} rental(s)',
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: DiahColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) => _onAction(context, ref, d, v, s),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(s.t('تعديل', 'Modifier', 'Edit')),
                          ),
                          if (d.status == DressStatus.pending) ...[
                            PopupMenuItem(
                              value: 'approve',
                              child: Text(
                                s.t(
                                  'موافقة (تجريبي)',
                                  'Approuver (démo)',
                                  'Approve (demo)',
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'reject',
                              child: Text(
                                s.t('رفض (تجريبي)', 'Refuser (démo)', 'Reject (demo)'),
                              ),
                            ),
                          ],
                          if (d.status == DressStatus.available ||
                              d.status == DressStatus.approved)
                            PopupMenuItem(
                              value: 'unavailable',
                              child: Text(
                                s.t('تعطيل التوفر', 'Rendre indisponible', 'Make unavailable'),
                              ),
                            ),
                          if (d.status == DressStatus.archived)
                            PopupMenuItem(
                              value: 'available',
                              child: Text(
                                s.t('إعادة التفعيل', 'Réactiver', 'Make available'),
                              ),
                            ),
                          PopupMenuItem(
                            value: 'archive',
                            child: Text(s.t('أرشفة', 'Archiver', 'Archive')),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              s.t('حذف', 'Supprimer', 'Delete'),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    Dress d,
    String action,
    AppStrings s,
  ) async {
    final n = ref.read(ownerDressNotifierProvider.notifier);
    switch (action) {
      case 'edit':
        context.push('/owner/edit-dress/${d.id}');
      case 'approve':
        await n.simulateApprove(d.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                s.t('تمت الموافقة — الفستان ظاهر للزبائن', 'Approuvé', 'Approved — now public'),
              ),
            ),
          );
        }
      case 'reject':
        await n.simulateReject(d.id);
      case 'unavailable':
        await n.setAvailability(d.id, false);
      case 'available':
        await n.setAvailability(d.id, true);
      case 'archive':
        await n.archiveDress(d.id);
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(s.t('حذف الفستان؟', 'Supprimer ?', 'Delete dress?')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(s.t('إلغاء', 'Annuler', 'Cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(s.t('حذف', 'Supprimer', 'Delete')),
              ),
            ],
          ),
        );
        if (ok == true) await n.deleteDress(d.id);
    }
  }
}

class _DressStatusChip extends StatelessWidget {
  const _DressStatusChip({required this.status, required this.s});

  final DressStatus status;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      DressStatus.pending => (
          s.t('قيد المراجعة', 'En revue', 'Pending Review'),
          DiahColors.warning,
        ),
      DressStatus.approved || DressStatus.available => (
          s.t('معتمد / متاح', 'Approuvé', 'Approved'),
          DiahColors.success,
        ),
      DressStatus.rejected => (
          s.t('مرفوض', 'Refusé', 'Rejected'),
          Colors.redAccent,
        ),
      DressStatus.archived => (
          s.t('غير نشط', 'Inactif', 'Inactive'),
          DiahColors.textMuted,
        ),
      DressStatus.rented => (
          s.t('مؤجر حالياً', 'Loué', 'Rented'),
          OwnerColors.accent,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Step-by-step personal dress form.
class OwnerAddEditDressScreen extends ConsumerStatefulWidget {
  const OwnerAddEditDressScreen({super.key, this.dressId});

  final String? dressId;

  @override
  ConsumerState<OwnerAddEditDressScreen> createState() =>
      _OwnerAddEditDressScreenState();
}

class _OwnerAddEditDressScreenState
    extends ConsumerState<OwnerAddEditDressScreen> {
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _price;
  late final TextEditingController _deposit;
  late final TextEditingController _color;
  late final TextEditingController _days;
  DressCategory _category = DressCategory.evening;
  DressOccasion _occasion = DressOccasion.soiree;
  final List<String> _sizes = ['M'];
  final List<String> _images = [];
  DateTimeRange? _availableRange;
  final _picker = ImagePicker();
  bool _loading = false;
  int _step = 0;

  static const _fallbackImage =
      'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800';

  @override
  void initState() {
    super.initState();
    final existing = widget.dressId != null
        ? ref.read(dressByIdProvider(widget.dressId!))
        : null;
    _name = TextEditingController(text: existing?.name ?? '');
    _desc = TextEditingController(text: existing?.description ?? '');
    _price = TextEditingController(
      text: existing?.pricePerDay.toStringAsFixed(0) ?? '5000',
    );
    _deposit = TextEditingController(
      text: existing?.deposit.toStringAsFixed(0) ?? '15000',
    );
    _color = TextEditingController(text: existing?.color ?? '');
    _days = TextEditingController(text: '${existing?.minRentalDays ?? 2}');
    if (existing != null) {
      _category = existing.category;
      _occasion = existing.occasion;
      _sizes
        ..clear()
        ..addAll(existing.sizes);
      _images.addAll(existing.images);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _deposit.dispose();
    _color.dispose();
    _days.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;
    setState(() {
      for (final f in files) {
        if (!_images.contains(f.path)) _images.add(f.path);
      }
    });
  }

  Future<void> _pickFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() {
      if (!_images.contains(file.path)) _images.add(file.path);
    });
  }

  Future<void> _pickDates(AppStrings s) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _availableRange ??
          DateTimeRange(start: now, end: now.add(const Duration(days: 30))),
      helpText: s.t(
        'فترات التوفر',
        'Disponibilités',
        'Availability dates',
      ),
    );
    if (range != null) setState(() => _availableRange = range);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _sizes.isEmpty) return;
    setState(() => _loading = true);
    final notifier = ref.read(ownerDressNotifierProvider.notifier);
    final images =
        _images.isEmpty ? [_fallbackImage] : List<String>.from(_images);

    // Dates outside selected range become unavailable for a simple prototype.
    final unavailable = <DateTime>[];
    if (_availableRange != null) {
      final start = DateTime.now();
      final end = start.add(const Duration(days: 90));
      var cursor = DateTime(start.year, start.month, start.day);
      final last = DateTime(end.year, end.month, end.day);
      final availStart = DateTime(
        _availableRange!.start.year,
        _availableRange!.start.month,
        _availableRange!.start.day,
      );
      final availEnd = DateTime(
        _availableRange!.end.year,
        _availableRange!.end.month,
        _availableRange!.end.day,
      );
      while (!cursor.isAfter(last)) {
        if (cursor.isBefore(availStart) || cursor.isAfter(availEnd)) {
          unavailable.add(cursor);
        }
        cursor = cursor.add(const Duration(days: 1));
      }
    }

    final dress = Dress(
      id: widget.dressId ?? '',
      name: _name.text.trim(),
      description: _desc.text.trim(),
      images: images,
      category: _category,
      occasion: _occasion,
      color: _color.text.trim(),
      sizes: List.from(_sizes),
      pricePerDay: double.tryParse(_price.text) ?? 5000,
      deposit: double.tryParse(_deposit.text) ?? 15000,
      ownerId: ref.read(authProvider).user?.id ?? '',
      storeId: null,
      minRentalDays: int.tryParse(_days.text) ?? 1,
      unavailableDates: unavailable,
      status: DressStatus.pending,
    );

    try {
      if (widget.dressId != null) {
        final existing = ref.read(dressByIdProvider(widget.dressId!))!;
        final resubmit = existing.status == DressStatus.rejected;
        await notifier.updateDress(
          dress.copyWith(
            id: existing.id,
            rating: existing.rating,
            reviews: existing.reviews,
            rentalCount: existing.rentalCount,
            unavailableDates:
                unavailable.isEmpty ? existing.unavailableDates : unavailable,
            createdAt: existing.createdAt,
            status: resubmit ? DressStatus.pending : existing.status,
          ),
        );
      } else {
        await notifier.addDress(dress);
      }
      if (mounted) {
        final strings = ref.read(stringsProvider);
        final msg = widget.dressId == null
            ? strings.t(
                'تم الإرسال للمراجعة',
                'Envoyé pour validation',
                'Submitted for platform review',
              )
            : strings.t('تم الحفظ', 'Enregistré', 'Saved');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final isEdit = widget.dressId != null;
    final steps = [
      s.t('التفاصيل', 'Détails', 'Details'),
      s.t('الصور والتوفر', 'Photos', 'Photos & dates'),
      s.t('السعر', 'Prix', 'Pricing'),
    ];

    return Scaffold(
      backgroundColor: OwnerColors.canvas,
      appBar: AppBar(
        backgroundColor: OwnerColors.canvas,
        title: Text(
          isEdit
              ? s.t('تعديل فستان', 'Modifier la robe', 'Edit dress')
              : s.t('أضيفي فستاناً شخصياً', 'Ajouter une robe', 'Add personal dress'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: List.generate(steps.length, (i) {
                final active = i <= _step;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: active
                                ? OwnerColors.accent
                                : DiahColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          steps[i],
                          style: TextStyle(
                            fontSize: 11,
                            color: active
                                ? OwnerColors.accent
                                : DiahColors.textMuted,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _step == 0
                  ? _buildDetails(s)
                  : _step == 1
                      ? _buildPhotos(s)
                      : _buildPricing(s),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        child: Text(s.t('السابق', 'Retour', 'Back')),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: _step < 2
                          ? s.continueText
                          : s.save,
                      isLoading: _loading,
                      onPressed: () {
                        if (_step < 2) {
                          if (_step == 0 && _name.text.trim().isEmpty) return;
                          setState(() => _step++);
                        } else {
                          _save();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(AppStrings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.t(
            'مثال: فستان زفاف، كاراكو، فستان سهرة…',
            'Ex. robe de mariée, karakou, robe de soirée…',
            'e.g. wedding gown, karakou, evening dress…',
          ),
          style: const TextStyle(color: DiahColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          decoration: InputDecoration(
            labelText: s.t('اسم الفستان', 'Nom', 'Dress name'),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _desc,
          maxLines: 4,
          decoration: InputDecoration(labelText: s.description),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<DressCategory>(
          initialValue: _category,
          decoration: InputDecoration(labelText: s.categories),
          items: DressCategory.values
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(s.categoryLabel(c)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _category = v!),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<DressOccasion>(
          initialValue: _occasion,
          decoration: InputDecoration(labelText: s.occasion),
          items: DressOccasion.values
              .map((o) => DropdownMenuItem(value: o, child: Text(o.name)))
              .toList(),
          onChanged: (v) => setState(() => _occasion = v!),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _color,
          decoration: InputDecoration(labelText: s.color),
        ),
        const SizedBox(height: 16),
        Text(s.size, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['XS', 'S', 'M', 'L', 'XL', 'One Size'].map((sz) {
            final selected = _sizes.contains(sz);
            return DiahFilterChip(
              label: sz,
              selected: selected,
              onSelected: (_) {
                setState(() {
                  if (selected) {
                    _sizes.remove(sz);
                  } else {
                    _sizes.add(sz);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotos(AppStrings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.t('صور الفستان', 'Photos', 'Dress photos'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._images.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: Stack(
                    children: [
                      DressImage(
                        source: e.value,
                        width: 100,
                        height: 120,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.removeAt(e.key)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              GestureDetector(
                onTap: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: DiahColors.card,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (ctx) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_library_outlined),
                            title: Text(
                              s.t('من المعرض', 'Galerie', 'From gallery'),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              _pickFromGallery();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_camera_outlined),
                            title: Text(
                              s.t('التقاط صورة', 'Appareil photo', 'Take a photo'),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              _pickFromCamera();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    color: OwnerColors.accentSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: OwnerColors.accent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined,
                          color: OwnerColors.accent),
                      const SizedBox(height: 6),
                      Text(
                        s.t('إضافة', 'Ajouter', 'Add'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: OwnerColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OwnerCard(
          onTap: () => _pickDates(s),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: OwnerColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.t('تواريخ التوفر', 'Dates de dispo.', 'Availability dates'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _availableRange == null
                          ? s.t(
                              'اختاري الفترة المتاحة للإيجار',
                              'Choisir la période',
                              'Choose available period',
                            )
                          : '${_fmt(_availableRange!.start)} → ${_fmt(_availableRange!.end)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: DiahColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricing(AppStrings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.t(
            'بعد الحفظ سيُراجع الفستان قبل ظهوره للزبائن',
            'Après envoi, la robe sera validée avant publication',
            'After save, the dress is reviewed before going public',
          ),
          style: const TextStyle(color: DiahColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    labelText: s.t(
                      'سعر الإيجار',
                      'Prix location',
                      'Price per rental',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: _deposit,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(labelText: s.deposit),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Directionality(
          textDirection: TextDirection.ltr,
          child: TextField(
            controller: _days,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              labelText: s.t(
                'مدة الإيجار (أيام)',
                'Durée (jours)',
                'Rental duration (days)',
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
