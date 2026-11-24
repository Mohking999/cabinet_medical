import 'package:flutter/material.dart';
import '../models/rendez_vous.dart';
import '../services/repository_provider.dart';
import 'rendez_vous_tab.dart';
import 'salle_attente_tab.dart';
import 'consultation_tab.dart';
import 'facturation_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  RendezVous? _rdvPourConsultation;

  void _onDataChanged() {
    setState(() {});
  }

  void _appelerEnConsultation(RendezVous rdv) {
    setState(() {
      _rdvPourConsultation = rdv;
      _currentIndex = 2; // Basculer vers l'onglet Consultations
    });
  }

  void _onConsultationTerminee() {
    setState(() {
      _rdvPourConsultation = null;
      _currentIndex = 3; // Basculer vers l'onglet Facturation
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      RendezVousTab(onDataChanged: _onDataChanged),
      SalleAttenteTab(
        onAppelerEnConsultation: _appelerEnConsultation,
        onDataChanged: _onDataChanged,
      ),
      ConsultationTab(
        rdvActif: _rdvPourConsultation,
        onConsultationTerminee: _onConsultationTerminee,
      ),
      FacturationTab(onDataChanged: _onDataChanged),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.teal),
            SizedBox(width: 10),
            Text(
              'Cabinet Médical',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Sélecteur de source de données (Base Locale SQLite / API Distante)
          PopupMenuButton<bool>(
            tooltip: 'Source des données',
            icon: Icon(
              RepositoryProvider.useRemoteApi ? Icons.cloud_done : Icons.storage,
              color: RepositoryProvider.useRemoteApi ? Colors.blue : Colors.teal,
            ),
            onSelected: (bool useApi) {
              setState(() {
                RepositoryProvider.useRemoteApi = useApi;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Source active : ${RepositoryProvider.sourceActiveNom}'),
                ),
              );
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: false,
                child: Row(
                  children: [
                    Icon(Icons.storage, color: !RepositoryProvider.useRemoteApi ? Colors.teal : Colors.grey),
                    const SizedBox(width: 10),
                    const Text('Base Locale SQLite'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: true,
                child: Row(
                  children: [
                    Icon(Icons.cloud, color: RepositoryProvider.useRemoteApi ? Colors.blue : Colors.grey),
                    const SizedBox(width: 10),
                    const Text('API Distante (Web/REST)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Rendez-vous',
          ),
          NavigationDestination(
            icon: Icon(Icons.hourglass_empty_outlined),
            selectedIcon: Icon(Icons.hourglass_full),
            label: 'Salle d\'attente',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: 'Consultation',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Facturation',
          ),
        ],
      ),
    );
  }
}
