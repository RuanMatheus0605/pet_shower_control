import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import 'add_appointment_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  String _statusFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context);
    final allAppointments = provider.appointments;

    // Filtrar agendamentos pela data selecionada
    final dailyAppointments = allAppointments.where((app) {
      return app.dateTime.year == _selectedDate.year &&
          app.dateTime.month == _selectedDate.month &&
          app.dateTime.day == _selectedDate.day;
    }).toList();

    // Filtrar por status
    final filteredAppointments = dailyAppointments.where((app) {
      if (_statusFilter == 'Todos') return true;
      return app.status == _statusFilter;
    }).toList();

    // Calcular métricas do dia
    final totalCount = dailyAppointments.length;
    final waitingCount = dailyAppointments.where((a) => a.status == 'Aguardando').length;
    final inProgressCount = dailyAppointments.where((a) => a.status == 'Em Banho').length;
    final doneCount = dailyAppointments.where((a) => a.status == 'Pronto').length;
    final deliveredCount = dailyAppointments.where((a) => a.status == 'Entregue').length;

    // Cores de tema
    const pastelYellow = Color(0xFFFEFBE9);
    const primaryCaramel = Color(0xFFD4A373);
    const darkSlate = Color(0xFF2A3439);

    return Scaffold(
      backgroundColor: pastelYellow,
      appBar: AppBar(
        backgroundColor: pastelYellow,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.pets, color: primaryCaramel, size: 28),
            SizedBox(width: 8),
            Text(
              'Pet Shower Control',
              style: TextStyle(
                color: darkSlate,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: darkSlate, size: 28),
            tooltip: 'Relatórios e Finanças',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seletor de Data Horizontal
            _buildDatePicker(pastelYellow, primaryCaramel, darkSlate),

            // Métricas Rápidas
            _buildMetricsRow(
              totalCount: totalCount,
              waiting: waitingCount,
              inProgress: inProgressCount,
              done: doneCount,
              delivered: deliveredCount,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Filtro por Status',
                style: TextStyle(
                  color: darkSlate,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            // Filtros por Status (Chips)
            _buildStatusFilters(darkSlate, primaryCaramel),

            // Lista de Agendamentos do Dia
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryCaramel))
                  : filteredAppointments.isEmpty
                      ? _buildEmptyState(darkSlate)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = filteredAppointments[index];
                            return _buildAppointmentCard(context, provider, appointment, darkSlate, primaryCaramel);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddAppointmentScreen(initialDate: _selectedDate),
            ),
          );
        },
        backgroundColor: primaryCaramel,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Agendamento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget para seletor de data horizontal (Últimos 3 dias e próximos 7 dias)
  Widget _buildDatePicker(Color background, Color primaryColor, Color textColor) {
    final today = DateTime.now();
    final dates = List.generate(11, (index) => today.add(Duration(days: index - 3)));

    return Container(
      height: 95,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final dayName = DateFormat('EEE', 'pt_BR').format(date).toUpperCase().replaceAll('.', '');
          final dayNum = DateFormat('dd').format(date);
          final isToday = DateUtils.isSameDay(date, today);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : (isToday ? primaryColor.withOpacity(0.5) : Colors.grey.shade200),
                  width: isToday ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayNum,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Row de métricas com rolagem horizontal
  Widget _buildMetricsRow({
    required int totalCount,
    required int waiting,
    required int inProgress,
    required int done,
    required int delivered,
  }) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildMetricCard('Total', totalCount.toString(), Colors.blueGrey),
          _buildMetricCard('Aguardando', waiting.toString(), const Color(0xFFD97706)),
          _buildMetricCard('Em Banho', inProgress.toString(), const Color(0xFF3B82F6)),
          _buildMetricCard('Pronto', done.toString(), const Color(0xFF10B981)),
          _buildMetricCard('Entregue', delivered.toString(), Colors.grey),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Filtros de status em horizontal chip
  Widget _buildStatusFilters(Color darkSlate, Color primaryCaramel) {
    final statusList = ['Todos', 'Aguardando', 'Em Banho', 'Pronto', 'Entregue'];

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: statusList.length,
        itemBuilder: (context, index) {
          final status = statusList[index];
          final isSelected = _statusFilter == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _statusFilter = status;
                  });
                }
              },
              selectedColor: primaryCaramel.withOpacity(0.2),
              checkmarkColor: primaryCaramel,
              labelStyle: TextStyle(
                color: isSelected ? primaryCaramel : darkSlate,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? primaryCaramel : Colors.grey.shade200,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Estado vazio
  Widget _buildEmptyState(Color darkSlate) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nenhum agendamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Não há sessões registradas para o dia ${DateFormat('dd/MM/yyyy').format(_selectedDate)} com os filtros selecionados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card do agendamento
  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentProvider provider,
    Appointment appointment,
    Color darkSlate,
    Color primaryCaramel,
  ) {
    // Definir as cores com base no status do pet
    Color statusBgColor;
    Color statusTextColor;
    IconData statusIcon;

    switch (appointment.status) {
      case 'Aguardando':
        statusBgColor = const Color(0xFFFEF3C7); // Amber suave
        statusTextColor = const Color(0xFFD97706);
        statusIcon = Icons.hourglass_empty;
        break;
      case 'Em Banho':
        statusBgColor = const Color(0xFFDBEAFE); // Blue suave
        statusTextColor = const Color(0xFF2563EB);
        statusIcon = Icons.bubble_chart;
        break;
      case 'Pronto':
        statusBgColor = const Color(0xFFD1FAE5); // Green suave
        statusTextColor = const Color(0xFF059669);
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Entregue':
      default:
        statusBgColor = const Color(0xFFF3F4F6); // Grey suave
        statusTextColor = const Color(0xFF4B5563);
        statusIcon = Icons.home;
        break;
    }

    final petIcon = appointment.petType.toLowerCase() == 'gato' ? Icons.pets : Icons.pets;
    final timeStr = DateFormat('HH:mm').format(appointment.dateTime);

    return Card(
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Abrir tela para editar agendamento
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddAppointmentScreen(appointment: appointment),
              ),
            );
          },
          onLongPress: () {
            _showDeleteConfirmation(context, provider, appointment);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha Superior: Pet Name, Tipo e Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryCaramel.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          petIcon,
                          color: primaryCaramel,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.petName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkSlate,
                            ),
                          ),
                          Text(
                            '${appointment.petBreed} • ${appointment.petSize}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusTextColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          appointment.status,
                          style: TextStyle(
                            color: statusTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 0.5),

              // Detalhes do agendamento (Horário, Serviço, Groomer e Valor)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: darkSlate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.cut_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            appointment.serviceName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: darkSlate,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            appointment.groomerName,
                            style: TextStyle(
                              fontSize: 14,
                              color: darkSlate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'R\$ ${appointment.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: darkSlate,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Tutor info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Tutor: ${appointment.clientName} (${appointment.clientPhone})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),

              if (appointment.notes.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Obs: ${appointment.notes}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              // Ações Rápidas de Alteração de Status
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Atualizar status:',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusTransitionButtons(provider, appointment, primaryCaramel),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  // Botões rápidos de mudança de status
  Widget _buildStatusTransitionButtons(
    AppointmentProvider provider,
    Appointment appointment,
    Color primaryColor,
  ) {
    if (appointment.status == 'Aguardando') {
      return TextButton.icon(
        onPressed: () => provider.updateStatus(appointment.id, 'Em Banho'),
        icon: const Icon(Icons.play_arrow, size: 16),
        label: const Text('Iniciar Banho'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF2563EB),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    } else if (appointment.status == 'Em Banho') {
      return TextButton.icon(
        onPressed: () => provider.updateStatus(appointment.id, 'Pronto'),
        icon: const Icon(Icons.check, size: 16),
        label: const Text('Finalizar'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF059669),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    } else if (appointment.status == 'Pronto') {
      return TextButton.icon(
        onPressed: () => provider.updateStatus(appointment.id, 'Entregue'),
        icon: const Icon(Icons.card_giftcard, size: 16),
        label: const Text('Entregar ao Tutor'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF4B5563),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    } else {
      // Já está entregue, sem ação rápida necessária além de poder reabrir se necessário
      return TextButton.icon(
        onPressed: () => provider.updateStatus(appointment.id, 'Aguardando'),
        icon: const Icon(Icons.refresh, size: 16),
        label: const Text('Reabrir'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
  }

  // Confirmação para excluir
  void _showDeleteConfirmation(
    BuildContext context,
    AppointmentProvider provider,
    Appointment appointment,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Agendamento'),
        content: Text('Tem certeza que deseja excluir o agendamento de ${appointment.petName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteAppointment(appointment.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Agendamento de ${appointment.petName} excluído.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
