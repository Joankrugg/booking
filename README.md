# Modern Box — V4 Rails

Adaptation du dépôt public Joankrugg/booking, commit bc242c64ea57f12963b7f9a3d4739a3b03e6d1c2. Version de travail indépendante : aucune publication ni modification du service Render existant.

Voir **MISE_A_JOUR_V4.md** pour la mise à jour de votre installation existante et les parcours cumulables.

## Fonctionnalités

- Accueil Modern Box, annuaire de groupes et contacts.
- Recherche publique sans date imposée : prochaines disponibilités et prochains concerts ; filtres facultatifs de date, ville et rayon.
- Calendrier cliquable des groupes : disponible, sur demande, indisponible, non renseigné ; périodes avec choix des jours de la semaine.
- Zones de déplacement par ville de départ et rayon ; horaires facultatifs sur une même journée.
- Compte unique avec usages cumulables : groupes, organisation de concerts et public. La recherche reste gratuite ; publier un groupe exige une adhésion.
- Écran membre accessible sans adhésion ; gestion des groupes toujours réservée aux adhérents.
- Propriétaire et plusieurs responsables pour chaque groupe ; édition limitée aux groupes autorisés.
- Catalogue de skills, versions Markdown privées, téléchargement contrôlé côté serveur.
- Administration des adhésions, des skills et de leurs versions.
- Comptes Devise existants conservés. Créer un compte ne donne pas automatiquement une adhésion.

Les groupes brouillons ne sont pas publics. La visibilité exige que le propriétaire ait un compte actif et une adhésion en cours. Une disponibilité doit être reconfirmée tous les 30 jours. Sans déclaration, la date reste inconnue. Geocoder localise les centres des zones et les lieux des concerts. Les recherches utilisent les distances à vol d’oiseau ; une recherche de concert à Bordeaux inclut Floirac et Mérignac dans le rayon adapté. Le rayon déclaré par un groupe s’ajoute au rayon de recherche de l’organisateur. Les lieux non localisés restent visibles sans filtre géographique, sans être présentés comme proches. Aucune synchronisation Google Calendar.

Les skills sont des instructions Markdown à installer dans un environnement compatible, pas des comptes IA partagés. Un téléchargement déjà obtenu ne peut pas être retiré à distance. Les instructions sont enregistrées dans PostgreSQL ; aucun téléversement sur le disque éphémère de Render n’est nécessaire.

## Installation locale

Prérequis : Ruby 3.2.2, Bundler (version du Gemfile.lock), PostgreSQL, compilateur et libpq.

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

Créer un compte depuis l’interface, puis lui attribuer l’administration :

```bash
ADMIN_EMAIL=modernboxrecords@gmail.com bin/rails modern_box:admin
OWNER_EMAIL=modernboxrecords@gmail.com bin/rails modern_box:drafts
```

L’adresse doit correspondre à un compte existant. La commande drafts est réutilisable et crée seulement Deftoons (4), Schmok (5), Vector (2 + guests à préciser dans la présentation), en brouillon. Elle ne crée ni mot de passe ni adhésion ni disponibilité fictive. Compléter les genres, les présentations, les villes et les liens Instagram/YouTube ; TikTok pour Vector. Aucun lien social inventé.

Depuis /admin : valider les dates de l’adhésion du propriétaire. Depuis /membre : compléter et publier les groupes, déclarer les dates et zones, ajouter les responsables par leur e-mail. Les responsables doivent eux aussi avoir une adhésion active. Depuis /admin/skills : créer un skill, ajouter une version avec les instructions privées, puis publier le catalogue.

## Vérification

```bash
RAILS_ENV=test bin/rails db:prepare
bin/rails test test/models/modern_box_core_test.rb test/integration/modern_box_access_test.rb test/integration/modern_box_profiles_test.rb test/integration/modern_box_v3_test.rb test/models/modern_box_v3_core_test.rb test/integration/modern_box_v4_test.rb
bin/rails zeitwerk:check
```

Les nouveaux tests couvrent l’adhésion, l’isolement des groupes, la confirmation serveur, les téléchargements privés, les IDs de versions et les dates obsolètes. Voir VERIFICATION.md pour les vérifications réellement exécutées sur cette livraison.

## Passage sur Render — à faire après revue

Le service booking-enwy existant reste inchangé. Éviter de pousser cette version sur sa branche main avant validation : son déploiement automatique est activé.

1. Tester cette version dans un service de préproduction avec une base séparée.
2. Conserver les variables DATABASE_URL et SECRET_KEY_BASE ; définir APP_HOST avec le domaine final, sans protocole. Conserver RAILS_MASTER_KEY si les credentials existants sont utilisés. Configurer DEFAULT_FROM_EMAIL avec un expéditeur validé auprès de Mailjet. MAILJET_API_KEY et MAILJET_SECRET_KEY sont nécessaires pour les e-mails de réinitialisation.
3. Build : `bash bin/render-build.sh`. Démarrage : `bundle exec puma -C config/puma.rb`. Health check : `/up`.
4. Exécuter `RAILS_ENV=production bin/rails db:migrate` avant de démarrer le nouveau code. Sur une base neuve, utiliser `db:prepare`. Le script de build ne migre pas implicitement la base. Les migrations Modern Box ajoutent neuf tables et sept colonnes aux comptes, ainsi que les coordonnées et créneaux des dates ; les tables Slotbook sont préservées.
5. Une fois validé, sauvegarder la base de production puis appliquer la migration ; attribuer l’administration à un compte existant et créer les brouillons avec les tâches ci-dessus.
6. Générer et committer le schéma avec `bin/rails db:schema:dump` après migration locale. Le db/schema.rb fourni est le schéma Slotbook d’origine ; utiliser db:prepare/db:migrate, pas db:schema:load seul, pour installer cette V4.

Les anciens parcours de réservation et de Stripe ne sont plus routés. Leurs fichiers et leurs données sont conservés pour référence ; cette livraison ne les corrige pas et ne propose pas le paiement en ligne. Les adhésions sont validées manuellement.

## Domaines et périmètre

Cette application propose /skills et /disponibilites dans un espace commun. Les sous-domaines ai.modernboxrecords.org et availabilities.modernboxrecords.org nécessitent encore un choix de domaine canonique et une configuration DNS/Render ; aucune configuration DNS n’a été effectuée. La page racine est une entrée vers les deux nouveaux services, pas le remplacement de la précédente page d’écosystème incluant Beertrackr, agence, jeux, loops et partenaires.

Les portraits, biographies des membres, fiches techniques, photos et contenus éditoriaux du label restent à produire dans le chantier du site bands. Ces fichiers éditoriaux ne sont pas inclus ; les dates de concert peuvent désormais être renseignées dans l’application.

Pas de tunnel de paiement, gestion de contrats, booking automatisé, notifications ou moteur IA hébergé. Le tarif et la procédure de règlement de l’adhésion sont à définir avant commercialisation. Radioleg porte la structure ; Modern Box porte l’expérience produit.
