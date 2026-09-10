import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/appointment_model.dart';

class StorageService {
  static const String _fileName = 'appointments.json';

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<List<Appointment>> loadAppointments() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents) as List<dynamic>;
      return jsonList
          .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Retorna uma lista vazia caso ocorra algum erro na leitura/desserialização
      return [];
    }
  }

  Future<void> saveAppointments(List<Appointment> appointments) async {
    try {
      final file = await _getLocalFile();
      final jsonList = appointments.map((app) => app.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (_) {
      // Ignora erro ou trata silenciosamente
    }
  }
}
