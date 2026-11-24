import 'cabinet_repository.dart';
import 'local_database_repository.dart';
import 'api_cabinet_repository.dart';

/// Gestionnaire central de dépendances (Repository Provider)
///
/// Pour basculer de la base locale SQLite vers l'API distante :
/// Changer simplement `useRemoteApi = true` et configurer l'URL dans `ApiCabinetRepository`.
class RepositoryProvider {
  // Drapeau de configuration : false = SQLite local, true = API Backend
  static bool useRemoteApi = false;

  static final CabinetRepository _localRepo = LocalDatabaseRepository();
  static final CabinetRepository _apiRepo = ApiCabinetRepository();

  /// Fournit le repository actif selon la configuration
  static CabinetRepository get repository {
    if (useRemoteApi) {
      return _apiRepo;
    }
    return _localRepo;
  }

  /// Nom de la source active en français
  static String get sourceActiveNom {
    return useRemoteApi ? 'API Distante (Serveur Web)' : 'Base Locale SQLite (Hors-ligne)';
  }
}
