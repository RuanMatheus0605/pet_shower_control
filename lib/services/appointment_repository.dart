import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment_model.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore;

  AppointmentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userAppointments(String uid) {
    return _firestore.collection('users').doc(uid).collection('appointments');
  }

  Stream<List<Appointment>> watchAppointments(String uid) {
    return _userAppointments(uid)
        .orderBy('dateTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) =>
                    Appointment.fromFirestore(document.id, document.data()),
              )
              .toList(),
        );
  }

  Future<void> addAppointment(String uid, Appointment appointment) async {
    final now = FieldValue.serverTimestamp();
    await _userAppointments(uid).add({
      ...appointment.toFirestore(),
      'ownerUid': uid,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> updateAppointment(String uid, Appointment appointment) async {
    await _userAppointments(uid).doc(appointment.id).update({
      ...appointment.toFirestore(),
      'ownerUid': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String uid, String id, String status) async {
    await _userAppointments(uid).doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAppointment(String uid, String id) async {
    await _userAppointments(uid).doc(id).delete();
  }
}
