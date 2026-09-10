import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pastelYellow = Color(0xFFFEFBE9);
    const primaryCaramel = Color(0xFFD4A373);
    const darkSlate = Color(0xFF2A3439);

    final provider = Provider.of<AppointmentProvider>(context);
    final appointments = provider.appointments;

    // Calcular Métricas Financeiras
    double totalRevenue = 0.0;
    double realizedRevenue = 0.0;
    double pendingRevenue = 0.0;

    // Estatísticas de Serviços
    final serviceCounts = <String, int>{};
    // Lista de Clientes únicos
    final clientsMap = <String, String>{}; // clientName -> clientPhone

    for (var app in appointments) {
      totalRevenue += app.price;
      if (app.status == 'Entregue') {
        realizedRevenue += app.price;
      } else {
        pendingRevenue += app.price;
      }

      serviceCounts[app.serviceName] = (serviceCounts[app.serviceName] ?? 0) + 1;

      if (app.clientName.trim().isNotEmpty) {
        clientsMap[app.clientName] = app.clientPhone;
      }
    }

    return Scaffold(
      backgroundColor: pastelYellow,
      appBar: AppBar(
        backgroundColor: pastelYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkSlate),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Relatórios & Clientes',
          style: TextStyle(
            color: darkSlate,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção Financeira
              _buildSectionTitle('Resumo Financeiro (Total)', darkSlate),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFinancialCard(
                      'Realizado',
                      'R\$ ${realizedRevenue.toStringAsFixed(2)}',
                      const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFinancialCard(
                      'Pendente',
                      'R\$ ${pendingRevenue.toStringAsFixed(2)}',
                      const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFinancialCard(
                'Faturamento Total (Histórico)',
                'R\$ ${totalRevenue.toStringAsFixed(2)}',
                primaryCaramel,
                isWide: true,
              ),
              const SizedBox(height: 24),

              // Seção Serviços Populares
              _buildSectionTitle('Distribuição de Serviços', darkSlate),
              const SizedBox(height: 12),
              serviceCounts.isEmpty
                  ? _buildEmptyText('Sem dados de serviços disponíveis.')
                  : Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: serviceCounts.entries.map((entry) {
                          final percent = appointments.isEmpty
                              ? 0.0
                              : (entry.value / appointments.length);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    entry.key,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: darkSlate,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percent,
                                      backgroundColor: Colors.grey.shade100,
                                      color: primaryCaramel,
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${entry.value} (${(percent * 100).toStringAsFixed(0)}%)',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
              const SizedBox(height: 24),

              // Seção Diretório de Clientes
              _buildSectionTitle('Diretório de Clientes (${clientsMap.length})', darkSlate),
              const SizedBox(height: 12),
              clientsMap.isEmpty
                  ? _buildEmptyText('Nenhum cliente cadastrado ainda.')
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: clientsMap.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final name = clientsMap.keys.elementAt(index);
                          final phone = clientsMap[name]!;
                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: primaryCaramel.withOpacity(0.1),
                                child: const Icon(Icons.person, color: primaryCaramel),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: darkSlate,
                                ),
                              ),
                              subtitle: Text(phone),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Cliente: $name • Tel: $phone'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.phone_forwarded, color: primaryCaramel),
                                tooltip: 'Ligar para Cliente',
                                onPressed: () {
                                  // Apenas feedback visual (ou integração futura com url_launcher)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Ligando para $name ($phone)...'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildFinancialCard(
    String label,
    String value,
    Color color, {
    bool isWide = false,
  }) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
