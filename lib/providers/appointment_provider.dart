import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/storage_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;

  AppointmentProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();
    _appointments = await _storageService.loadAppointments();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAppointment(Appointment appointment) async {
    _appointments.add(appointment);
    // Ordenar agendamentos por data/hora
    _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    notifyListeners();
    await _storageService.saveAppointments(_appointments);
  }

  Future<void> updateAppointment(Appointment updated) async {
    final index = _appointments.indexWhere((app) => app.id == updated.id);
    if (index != -1) {
      _appointments[index] = updated;
      _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      notifyListeners();
      await _storageService.saveAppointments(_appointments);
    }
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final index = _appointments.indexWhere((app) => app.id == id);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(status: newStatus);
      notifyListeners();
      await _storageService.saveAppointments(_appointments);
    }
  }

  Future<void> deleteAppointment(String id) async {
    _appointments.removeWhere((app) => app.id == id);
    notifyListeners();
    await _storageService.saveAppointments(_appointments);
  }

  // Obter profissionais cadastrados (extraído dos agendamentos + padrão)
  List<String> get groomers {
    final set = <String>{'Ana Flávia', 'Bruno Lima', 'Carlos Souza'};
    for (var app in _appointments) {
      if (app.groomerName.trim().isNotEmpty) {
        set.add(app.groomerName);
      }
    }
    return set.toList()..sort();
  }

  // Obter raças cadastradas (padrão + registradas)
  List<String> get breeds {
    final set = <String>{
      'Vira-lata (SRD)',
      'Shih Tzu',
      'Poodle',
      'Golden Retriever',
      'Yorkshire',
      'Spitz Alemão',
      'Pinscher',
      'Bulldog Francês',
      'Persa',
      'Siamês'
    };
    for (var app in _appointments) {
      if (app.petBreed.trim().isNotEmpty) {
        set.add(app.petBreed);
      }
    }
    return set.toList()..sort();
  }
}
