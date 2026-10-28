import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/appointment_model.dart';
import '../services/appointment_repository.dart';

class AppointmentProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  final AppointmentRepository _repository;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Appointment>>? _subscription;
  String? _uid;
  List<Appointment> _appointments = [];
  final Set<String> _updatingAppointmentIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  AppointmentProvider({FirebaseAuth? auth, AppointmentRepository? repository})
    : _auth = auth ?? FirebaseAuth.instance,
      _repository = repository ?? AppointmentRepository() {
    _uid = _auth.currentUser?.uid;
    final uid = _uid;
    if (uid != null) {
      _listenForAppointments(uid);
    } else {
      _isLoading = false;
    }

    _authSubscription = _auth.authStateChanges().listen(
      _handleAuthChange,
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = userFriendlyError(error);
        notifyListeners();
      },
    );
  }

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isUpdating(String id) => _updatingAppointmentIds.contains(id);

  void _handleAuthChange(User? user) {
    final uid = user?.uid;
    if (uid == _uid) return;

    _uid = uid;
    _appointments = [];
    _errorMessage = null;
    _subscription?.cancel();
    _subscription = null;

    if (uid == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    _listenForAppointments(uid);
  }

  void _listenForAppointments(String uid) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _subscription = _repository
        .watchAppointments(uid)
        .listen(
          (appointments) {
            _appointments = appointments;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (Object error) {
            _isLoading = false;
            _errorMessage = userFriendlyError(error);
            notifyListeners();
          },
        );
  }

  Future<void> retry() async {
    await _subscription?.cancel();
    final uid = _uid;
    if (uid != null) _listenForAppointments(uid);
  }

  Future<void> addAppointment(Appointment appointment) {
    return _repository.addAppointment(_requireUid(), appointment);
  }

  Future<void> updateAppointment(Appointment appointment) {
    return _repository.updateAppointment(_requireUid(), appointment);
  }

  Future<void> updateStatus(String id, String newStatus) async {
    if (!_updatingAppointmentIds.add(id)) return;
    notifyListeners();
    try {
      await _repository.updateStatus(_requireUid(), id, newStatus);
    } finally {
      _updatingAppointmentIds.remove(id);
      notifyListeners();
    }
  }

  Future<void> deleteAppointment(String id) {
    return _repository.deleteAppointment(_requireUid(), id);
  }

  String _requireUid() {
    final uid = _uid;
    if (uid == null) {
      throw StateError('A sessão do usuário não está autenticada.');
    }
    return uid;
  }

  String userFriendlyError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
        case 'unauthenticated':
          return 'Sua sessão não tem permissão para acessar estes agendamentos. Entre novamente.';
        case 'unavailable':
        case 'network-request-failed':
          return 'Não foi possível conectar ao Firestore. Verifique sua internet e tente novamente.';
        case 'not-found':
          return 'O agendamento não foi encontrado. Atualize a lista e tente novamente.';
      }
    }
    return 'Não foi possível concluir a operação. Tente novamente.';
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
      'Siamês',
    };
    for (var app in _appointments) {
      if (app.petBreed.trim().isNotEmpty) {
        set.add(app.petBreed);
      }
    }
    return set.toList()..sort();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
