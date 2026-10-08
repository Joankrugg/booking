# Modern Box V3 — recherche flexible et calendrier

## Ce qui change

- Sans date : les prochaines disponibilités et les prochains concerts sont affichés, 50 résultats par page. Une date devient un filtre facultatif, effaçable. Parcourir un mois du calendrier ne force pas une date.
- Ville et rayon facultatifs : Geocoder utilise les coordonnées enregistrées, avec une distance à vol d’oiseau. Pour un concert, le rayon part du lieu recherché. Pour un groupe, il croise aussi le rayon de déplacement déclaré depuis sa ville de départ. Ce n’est pas un calcul de trajet routier.
- Dans la fiche de gestion du groupe : **Calendrier des disponibilités**. Choisir une zone puis un état, cliquer sur une date. Disponible : orange encadré ; indisponible : noir ; sur demande : pointillé ; non renseigné : gris. Effacer retire la déclaration, sans transformer le jour en indisponibilité.
- Une période permet de déclarer ou reconfirmer, par exemple, tous les vendredis et samedis pendant trois mois, au maximum 366 jours à la fois. La modification est atomique : une période invalide ne laisse pas des dates partiellement enregistrées.
- Une plage horaire facultative par jour et zone (sur la même journée). Sans horaires : journée entière. Les clics conservent les notes et horaires existants sauf si la case de remplacement est cochée. Les états ne sont pas des réservations.
- Mon profil propose plusieurs cases cumulables : groupes, programmation, sorties. Un organisateur peut aussi gérer ses groupes, avec une seule connexion. L’activité organisateur reste obligatoire lorsque cet usage est sélectionné. La publication des groupes reste soumise à l’adhésion.

Les comptes, groupes et adhésions existants sont conservés. Les anciens profils sont convertis en cases correspondantes. La date d’un concert ne bloque pas automatiquement la disponibilité du groupe.

## Mettre à jour votre installation locale

Arrêter le serveur avec Ctrl+C. Télécharger l’archive, puis :

```bash
unzip ~/Downloads/modernbox-rails-v3.zip -d ~/Downloads/modernbox-v3
rsync -a --exclude='.env*' --exclude='config/master.key' --exclude='db/schema.rb' --exclude='storage/' --exclude='tmp/' --exclude='log/' ~/Downloads/modernbox-v3/modernbox-app/ ~/Desktop/modernbox-app/
cd ~/Desktop/modernbox-app
chmod u+x bin/*
export PGHOST=127.0.0.1
export PGPORT=5432
export PGUSER="$(whoami)"
bundle _2.4.10_ install
bin/rails db:migrate
bin/rails db:schema:dump
bin/rails assets:clobber
bin/rails server
```

Le chemin suppose le nom exact du ZIP. Adapter les chemins si le navigateur a renommé le fichier. Aucun reset de base. La nouvelle migration ajoute trois cases aux comptes, les coordonnées aux dates et concerts, le rayon et les horaires aux disponibilités, et deux tables de cache/verrou géographique. Les nouveaux formulaires proposent un rayon explicite de 50 km ; les anciennes disponibilités reçoivent 0 km, car leur rayon n’avait pas été déclaré.

**Dates déjà enregistrées :** ouvrir le calendrier, préciser une ville de départ et un rayon, puis reconfirmer une période. Les coordonnées manquantes empêchent la recherche par distance, mais pas l’affichage sans filtre de lieu. Une zone ancienne comme « Gironde » doit être remplacée ou précisée en ville de départ et rayon adapté ; un département géocodé n’est qu’un point central, pas une couverture complète.

Pour localiser les lieux historiques sans changer leurs états ni leur confirmation :

```bash
bin/rails modern_box:geocode_existing
```

Cette tâche espace les requêtes. Elle ne change ni les noms des zones ni les rayons : compléter les zones imprécises depuis l’interface. Les échecs de localisation sont mis en cache 30 minutes ; après correction du nom, une nouvelle recherche peut être faite. Un succès est conservé en base.

## Géocodage

Le développement utilise désormais le vrai fournisseur, et non le faux géocodeur de test de Slotbook. Aucun service de géocodage n’est appelé dans les tests automatiques.

Par défaut : Nominatim, pays France. Requêtes uniquement après soumission ou enregistrement, pas d’autocomplétion. Cache PostgreSQL commun aux processus ; verrou limitant les nouvelles requêtes à une par seconde dans cette application. Si le fournisseur est indisponible ou momentanément occupé, la recherche affiche un message explicite et ne remplace pas le rayon par une comparaison textuelle trompeuse.

La localisation demande une connexion réseau sortante. Nominatim est adapté à une expérimentation modeste ; avant un volume important, choisir un fournisseur et sa capacité. Configuration remplaçable :

```bash
# Valeurs d’exemple, à adapter au fournisseur retenu ; aucune clé n’est livrée.
export GEOCODER_LOOKUP=nominatim
export GEOCODER_COUNTRY=France
# export GEOCODER_API_KEY=...
```

Le fournisseur reçoit uniquement le lieu recherché / renseigné. Aucun e-mail de membre ou contrainte personnelle n’est envoyé. Les résultats publics restent soumis à la publication du groupe, à l’adhésion active de son propriétaire et à une confirmation de disponibilité datant de moins de 30 jours.

## Vérifier les parcours

```bash
RAILS_ENV=test bin/rails db:prepare
bin/rails test test/models/modern_box_core_test.rb test/models/modern_box_v3_core_test.rb test/integration/modern_box_access_test.rb test/integration/modern_box_profiles_test.rb test/integration/modern_box_v3_test.rb
bin/rails zeitwerk:check
```

Dans le navigateur : recherche sans date, Bordeaux avec rayon de 15 km, clics successifs dans le calendrier, période limitée aux vendredis, effacement d’une date, reconfirmation sans perte de notes, profil Groupe + Organisateur.

La livraison a été vérifiée sur une copie SQLite, pas sur votre PostgreSQL ni sur Render. Le calcul géographique SQL utilisé en production reste à vérifier sur votre PostgreSQL. Voir VERIFICATION.md. Aucun push sur main, déploiement ou changement DNS.
