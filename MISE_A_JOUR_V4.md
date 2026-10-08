# Modern Box V4

## Changements

- Adhésion automatique et gratuite à l’inscription, sans validation administrative.
- Publication des groupes, concerts et disponibilités indépendante des anciennes dates d’adhésion. Un compte suspendu reste bloqué.
- Accès aux téléchargements IA distinct, payant et limité par une date de fin. Seul un administrateur peut l’activer après paiement vérifié. Le catalogue reste public. Aucun encaissement automatique ajouté : demande d’accès par email.
- Migration : anciens accès IA associés à une adhésion active conservés jusqu’à leur échéance antérieure ; adhésions existantes converties en adhésions gratuites et création des adhésions manquantes. Les comptes ne sont pas réactivés.
- Calendrier en deux étapes : zone, état et précisions, puis activation et application aux dates. Aucun clic d’édition possible avant activation.
- Une modification de paramètres suspend le mode d’application. Les boutons Modifier et Terminer reviennent en consultation.
- Message après enregistrement, affichage des erreurs sans faux changement de case, annulation de la dernière date pendant 15 minutes. L’annulation restaure les détails et refuse d’écraser une modification ultérieure. Les périodes n’ont pas d’annulation globale.
- Changement de zone recharge ses dates avant activation. Navigation des mois conserve les paramètres et le mode actif.
- Application à une période avec nombre de dates et confirmation explicite. JavaScript requis pour ce nouvel éditeur.

## Installation sur la V3

Sauvegarder la base, arrêter le serveur et extraire l’archive. Copier les sources en conservant .env, config/master.key, storage, log et tmp de votre installation. Ne pas remplacer votre base ni son schéma avec le schéma historique livré.

```bash
bundle install
bin/rails db:migrate
bin/rails test test/models/modern_box_core_test.rb test/integration/modern_box_access_test.rb test/integration/modern_box_profiles_test.rb test/integration/modern_box_v3_test.rb test/models/modern_box_v3_core_test.rb test/integration/modern_box_v4_test.rb
node test/javascript/availability_calendar_test.mjs
bin/rails server
```

La migration V4 transforme les adhésions : son retour arrière n’est pas automatique. Restaurer la sauvegarde si nécessaire.

## Vérification à faire localement

Créer un compte : vérifier l’accès immédiat aux groupes et le refus de téléchargement IA. Activer ensuite l’accès IA depuis Administration et vérifier le téléchargement, puis retirer sa date de fin pour le révoquer.

Sur les disponibilités : activer Disponible pour Bordeaux + 50 km, cliquer puis annuler ; changer l’état pour vérifier la pause ; changer de zone ; naviguer entre les mois ; appliquer à plusieurs vendredis et samedis ; essayer depuis un autre compte sans accès au groupe.

## Limites de validation de cette livraison

Le contrôleur JavaScript a passé la vérification de syntaxe et les tests isolés exécutés avec Node (consultation, activation, pause, période, réussite, échec, annulation et fin).

Les tests Rails ont été adaptés et complétés mais ne sont pas exécutés ici : Ruby et PostgreSQL ne sont pas disponibles. Aucun rendu navigateur Rails ni migration réelle n’a été vérifié. Les résultats V3 du fichier VERIFICATION.md concernent la livraison précédente, pas la V4.

La configuration Ruby/Gemfile historique est conservée. Rails 8 exige Ruby >= 3.2 ; vérifier la résolution effective des dépendances sur votre installation.

Aucun déploiement ni changement de votre installation locale réalisé depuis cette archive.
