import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await Hive.initFlutter();
  await Hive.openBox('stadium_v2_box');
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'یاریگا',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const SplashScreen(),
    );
  }
}

// ---------------- 1. شاشەی دەستپێک (Splash Screen) ----------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade800,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/stadiom_1.avif',
              width: 140,
              height: 140,
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.sports_soccer,
                  size: 100,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'بەرێوەبردنی یاریگای زەیدون',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 2. شاشەی سەرەکی ----------------
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zaidun Stadium',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 70,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  icon: const Icon(Icons.add_task, size: 28),
                  label: const Text('حجز کردن',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BookingDaysScreen()));
                  },
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 70,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  icon: const Icon(Icons.calendar_month, size: 28),
                  label: const Text('دیتنا خشتێ',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WeeklyScheduleScreen()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _getKurdishMonthName(int month) {
  List<String> months = [
    '',
    'کانونی دووەم',
    'شوبات',
    'ئازار',
    'نیسان',
    'ئایار',
    'حوزەیران',
    'تەممووز',
    'ئاب',
    'ئەیلوول',
    'تشرینی یەکەم',
    'تشرینی دووەم',
    'کانونی یەکەم'
  ];
  return months[month];
}

// ---------------- 3. شاشەی حجزکردن ----------------
class BookingDaysScreen extends StatefulWidget {
  const BookingDaysScreen({super.key});

  @override
  State<BookingDaysScreen> createState() => _BookingDaysScreenState();
}

class _BookingDaysScreenState extends State<BookingDaysScreen> {
  bool isMonthlyMode = false;
  late DateTime startDate;
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now().toLocal();
    startDate = DateTime(now.year, now.month, now.day);
    selectedMonth = DateTime(now.year, now.month, 1);
  }

  String getKurdishDayName(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
        return 'شەممە';
      case DateTime.sunday:
        return 'یکشەممە';
      case DateTime.monday:
        return 'دووشەممە';
      case DateTime.tuesday:
        return 'سێشەممە';
      case DateTime.wednesday:
        return 'چوارشەممە';
      case DateTime.thursday:
        return 'پێنجشەممە';
      case DateTime.friday:
        return 'هەیینی';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> daysToShow = [];
    if (isMonthlyMode) {
      int daysInMonth =
          DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
      daysToShow = List.generate(
        daysInMonth,
        (index) => DateTime(selectedMonth.year, selectedMonth.month, index + 1),
      );
    } else {
      daysToShow = List.generate(
        7,
        (index) => startDate.add(Duration(days: index)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('دیاریکردنی بەروار'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.green.shade50,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('هەفتانە'),
                        selected: !isMonthlyMode,
                        onSelected: (selected) {
                          setState(() {
                            isMonthlyMode = false;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('مانگانە'),
                        selected: isMonthlyMode,
                        onSelected: (selected) {
                          setState(() {
                            isMonthlyMode = true;
                          });
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.green),
                        onPressed: () {
                          setState(() {
                            if (isMonthlyMode) {
                              selectedMonth = DateTime(selectedMonth.year,
                                  selectedMonth.month - 1, 1);
                            } else {
                              startDate =
                                  startDate.subtract(const Duration(days: 7));
                            }
                          });
                        },
                      ),
                      Text(
                        isMonthlyMode
                            ? 'خشتەی مانگی: ${_getKurdishMonthName(selectedMonth.month)} ${selectedMonth.year}'
                            : 'دەستپێکی هەفتە: ${startDate.year}/${startDate.month.toString().padLeft(2, '0')}/${startDate.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Colors.green),
                        onPressed: () {
                          setState(() {
                            if (isMonthlyMode) {
                              selectedMonth = DateTime(selectedMonth.year,
                                  selectedMonth.month + 1, 1);
                            } else {
                              startDate =
                                  startDate.add(const Duration(days: 7));
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: daysToShow.length,
                  itemBuilder: (context, index) {
                    DateTime day = daysToShow[index];
                    String dayName = getKurdishDayName(day.weekday);
                    // Fixed format to include leading zeros for consistency across devices
                    String dateStr =
                        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          child: Text('${index + 1}'),
                        ),
                        title: Text('$dayName ($dateStr)',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HoursBookingScreen(
                                  selectedDate: day, dayName: dayName),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- 4. شاشەی دیاریکردنی کاتژمێرەکان ----------------
class HoursBookingScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String dayName;

  const HoursBookingScreen({
    super.key,
    required this.selectedDate,
    required this.dayName,
  });

  @override
  State<HoursBookingScreen> createState() => _HoursBookingScreenState();
}

class _HoursBookingScreenState extends State<HoursBookingScreen> {
  final List<String> timeSlots = [
    '02:00 پ.ن - 03:00 پ.ن',
    '03:00 پ.ن - 04:00 پ.ن',
    '04:00 پ.ن - 05:00 پ.ن',
    '05:00 پ.ن - 06:00 پ.ن',
    '06:00 پ.ن - 07:00 پ.ن',
    '07:00 پ.ن - 08:00 پ.ن',
    '08:00 پ.ن - 09:00 پ.ن',
    '09:00 پ.ن - 10:00 پ.ن',
    '10:00 پ.ن - 11:00 پ.ن',
    '11:00 پ.ن - 12:00 ب.ن',
    '12:00 ب.ن - 01:00 ب.ن',
    '01:00 ب.ن - 02:00 ب.ن',
    '02:00 ب.ن - 03:00 ب.ن',
  ];

  void _openBookingDialog(
      String dateKey, String slot, Map<String, dynamic> dayData) {
    final nameController = TextEditingController();
    bool isPaid = false;
    bool isRecurring = false;
    int monthsCount = 1;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text('حجزکردنی کاتی $slot'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'ناوی تەواو (پێویستە)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        title: const Text('پارە واسڵ کراوە (سەح)'),
                        value: isPaid,
                        onChanged: (val) =>
                            setDialogState(() => isPaid = val ?? false),
                      ),
                      const Divider(),
                      CheckboxListTile(
                        title:
                            const Text('حجزی جێگیر (سابت) بۆ هەموو هەفتەیەک'),
                        subtitle:
                            const Text('دووبارەبوونەوە لە هەمان ڕۆژ و کاتدا'),
                        value: isRecurring,
                        onChanged: (val) =>
                            setDialogState(() => isRecurring = val ?? false),
                      ),
                      if (isRecurring) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('ماوەی حجز لە مانگ:'),
                            DropdownButton<int>(
                              value: monthsCount,
                              items: const [
                                DropdownMenuItem(
                                    value: 1, child: Text('۱ مانگ')),
                                DropdownMenuItem(
                                    value: 3, child: Text('۳ مانگ')),
                                DropdownMenuItem(
                                    value: 6, child: Text('٦ مانگ')),
                                DropdownMenuItem(
                                    value: 12, child: Text('۱ ساڵ (۱۲ مانگ)')),
                              ],
                              onChanged: (val) =>
                                  setDialogState(() => monthsCount = val ?? 1),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('پاشگەزبوونەوە')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تکایە ناوی حجزکەر بنووسە!')),
                        );
                        return;
                      }

                      String customerName = nameController.text.trim();

                      // لێرەدا try / catch زیادکرا بۆ ئەوەی هەر هەڵەیەک ڕوویدا لە کۆنسۆڵدا دەربکەوێت
                      try {
                        if (isRecurring) {
                          int totalWeeks = monthsCount * 4;
                          for (int i = 0; i < totalWeeks; i++) {
                            DateTime nextDate =
                                widget.selectedDate.add(Duration(days: i * 7));
                            String targetKey =
                                "${nextDate.year}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}";

                            DocumentSnapshot docSnap = await FirebaseFirestore
                                .instance
                                .collection('stadium_bookings')
                                .doc(targetKey)
                                .get();

                            Map<String, dynamic> targetDayData = {};
                            if (docSnap.exists && docSnap.data() != null) {
                              targetDayData = Map<String, dynamic>.from(
                                  docSnap.data() as Map);
                            }

                            targetDayData[slot] = {
                              'name': customerName,
                              'isPaid': isPaid,
                              'isFixed': true,
                            };

                            await FirebaseFirestore.instance
                                .collection('stadium_bookings')
                                .doc(targetKey)
                                .set(targetDayData);
                          }
                        } else {
                          dayData[slot] = {
                            'name': customerName,
                            'isPaid': isPaid,
                            'isFixed': false,
                          };

                          await FirebaseFirestore.instance
                              .collection('stadium_bookings')
                              .doc(dateKey)
                              .set(dayData);
                        }

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          // نیشاندانی نامەی سەرکەوتن
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'حجزەکە بە سەرکەوتوویی پاشەکەوت کرا!')),
                          );
                        }
                      } catch (e) {
                        // ئەگەر کێشەیەک لە پەیوەندی یان فایەربەیس هەبێت، لێرەدا دەردەکەوێت
                        print("FIREBASE ERROR: $e");
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('هەڵە ڕوویدا لە پاشەکەوتکردن: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('پاشەکەوتکردن'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editOrDeleteBooking(String dateKey, String slot, Map bookingInfo,
      Map<String, dynamic> dayData) {
    final nameController = TextEditingController(text: bookingInfo['name']);
    bool isPaid = bookingInfo['isPaid'] ?? false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text('دەستکاریکردنی $slot'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'ناوی حجزکەر',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: const Text('پارە واسڵ کراوە (سەح)'),
                      value: isPaid,
                      onChanged: (val) =>
                          setDialogState(() => isPaid = val ?? false),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      try {
                        dayData.remove(slot);
                        await FirebaseFirestore.instance
                            .collection('stadium_bookings')
                            .doc(dateKey)
                            .set(dayData);
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      } catch (e) {
                        print("FIREBASE DELETE ERROR: $e");
                      }
                    },
                    child: const Text('سڕینەوەی حجز',
                        style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        dayData[slot] = {
                          'name': nameController.text.trim(),
                          'isPaid': isPaid,
                          'isFixed': bookingInfo['isFixed'] ?? false,
                        };
                        await FirebaseFirestore.instance
                            .collection('stadium_bookings')
                            .doc(dateKey)
                            .set(dayData);
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      } catch (e) {
                        print("FIREBASE UPDATE ERROR: $e");
                      }
                    },
                    child: const Text('نوێکردنەوە'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String dateKey =
        "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dayName} ($dateKey)'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('stadium_bookings')
              .doc(dateKey)
              .snapshots(),
          builder: (context, snapshot) {
            Map<String, dynamic> dayData = {};
            if (snapshot.hasData && snapshot.data!.exists) {
              dayData = Map<String, dynamic>.from(snapshot.data!.data() as Map);
            }

            return RefreshIndicator(
              onRefresh: () async {},
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  String slot = timeSlots[index];
                  bool isBooked = dayData.containsKey(slot);
                  Map? bookingInfo = isBooked ? Map.from(dayData[slot]) : null;

                  Color tileColor = Colors.grey.shade200;
                  String statusText = 'بەردەستە';
                  IconData icon = Icons.add_circle_outline;

                  if (isBooked) {
                    bool isPaid = bookingInfo?['isPaid'] ?? false;
                    bool isFixed = bookingInfo?['isFixed'] ?? false;

                    tileColor =
                        isPaid ? Colors.green.shade200 : Colors.red.shade200;
                    statusText = isPaid
                        ? 'حجزکراوە (پارە واسڵکراوە${isFixed ? " - سابت" : ""})'
                        : 'حجزکراوە (پارە واسڵنەکراوە${isFixed ? " - سابت" : ""})';
                    icon = isPaid ? Icons.check_circle : Icons.cancel;
                  }

                  return Card(
                    color: tileColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(slot,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: isBooked
                          ? Text(
                              'حجزکەر: ${bookingInfo?['name']} - $statusText')
                          : Text(statusText),
                      leading: Icon(icon,
                          color: isBooked
                              ? (bookingInfo?['isPaid'] == true
                                  ? Colors.green.shade900
                                  : Colors.red.shade900)
                              : Colors.green),
                      trailing: isBooked
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  dayData.remove(slot);
                                  await FirebaseFirestore.instance
                                      .collection('stadium_bookings')
                                      .doc(dateKey)
                                      .set(dayData);
                                } catch (e) {
                                  print("FIREBASE DELETE ERROR: $e");
                                }
                              },
                            )
                          : null,
                      onTap: () {
                        if (!isBooked) {
                          _openBookingDialog(dateKey, slot, dayData);
                        } else {
                          _editOrDeleteBooking(
                              dateKey, slot, bookingInfo!, dayData);
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------- 5. شاشەی "دیتنا خشتێ" ----------------
class WeeklyScheduleScreen extends StatefulWidget {
  const WeeklyScheduleScreen({super.key});

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  bool isMonthlyMode = false;
  late DateTime startDate;
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now().toLocal();
    startDate = DateTime(now.year, now.month, now.day);
    selectedMonth = DateTime(now.year, now.month, 1);
  }

  String getKurdishDayName(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
        return 'شەممە';
      case DateTime.sunday:
        return 'یکشەممە';
      case DateTime.monday:
        return 'دووشەممە';
      case DateTime.tuesday:
        return 'سێشەممە';
      case DateTime.wednesday:
        return 'چوارشەممە';
      case DateTime.thursday:
        return 'پێنجشەممە';
      case DateTime.friday:
        return 'هەیینی';
      default:
        return '';
    }
  }

  void _editBookingInSchedule(String dateKey, String slot, Map bookingInfo,
      Map<String, dynamic> dayData) {
    final nameController = TextEditingController(text: bookingInfo['name']);
    bool isPaid = bookingInfo['isPaid'] ?? false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text('دەستکاریکردنی کاتی $slot'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'ناوی حجزکەر',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: const Text('پارە واسڵ کراوە (سەح)'),
                      value: isPaid,
                      onChanged: (val) =>
                          setDialogState(() => isPaid = val ?? false),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      },
                      child: const Text('پاشگەزبوونەوە')),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        dayData[slot] = {
                          'name': nameController.text.trim(),
                          'isPaid': isPaid,
                          'isFixed': bookingInfo['isFixed'] ?? false,
                        };
                        await FirebaseFirestore.instance
                            .collection('stadium_bookings')
                            .doc(dateKey)
                            .set(dayData);
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      } catch (e) {
                        print("FIREBASE UPDATE ERROR: $e");
                      }
                    },
                    child: const Text('نوێکردنەوە'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> daysToShow = [];
    if (isMonthlyMode) {
      int daysInMonth =
          DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
      daysToShow = List.generate(
        daysInMonth,
        (i) => DateTime(selectedMonth.year, selectedMonth.month, i + 1),
      );
    } else {
      daysToShow = List.generate(
        7,
        (index) => startDate.add(Duration(days: index)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('دیتنا خشتێ'),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blueGrey.shade50,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('هەفتانە'),
                        selected: !isMonthlyMode,
                        onSelected: (selected) {
                          setState(() {
                            isMonthlyMode = false;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('مانگانە'),
                        selected: isMonthlyMode,
                        onSelected: (selected) {
                          setState(() {
                            isMonthlyMode = true;
                          });
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.blueGrey),
                        onPressed: () {
                          setState(() {
                            if (isMonthlyMode) {
                              selectedMonth = DateTime(selectedMonth.year,
                                  selectedMonth.month - 1, 1);
                            } else {
                              startDate =
                                  startDate.subtract(const Duration(days: 7));
                            }
                          });
                        },
                      ),
                      Text(
                        isMonthlyMode
                            ? 'خشتەی مانگی: ${_getKurdishMonthName(selectedMonth.month)} ${selectedMonth.year}'
                            : 'دەستپێکی هەفتە: ${startDate.year}/${startDate.month.toString().padLeft(2, '0')}/${startDate.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Colors.blueGrey),
                        onPressed: () {
                          setState(() {
                            if (isMonthlyMode) {
                              selectedMonth = DateTime(selectedMonth.year,
                                  selectedMonth.month + 1, 1);
                            } else {
                              startDate =
                                  startDate.add(const Duration(days: 7));
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('stadium_bookings')
                    .snapshots(),
                builder: (context, snapshot) {
                  Map<String, Map<String, dynamic>> allBookings = {};
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      allBookings[doc.id] =
                          Map<String, dynamic>.from(doc.data() as Map);
                    }
                  }

                  return RefreshIndicator(
                    onRefresh: () async {},
                    child: ListView.builder(
                      itemCount: daysToShow.length,
                      itemBuilder: (context, index) {
                        DateTime day = daysToShow[index];
                        String dateKey =
                            "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                        String dayName = getKurdishDayName(day.weekday);
                        Map<String, dynamic> dayData =
                            allBookings[dateKey] ?? {};

                        if (dayData.isEmpty) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: ListTile(
                              title: Text('$dayName ($dateKey)',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: const Text('هیچ حجزێک نییە'),
                            ),
                          );
                        }

                        return ExpansionTile(
                          title: Text('$dayName ($dateKey)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle:
                              Text('کاتی حجزکراو: ${dayData.length} کاتژمێر'),
                          children: dayData.entries.map((e) {
                            bool isFixed = e.value['isFixed'] ?? false;
                            bool isPaid = e.value['isPaid'] ?? false;

                            return Container(
                              color: isPaid
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              child: ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    Text(e.key,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isPaid
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isPaid ? 'واسڵکراوە' : 'واسڵنەکراوە',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isPaid
                                              ? Colors.green.shade900
                                              : Colors.red.shade900,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isFixed) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'سابت',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text('ناونیشان: ${e.value['name']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue, size: 20),
                                      onPressed: () => _editBookingInSchedule(
                                          dateKey, e.key, e.value, dayData),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red, size: 20),
                                      onPressed: () async {
                                        try {
                                          dayData.remove(e.key);
                                          await FirebaseFirestore.instance
                                              .collection('stadium_bookings')
                                              .doc(dateKey)
                                              .set(dayData);
                                        } catch (e) {
                                          print("FIREBASE DELETE ERROR: $e");
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
