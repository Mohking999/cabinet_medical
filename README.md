# 🏥 Cabinet Médical — Application Flutter

Application mobile et bureau de gestion de cabinet médical développée en Flutter, basée sur le **Diagramme de Séquence UML** du parcours patient (Rendez-vous, Accueil, Consultation, Ordonnance sécurisée et Facturation SESAM-Vitale).

100% en langue française.

---

## 📱 Fonctionnalités Principales

1. **📅 Gestion des Rendez-vous**
   - Planification de créneaux avec détection des conflits.
   - Création à la volée de fiches patients pour les nouveaux arrivants.
   - Statuts dynamiques : *Confirmé*, *En salle d'attente*, *En consultation*, *Terminé*.

2. **⏳ Salle d'Attente & Accueil**
   - Pointage de l'arrivée du patient avec simulation de lecture de la **Carte Vitale**.
   - Ordre d'arrivée et appel en consultation en 1 clic.

3. **🩺 Consultation & Prescription Sécurisée**
   - Consultation immédiate des antécédents et des allergies du patient (DMI).
   - Relevé des constantes vitales (tension, pouls, température).
   - Rédaction d'ordonnances avec **contrôle automatisé des contre-indications et allergies médicamenteuses**.

4. **💳 Facturation & Télétransmission SESAM-Vitale**
   - Cotation automatique des actes (ex: Acte `G` = 26.50 €).
   - Répartition Tiers-Payant : Part Caisse (RO 70%), Part Mutuelle (RC 30%) et Reste à charge patient.
   - Gestion des prises en charge intégrales à 100% (**ALD**, C2S) sans avance de frais.
   - Encaissement (Carte Bancaire, Espèces, Chèque) et génération de quittance.

---

## 🗄️ Architecture des Données : Base Locale & API Distante

L'application respecte le **Repository Pattern** afin de séparer la vue de la persistance :

- **Base de données locale (SQLite)** : via `sqflite` dans `lib/database/database_helper.dart`. Fonctionne 100% hors-ligne.
- **Connecteur API Web REST** : implémenté dans `lib/services/api_cabinet_repository.dart`.
- **Commutateur de source** : dans l'application (icône en haut à droite de l'écran d'accueil) ou dans `lib/services/repository_provider.dart` (`useRemoteApi = true`).

---

## 🚀 Compilation Automatique de l'APK (GitHub Actions)

Un workflow CI/CD complet est configuré dans [`.github/workflows/build_apk.yml`](.github/workflows/build_apk.yml) :
- Dès que vous poussez (`git push`) sur GitHub sur la branche `main` ou `master` :
  1. GitHub Actions installe l'environnement Java et Flutter.
  2. Il analyse le code et exécute les tests.
  3. Il compile le fichier **`app-release.apk`**.
  4. L'APK est disponible au téléchargement dans l'onglet **Actions** de votre dépôt GitHub (section *Artifacts*).

---

## 📦 Guide pour publier sur votre compte GitHub

Dans le dossier `cabinet_medical` :

```bash
# 1. Initialiser git si nécessaire
git init

# 2. Ajouter tous les fichiers
git add .
git commit -m "feat: Application Flutter Cabinet Médical avec SQLite et GitHub Actions"

# 3. Lier à votre dépôt GitHub distant
git remote add origin https://github.com/VOTRE_NOM_UTILISATEUR/cabinet_medical.git
git branch -M main
git push -u origin main
```
Dès le push terminé, rendez-vous sur GitHub dans l'onglet **Actions** pour voir la compilation automatique de l'APK !
