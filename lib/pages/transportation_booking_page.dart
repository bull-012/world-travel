import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 交通機関予約情報のモデル
class TransportationBooking {
  const TransportationBooking({
    required this.type,
    required this.provider,
    required this.url,
    this.pdfPath,
    this.departureDate,
    this.departureTime,
    this.arrivalDate,
    this.arrivalTime,
    this.departureLocation,
    this.arrivalLocation,
    this.bookingReference,
    this.notes,
  });

  final String type; // 航空機、新幹線、バス、船など
  final String provider; // 予約サイト名
  final String url; // 予約URL
  final String? pdfPath; // PDFファイルパス
  final DateTime? departureDate; // 出発日
  final String? departureTime; // 出発時刻
  final DateTime? arrivalDate; // 到着日
  final String? arrivalTime; // 到着時刻
  final String? departureLocation; // 出発地
  final String? arrivalLocation; // 到着地
  final String? bookingReference; // 予約番号
  final String? notes; // メモ

  TransportationBooking copyWith({
    String? type,
    String? provider,
    String? url,
    String? pdfPath,
    DateTime? departureDate,
    String? departureTime,
    DateTime? arrivalDate,
    String? arrivalTime,
    String? departureLocation,
    String? arrivalLocation,
    String? bookingReference,
    String? notes,
  }) {
    return TransportationBooking(
      type: type ?? this.type,
      provider: provider ?? this.provider,
      url: url ?? this.url,
      pdfPath: pdfPath ?? this.pdfPath,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureLocation: departureLocation ?? this.departureLocation,
      arrivalLocation: arrivalLocation ?? this.arrivalLocation,
      bookingReference: bookingReference ?? this.bookingReference,
      notes: notes ?? this.notes,
    );
  }
}

class TransportationBookingPage extends HookConsumerWidget {
  const TransportationBookingPage({
    super.key,
    this.booking,
    this.isEditing = false,
  });

  final TransportationBooking? booking;
  final bool isEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // フォームコントローラー
    final typeController = useTextEditingController(text: booking?.type ?? '');
    final providerController =
        useTextEditingController(text: booking?.provider ?? '');
    final urlController = useTextEditingController(text: booking?.url ?? '');
    final departureLocationController =
        useTextEditingController(text: booking?.departureLocation ?? '');
    final arrivalLocationController =
        useTextEditingController(text: booking?.arrivalLocation ?? '');
    final departureTimeController =
        useTextEditingController(text: booking?.departureTime ?? '');
    final arrivalTimeController =
        useTextEditingController(text: booking?.arrivalTime ?? '');
    final bookingReferenceController =
        useTextEditingController(text: booking?.bookingReference ?? '');
    final notesController =
        useTextEditingController(text: booking?.notes ?? '');

    // 状態管理
    final selectedPdfPath = useState<String?>(booking?.pdfPath);
    final departureDate = useState<DateTime?>(booking?.departureDate);
    final arrivalDate = useState<DateTime?>(booking?.arrivalDate);
    final selectedTransportationType = useState<String?>(booking?.type);

    // 交通機関の種類
    final transportationTypes = [
      {'name': '航空機', 'icon': Icons.flight, 'color': Colors.blue},
      {'name': '新幹線', 'icon': Icons.train, 'color': Colors.green},
      {'name': '電車', 'icon': Icons.directions_railway, 'color': Colors.orange},
      {'name': 'バス', 'icon': Icons.directions_bus, 'color': Colors.red},
      {'name': '船', 'icon': Icons.directions_boat, 'color': Colors.cyan},
      {'name': 'レンタカー', 'icon': Icons.car_rental, 'color': Colors.purple},
      {'name': 'タクシー', 'icon': Icons.local_taxi, 'color': Colors.amber},
      {'name': 'その他', 'icon': Icons.more_horiz, 'color': Colors.grey},
    ];

    // 予約サイトの種類
    final bookingSites = [
      '楽天トラベル',
      'じゃらん',
      'エクスペディア',
      'Booking.com',
      'Agoda',
      'スカイスキャナー',
      'JR東海',
      'JAL',
      'ANA',
      'その他',
    ];

