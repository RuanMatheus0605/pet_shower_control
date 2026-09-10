import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';

class AddAppointmentScreen extends StatefulWidget {
  final Appointment? appointment; // Se preenchido, modo edição
  final DateTime? initialDate;

  const AddAppointmentScreen({super.key, this.appointment, this.initialDate});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _clientName;
  late String _clientPhone;
  late String _petName;
  late String _petType;
  late String _petBreed;
  late String _petSize;
  late String _serviceName;
  late String _groomerName;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late double _price;
  late String _notes;
  late String _status;

  final List<String> _petTypes = ['Cão', 'Gato', 'Outro'];
  final List<String> _petSizes = ['Pequeno', 'Médio', 'Grande'];
  final List<String> _services = ['Banho', 'Tosa', 'Banho e Tosa', 'Hidratação', 'Outro'];
  final List<String> _statuses = ['Aguardando', 'Em Banho', 'Pronto', 'Entregue'];

  @override
  void initState() {
    super.initState();
    final app = widget.appointment;
    if (app != null) {
      _clientName = app.clientName;
      _clientPhone = app.clientPhone;
      _petName = app.petName;
      _petType = _petTypes.contains(app.petType) ? app.petType : 'Cão';
      _petBreed = app.petBreed;
      _petSize = _petSizes.contains(app.petSize) ? app.petSize : 'Pequeno';
      _serviceName = _services.contains(app.serviceName) ? app.serviceName : 'Banho';
      _groomerName = app.groomerName;
      _selectedDate = app.dateTime;
      _selectedTime = TimeOfDay(hour: app.dateTime.hour, minute: app.dateTime.minute);
      _price = app.price;
      _notes = app.notes;
      _status = app.status;
    } else {
      _clientName = '';
      _clientPhone = '';
      _petName = '';
      _petType = 'Cão';
      _petBreed = '';
      _petSize = 'Pequeno';
      _serviceName = 'Banho';
      _groomerName = '';
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedTime = const TimeOfDay(hour: 9, minute: 0);
      _price = 0.0;
      _notes = '';
      _status = 'Aguardando';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD4A373),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2A3439),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD4A373),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2A3439),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  String _capitalize(String text) {
    if (text.trim().isEmpty) return '';
    return text.trim().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final formattedClientName = _capitalize(_clientName);
    final formattedPetName = _capitalize(_petName);
    final formattedPetBreed = _capitalize(_petBreed);
    final formattedGroomerName = _capitalize(_groomerName);

    if (widget.appointment != null) {
      final updated = widget.appointment!.copyWith(
        clientName: formattedClientName,
        clientPhone: _clientPhone,
        petName: formattedPetName,
        petType: _petType,
        petBreed: formattedPetBreed,
        petSize: _petSize,
        serviceName: _serviceName,
        groomerName: formattedGroomerName,
        dateTime: dateTime,
        price: _price,
        notes: _notes,
        status: _status,
      );
      provider.updateAppointment(updated);
    } else {
      final newApp = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientName: formattedClientName,
        clientPhone: _clientPhone,
        petName: formattedPetName,
        petType: _petType,
        petBreed: formattedPetBreed,
        petSize: _petSize,
        serviceName: _serviceName,
        groomerName: formattedGroomerName,
        dateTime: dateTime,
        price: _price,
        notes: _notes,
        status: _status,
      );
      provider.addAppointment(newApp);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.appointment != null
            ? 'Agendamento atualizado com sucesso!'
            : 'Agendamento criado com sucesso!'),
        backgroundColor: const Color(0xFF059669),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pastelYellow = Color(0xFFFEFBE9);
    const primaryCaramel = Color(0xFFD4A373);
    const darkSlate = Color(0xFF2A3439);

    final provider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      backgroundColor: pastelYellow,
      appBar: AppBar(
        backgroundColor: pastelYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkSlate),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.appointment != null ? 'Editar Agendamento' : 'Novo Agendamento',
          style: const TextStyle(
            color: darkSlate,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Dados do Tutor', darkSlate),
                  const SizedBox(height: 8),
                  _buildTextField(
                    label: 'Nome do Cliente',
                    initialValue: _clientName,
                    icon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    onSaved: (val) => _clientName = val ?? '',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Insira o nome do cliente';
                      if (val.trim().length < 3) return 'Nome deve conter ao menos 3 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Telefone de Contato',
                    initialValue: _clientPhone,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [TelefoneInputFormatter()],
                    onSaved: (val) => _clientPhone = val ?? '',
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Insira o telefone';
                      final cleanVal = val.replaceAll(RegExp(r'\D'), '');
                      if (cleanVal.length < 10) return 'O telefone deve ter pelo menos 10 dígitos';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Dados do Pet', darkSlate),
                  const SizedBox(height: 8),
                  _buildTextField(
                    label: 'Nome do Pet',
                    initialValue: _petName,
                    icon: Icons.pets_outlined,
                    textCapitalization: TextCapitalization.words,
                    onSaved: (val) => _petName = val ?? '',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Insira o nome do pet';
                      if (val.trim().length < 2) return 'Nome deve conter ao menos 2 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Espécie',
                          value: _petType,
                          items: _petTypes,
                          onChanged: (val) => setState(() => _petType = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Porte',
                          value: _petSize,
                          items: _petSizes,
                          onChanged: (val) => setState(() => _petSize = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Breed Autocomplete
                  _buildAutocompleteField(
                    label: 'Raça do Pet',
                    initialValue: _petBreed,
                    suggestions: provider.breeds,
                    icon: Icons.search,
                    onSaved: (val) => _petBreed = val ?? '',
                    validator: (val) => val == null || val.isEmpty ? 'Insira a raça' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle('Serviço e Agendamento', darkSlate),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Serviço',
                          value: _serviceName,
                          items: _services,
                          onChanged: (val) => setState(() => _serviceName = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Valor (R\$)',
                          initialValue: widget.appointment != null ? _price.toString() : '',
                          icon: Icons.monetization_on_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onSaved: (val) => _price = double.tryParse(val ?? '0') ?? 0.0,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Insira o valor';
                            if (double.tryParse(val) == null) return 'Valor inválido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildAutocompleteField(
                    label: 'Profissional / Tosa',
                    initialValue: _groomerName,
                    suggestions: provider.groomers,
                    icon: Icons.face_outlined,
                    onSaved: (val) => _groomerName = val ?? '',
                    validator: (val) => val == null || val.isEmpty ? 'Selecione ou insira o profissional' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          child: _buildDateTimePickerCard(
                            label: 'Data',
                            value: DateFormat('dd/MM/yyyy').format(_selectedDate),
                            icon: Icons.calendar_today,
                            primaryColor: primaryCaramel,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _pickTime,
                          child: _buildDateTimePickerCard(
                            label: 'Horário',
                            value: _selectedTime.format(context),
                            icon: Icons.access_time,
                            primaryColor: primaryCaramel,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (widget.appointment != null) ...[
                    _buildDropdownField(
                      label: 'Status do Atendimento',
                      value: _status,
                      items: _statuses,
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                    const SizedBox(height: 12),
                  ],

                  _buildTextField(
                    label: 'Observações / Instruções Especiais',
                    initialValue: _notes,
                    icon: Icons.note_alt_outlined,
                    maxLines: 3,
                    onSaved: (val) => _notes = val ?? '',
                  ),
                  const SizedBox(height: 32),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCaramel,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.appointment != null ? 'Salvar Alterações' : 'Confirmar Agendamento',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color.withOpacity(0.8),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onSaved: onSaved,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFD4A373)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD4A373)),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD4A373)),
        ),
      ),
    );
  }

  Widget _buildAutocompleteField({
    required String label,
    required String initialValue,
    required List<String> suggestions,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return RawAutocomplete<String>(
      initialValue: TextEditingValue(text: initialValue),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return suggestions;
        }
        return suggestions.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
          FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          onSaved: onSaved,
          validator: validator,
          textCapitalization: TextCapitalization.words,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: const Color(0xFFD4A373)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD4A373)),
            ),
          ),
        );
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected,
          Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateTimePickerCard({
    required String label,
    required String value,
    required IconData icon,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A3439),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 11) {
      return oldValue;
    }
    String formatted = '';
    if (text.isNotEmpty) {
      formatted += '(';
      if (text.length <= 2) {
        formatted += text;
      } else {
        formatted += '${text.substring(0, 2)}) ';
        if (text.length <= 7) {
          formatted += text.substring(2);
        } else {
          formatted += '${text.substring(2, 7)}-${text.substring(7)}';
        }
      }
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

