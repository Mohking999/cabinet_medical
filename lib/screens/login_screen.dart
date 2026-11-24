import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/repository_provider.dart';
import 'client_home_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifiantCtrl = TextEditingController(text: 'dr.benali@cabinet.dz');
  final _passwordCtrl = TextEditingController(text: '123456');
  bool _obscurePassword = true;
  String _selectedRole = 'Médecin'; // 'Médecin', 'Secrétaire', ou 'Patient'
  bool _isLoading = false;

  @override
  void dispose() {
    _identifiantCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _seConnecter() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_selectedRole == 'Patient') {
      // Récupérer le patient depuis la base de données
      final patients = await RepositoryProvider.repository.getPatients();
      final Patient patientConnecte;
      if (patients.isNotEmpty) {
        patientConnecte = patients.first;
      } else {
        patientConnecte = Patient(
          id: 1,
          nom: 'Bouzid',
          prenom: 'Karim',
          telephone: '05 50 12 34 56',
          numeroSecu: '01 85 16 012 345 (CNAS)',
          dateNaissance: '14/04/1985',
          antecedents: 'Hypertension artérielle',
          allergies: 'Pénicilline',
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ClientHomeScreen(patient: patientConnecte),
        ),
      );
    } else {
      final nomAffiche = _selectedRole == 'Médecin' ? 'Dr. Benali' : 'Secrétariat Médical';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            nomUtilisateur: nomAffiche,
            roleUtilisateur: _selectedRole,
          ),
        ),
      );
    }
  }

  void _connexionRapide(String role) {
    setState(() {
      _selectedRole = role;
      if (role == 'Médecin') {
        _identifiantCtrl.text = 'dr.benali@cabinet.dz';
        _passwordCtrl.text = '123456';
      } else if (role == 'Secrétaire') {
        _identifiantCtrl.text = 'secretaire@cabinet.dz';
        _passwordCtrl.text = '123456';
      } else {
        _identifiantCtrl.text = 'karim.bouzid@patient.dz';
        _passwordCtrl.text = '123456';
      }
    });
    _seConnecter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête / Logo médical
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.teal.shade300, width: 2),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        size: 44,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cabinet Médical',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004D40),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        '🇩🇿 Algérie • Carte Chifa & CNAS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Carte de formulaire de connexion
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Authentification',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Text(
                              'Accédez à votre espace praticien, secrétariat ou patient (client)',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),

                            // Sélecteur de rôle (Médecin, Secrétaire ou Patient)
                            const Text(
                              'Rôle / Profil :',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                ChoiceChip(
                                  avatar: const Icon(Icons.medical_services, size: 16),
                                  label: const Text('Médecin'),
                                  selected: _selectedRole == 'Médecin',
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedRole = 'Médecin';
                                        _identifiantCtrl.text = 'dr.benali@cabinet.dz';
                                      });
                                    }
                                  },
                                  selectedColor: Colors.teal.shade100,
                                ),
                                ChoiceChip(
                                  avatar: const Icon(Icons.person, size: 16),
                                  label: const Text('Secrétaire'),
                                  selected: _selectedRole == 'Secrétaire',
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedRole = 'Secrétaire';
                                        _identifiantCtrl.text = 'secretaire@cabinet.dz';
                                      });
                                    }
                                  },
                                  selectedColor: Colors.teal.shade100,
                                ),
                                ChoiceChip(
                                  avatar: const Icon(Icons.badge, size: 16),
                                  label: const Text('Patient (Client)'),
                                  selected: _selectedRole == 'Patient',
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedRole = 'Patient';
                                        _identifiantCtrl.text = 'karim.bouzid@patient.dz';
                                      });
                                    }
                                  },
                                  selectedColor: Colors.teal.shade100,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Champ Identifiant / Email
                            TextFormField(
                              controller: _identifiantCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Identifiant ou Email *',
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Veuillez saisir votre identifiant';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Champ Mot de passe
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe *',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                isDense: true,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Veuillez saisir votre mot de passe';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Bouton Se connecter
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _isLoading ? null : _seConnecter,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Se connecter',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Accès rapide de démonstration
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Accès Démo 1-Clic',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.medical_services, size: 15),
                        label: const Text('Dr. Benali', style: TextStyle(fontSize: 12)),
                        onPressed: () => _connexionRapide('Médecin'),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.support_agent, size: 15),
                        label: const Text('Secrétaire', style: TextStyle(fontSize: 12)),
                        onPressed: () => _connexionRapide('Secrétaire'),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.person, size: 15),
                        label: const Text('Patient (Karim)', style: TextStyle(fontSize: 12)),
                        onPressed: () => _connexionRapide('Patient'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Système d\'Information Médical Algérien\nConforme Carte Chifa & Feuilles de Soins CNAS/CASNOS',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
