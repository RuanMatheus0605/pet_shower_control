import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_shower_control/models/appointment_model.dart';

void main() {
  final dateTime = DateTime(2026, 10, 26, 14, 30);
  final appointment = Appointment(
    id: 'appointment-1',
    clientName: 'Maria Silva',
    clientPhone: '(11) 99999-9999',
    petName: 'Thor',
    petType: 'Cão',
    petBreed: 'Vira-lata',
    petSize: 'Médio',
    serviceName: 'Banho e Tosa',
    groomerName: 'Ana Flávia',
    dateTime: dateTime,
    status: 'Aguardando',
    price: 85,
    notes: 'Usar shampoo neutro',
  );

  test('serializes appointment dates as Firestore timestamps', () {
    final data = appointment.toFirestore();

    expect(data['dateTime'], Timestamp.fromDate(dateTime));
    expect(data, isNot(contains('id')));
    expect(data['petName'], 'Thor');
    expect(data['price'], 85);
  });

  test('builds an appointment using the Firestore document ID', () {
    final restored = Appointment.fromFirestore('document-id', {
      ...appointment.toFirestore(),
      'price': 85,
    });

    expect(restored.id, 'document-id');
    expect(restored.petName, appointment.petName);
    expect(restored.dateTime, dateTime);
    expect(restored.price, 85);
    expect(restored.status, appointment.status);
  });
}
