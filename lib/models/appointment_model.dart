import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final String clientName;
  final String clientPhone;
  final String petName;
  final String petType; // Cão, Gato, Outro
  final String petBreed;
  final String petSize; // Pequeno, Médio, Grande
  final String serviceName; // Banho, Tosa, Banho e Tosa, etc.
  final String groomerName;
  final DateTime dateTime;
  final String status; // Aguardando, Em Banho, Pronto, Entregue
  final double price;
  final String notes;

  Appointment({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.petName,
    required this.petType,
    required this.petBreed,
    required this.petSize,
    required this.serviceName,
    required this.groomerName,
    required this.dateTime,
    required this.status,
    required this.price,
    required this.notes,
  });

  Appointment copyWith({
    String? id,
    String? clientName,
    String? clientPhone,
    String? petName,
    String? petType,
    String? petBreed,
    String? petSize,
    String? serviceName,
    String? groomerName,
    DateTime? dateTime,
    String? status,
    double? price,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      petName: petName ?? this.petName,
      petType: petType ?? this.petType,
      petBreed: petBreed ?? this.petBreed,
      petSize: petSize ?? this.petSize,
      serviceName: serviceName ?? this.serviceName,
      groomerName: groomerName ?? this.groomerName,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      price: price ?? this.price,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientName': clientName,
      'clientPhone': clientPhone,
      'petName': petName,
      'petType': petType,
      'petBreed': petBreed,
      'petSize': petSize,
      'serviceName': serviceName,
      'groomerName': groomerName,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'price': price,
      'notes': notes,
    };
  }

  factory Appointment.fromFirestore(String id, Map<String, dynamic> data) {
    return Appointment(
      id: id,
      clientName: data['clientName'] as String,
      clientPhone: data['clientPhone'] as String,
      petName: data['petName'] as String,
      petType: data['petType'] as String,
      petBreed: data['petBreed'] as String,
      petSize: data['petSize'] as String,
      serviceName: data['serviceName'] as String,
      groomerName: data['groomerName'] as String,
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'] as String,
      price: (data['price'] as num).toDouble(),
      notes: data['notes'] as String,
    );
  }
}