    // PDFファイル選択
    Future<void> pickPdfFile() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (result != null) {
          selectedPdfPath.value = result.files.single.path;
        }
      } on Exception catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ファイル選択エラー: $e')),
          );
        }
      }
    }

    // 保存処理
    void saveBooking() {
      final newBooking = TransportationBooking(
        type: selectedTransportationType.value ?? typeController.text,
        provider: providerController.text,
        url: urlController.text,
        pdfPath: selectedPdfPath.value,
        departureDate: departureDate.value,
        departureTime: departureTimeController.text,
        arrivalDate: arrivalDate.value,
        arrivalTime: arrivalTimeController.text,
        departureLocation: departureLocationController.text,
        arrivalLocation: arrivalLocationController.text,
        bookingReference: bookingReferenceController.text,
        notes: notesController.text,
      );

      Navigator.of(context).pop(newBooking);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '予約情報を編集' : '新しい予約を追加'),
        actions: [
          TextButton(
            onPressed: saveBooking,
            child: const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 交通機関の種類選択
            Text(
              '交通機関の種類',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: transportationTypes.length,
              itemBuilder: (context, index) {
                final type = transportationTypes[index];
                final isSelected =
                    selectedTransportationType.value == type['name'];

                return GestureDetector(
                  onTap: () {
                    selectedTransportationType.value = type['name']! as String;
                    typeController.text = type['name']! as String;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (type['color']! as Color).withValues(alpha: 0.1)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? type['color']! as Color
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type['icon']! as IconData,
                          color: isSelected
                              ? type['color']! as Color
                              : theme.colorScheme.onSurface,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type['name']! as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? type['color']! as Color
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                .animate(delay: const Duration(milliseconds: 200))
                .fadeIn(duration: const Duration(milliseconds: 600)),

            const SizedBox(height: 24),

            // 予約サイト選択
            Text(
              '予約サイト',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: bookingSites.contains(providerController.text)
                  ? providerController.text
                  : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.language),
              ),
              items: bookingSites.map((site) {
                return DropdownMenuItem(
                  value: site,
                  child: Text(site),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  providerController.text = value;
                }
              },
            )
                .animate(delay: const Duration(milliseconds: 400))
                .fadeIn(duration: const Duration(milliseconds: 600))
                .slideX(begin: 0.3),

            const SizedBox(height: 16),

            // 予約URL
            Text(
              '予約URL',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: 'https://...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            )
                .animate(delay: const Duration(milliseconds: 600))
                .fadeIn(duration: const Duration(milliseconds: 600))
                .slideX(begin: 0.3),

            const SizedBox(height: 24),

            // PDFファイル
            Text(
              '予約確認書（PDF）',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (selectedPdfPath.value != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedPdfPath.value!.split('/').last,
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => selectedPdfPath.value = null,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  FilledButton.tonal(
                    onPressed: pickPdfFile,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.upload_file),
                        const SizedBox(width: 8),
                        Text(
                          selectedPdfPath.value != null ? 'ファイルを変更' : 'PDFを選択',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate(delay: const Duration(milliseconds: 800))
                .fadeIn(duration: const Duration(milliseconds: 600))
                .slideY(begin: 0.3),

            const SizedBox(height: 24),

            // 出発・到着情報
            Text(
              '出発・到着情報',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // 出発地・到着地
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: departureLocationController,
                    decoration: InputDecoration(
                      labelText: '出発地',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.flight_takeoff),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: arrivalLocationController,
                    decoration: InputDecoration(
                      labelText: '到着地',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.flight_land),
                    ),
                  ),
                ),
              ],
            )
                .animate(delay: const Duration(milliseconds: 1000))
                .fadeIn(duration: const Duration(milliseconds: 600))
                .slideY(begin: 0.3),

            const SizedBox(height: 16),

            // 出発日時・到着日時
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '出発日時',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: departureDate.value ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            departureDate.value = date;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                departureDate.value != null
                                    ? '${departureDate.value!.month}/${departureDate.value!.day}'
                                    : '日付を選択',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: departureTimeController,
                        decoration: InputDecoration(
                          hintText: '例: 09:30',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.access_time),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '到着日時',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: arrivalDate.value ??
                                departureDate.value ??
                                DateTime.now(),
                            firstDate: departureDate.value ?? DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            arrivalDate.value = date;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                arrivalDate.value != null
                                    ? '${arrivalDate.value!.month}/${arrivalDate.value!.day}'
                                    : '日付を選択',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: arrivalTimeController,
                        decoration: InputDecoration(
                          hintText: '例: 12:45',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.access_time),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
                .animate(delay: const Duration(milliseconds: 1200))
                .fadeIn(duration: const Duration(milliseconds: 600))
                .slideY(begin: 0.3),

            const SizedBox(height: 24),

            // 予約番号
            Text(
              '予約番号',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bookingReferenceController,
              decoration: InputDecoration(
                hintText: '例: ABC123DEF',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.confirmation_number),
              ),
            )
                .animate(delay: const Duration(milliseconds: 1400))
                .fadeIn(duration: const Duration(milliseconds: 600))
                .slideX(begin: 0.3),

            const SizedBox(height: 16),

            // メモ
            Text(
              'メモ',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '座席番号、注意事項などのメモ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.note),
                ),
              ),
            )
                .animate(delay: const Duration(milliseconds: 1600))
                .fadeIn(duration: const Duration(milliseconds: 600))
                .slideY(begin: 0.3),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
