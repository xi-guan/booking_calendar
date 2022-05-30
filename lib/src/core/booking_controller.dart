import 'package:booking_calendar/src/model/booking_service.dart';
import 'package:booking_calendar/src/util/booking_util.dart';
import 'package:flutter/material.dart';

class BookingController extends ChangeNotifier {
  BookingService bookingSvc;
  BookingController({required this.bookingSvc}) {
    serviceOpening = bookingSvc.bookingStart;
    serviceClosing = bookingSvc.bookingEnd;
    if (serviceOpening!.isAfter(serviceClosing!)) {
      throw "Service closing must be after opening";
    }
    base = serviceOpening!;
    _generateBookingSlots();
  }

  late DateTime base;

  DateTime? serviceOpening;
  DateTime? serviceClosing;

  List<DateTime> _allBookingSlots = [];
  List<DateTime> get allBookingSlots => _allBookingSlots;

  List<DateTimeRange> bookedSlots = [];

  int _selectedSlot = (-1);
  bool _isUploading = false;

  int get selectedSlot => _selectedSlot;
  bool get isUploading => _isUploading;

  void _generateBookingSlots() {
    allBookingSlots.clear();
    _allBookingSlots = List.generate(
        _maxServiceFitInADay(), (index) => base.add(Duration(minutes: bookingSvc.serviceDuration) * index));
  }

  int _maxServiceFitInADay() {
    ///if no serviceOpening and closing was provided we will calculate with 00:00-24:00
    int openingHours = 24;
    if (serviceOpening != null && serviceClosing != null) {
      openingHours = DateTimeRange(start: serviceOpening!, end: serviceClosing!).duration.inHours;
    }

    ///round down if not the whole service would fit in the last hours
    return ((openingHours * 60) / bookingSvc.serviceDuration).floor();
  }

  bool isSlotBooked(int index) {
    DateTime checkSlot = allBookingSlots.elementAt(index);
    bool result = false;
    for (var slot in bookedSlots) {
      if (BookingUtil.isOverLapping(
        slot.start,
        slot.end,
        checkSlot,
        checkSlot.add(Duration(minutes: bookingSvc.serviceDuration)),
      )) {
        result = true;
        break;
      }
    }
    return result;
  }

  void selectSlot(int idx) {
    _selectedSlot = idx;
    notifyListeners();
  }

  void resetSelectedSlot() {
    _selectedSlot = -1;
    notifyListeners();
  }

  void toggleUploading() {
    _isUploading = !_isUploading;
    notifyListeners();
  }

  Future<void> generateBookedSlots(List<DateTimeRange> data) async {
    bookedSlots.clear();
    _generateBookingSlots();

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      bookedSlots.add(item);
    }
  }

  BookingService generateNewBookingForUploading() {
    final bookingDate = allBookingSlots.elementAt(selectedSlot);
    bookingSvc
      ..bookingStart = (bookingDate)
      ..bookingEnd = (bookingDate.add(Duration(minutes: bookingSvc.serviceDuration)));
    return bookingSvc;
  }
}
