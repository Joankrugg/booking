# Modern Box V2 — navigation et profils

## Ce qui change

| Usage | Accès | Espace |
| --- | --- | --- |
| Gérant de salle, tourneur, programmateur | Recherche gratuite, sans compte ; compte gratuit facultatif | Recherche de groupes disponibles par date et lieu |
| Responsable d’un ou plusieurs groupes | Compte gratuit ; adhésion active requise pour gérer et publier | Groupes, disponibilités, responsables, concerts |
| Public | Agenda gratuit, sans compte ; compte gratuit facultatif | Concerts par date et ville |

L’inscription propose les trois profils. L’organisateur précise son activité (salle, tourneur, programmateur/festival, autre) et éventuellement sa structure. Le profil peut être modifié dans Mon compte. Aucun choix de profil ne donne de droits administrateur ou ne valide une adhésion.

Les comptes existants gardent leurs groupes et leur adhésion et reçoivent le profil Groupe par défaut. Les comptes administrateur conservent leurs droits. Les disponibilités et les concerts sont deux informations distinctes : renseigner un concert ne bloque pas automatiquement une journée ou une zone de disponibilité.

L’orange #f04c24 reprend celui du site du label. /calendar ouvre désormais l’agenda des concerts ; /disponibilites reste le moteur des groupes à programmer. Les concerts annulés restent lisibles comme annulés mais ne colorent pas une date comme sortie active.

Les concerts publiés restent conditionnés à la visibilité publique du groupe et à l’adhésion du propriétaire, comme ses disponibilités. La recherche de lieu est textuelle, sur les zones déclarées ; ni rayon ni catégorie ajoutés. La billetterie est un lien externe facultatif, sans vente intégrée.

## Mettre à jour votre installation locale

Arrêter le serveur avec Ctrl+C. Télécharger l’archive V2 dans Téléchargements puis exécuter :

```bash
unzip ~/Downloads/modernbox-rails-v2.zip -d ~/Downloads/modernbox-v2
rsync -a --exclude='.env*' --exclude='config/master.key' --exclude='db/schema.rb' --exclude='storage/' --exclude='tmp/' --exclude='log/' ~/Downloads/modernbox-v2/modernbox-app/ ~/Desktop/modernbox-app/
cd ~/Desktop/modernbox-app
chmod u+x bin/*
export PGHOST=127.0.0.1
export PGPORT=5432
export PGUSER="$(whoami)"
bundle _2.4.10_ install
bin/rails db:migrate
bin/rails db:schema:dump
bin/rails server
```

Le chemin de l’archive suppose le nom exact modernbox-rails-v2.zip. Adapter seulement les chemins si le navigateur a renommé le téléchargement ou si l’application est ailleurs.

Aucune commande de suppression ou réinitialisation de base n’est nécessaire. La migration ajoute quatre colonnes aux comptes et une table concerts. L’administration et les adhésions déjà validées sont conservées. Les scripts bin sont livrés avec leur droit d’exécution ; chmod corrige les décompressions qui ne les conservent pas.

Le développement local utilise maintenant le stockage local et la livraison d’e-mails en mémoire (:test) : aucune clé Mailjet ou Cloudinary requise pour lancer l’application. La configuration de production Mailjet reste distincte.

## Vérifier les parcours

- Déconnecté : ouvrir Booker un groupe et Où sortir ?, rechercher date/lieu.
- Créer un compte organisateur avec une activité : espace gratuit, aucune demande d’adhésion.
- Créer un compte public : espace orienté concerts, aucune demande d’adhésion.
- Créer un compte groupe sans adhésion : écran d’activation, pas de création de groupe.
- Après validation de l’adhésion : créer plusieurs groupes, déclarer des disponibilités, ajouter un concert publié et un brouillon ; vérifier que seul le publié est dans l’agenda.

```bash
RAILS_ENV=test bin/rails db:prepare
bin/rails test test/models/modern_box_core_test.rb test/integration/modern_box_access_test.rb test/integration/modern_box_profiles_test.rb
```

Aucun déploiement Render ni changement DNS effectué.
