import 'package:flutter/material.dart';

class BadgeStatut extends StatelessWidget {
  final String statut;

  const BadgeStatut({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String libelle;
    IconData icon;

    switch (statut) {
      case 'EN_SALLE_D_ATTENTE':
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        libelle = 'En salle d\'attente';
        icon = Icons.access_time_filled;
        break;
      case 'EN_CONSULTATION':
        bg = Colors.purple.shade100;
        fg = Colors.purple.shade900;
        libelle = 'En consultation';
        icon = Icons.medical_services;
        break;
      case 'TERMINE':
      case 'PAYEE':
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        libelle = statut == 'PAYEE' ? 'Payée' : 'Terminé';
        icon = Icons.check_circle;
        break;
      case 'CLOTUREE_TIERS_PAYANT':
        bg = Colors.teal.shade100;
        fg = Colors.teal.shade900;
        libelle = '100% ALD / Tiers-Payant';
        icon = Icons.verified_user;
        break;
      case 'ANNULE':
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        libelle = 'Annulé';
        icon = Icons.cancel;
        break;
      case 'CONFIRME':
      default:
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        libelle = 'Confirmé';
        icon = Icons.calendar_today;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            libelle,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
