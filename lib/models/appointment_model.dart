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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'petName': petName,
      'petType': petType,
      'petBreed': petBreed,
      'petSize': petSize,
      'serviceName': serviceName,
      'groomerName': groomerName,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'price': price,
      'notes': notes,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      clientName: json['clientName'] as String,
      clientPhone: json['clientPhone'] as String,
      petName: json['petName'] as String,
      petType: json['petType'] as String,
      petBreed: json['petBreed'] as String,
      petSize: json['petSize'] as String,
      serviceName: json['serviceName'] as String,
      groomerName: json['groomerName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      status: json['status'] as String,
      price: (json['price'] as num).toDouble(),
      notes: json['notes'] as String,
    );
  }
}
