# Validation V4

Voir MISE_A_JOUR_V4.md : tests JavaScript isolés réussis ; tests Rails et migration V4 non exécutés dans cet environnement.

---

# Vérification de Modern Box V3 — 8 octobre 2026

## Contrôles exécutés

- 44 tests, 206 assertions : zéro échec, zéro erreur, zéro test ignoré.
- Vérification de syntaxe : 140 fichiers Ruby/Rake et 52 vues ERB du périmètre Modern Box.
- Vérification de syntaxe JavaScript : profil cumulable, calendrier et enregistrement des contrôleurs.
- Migration V3 exécutée dans la copie isolée SQLite.
- Chargement Rails/contrôle Zeitwerk et précompilation des assets : réussis.

Les tests couvrent les recherches sans date, le filtre explicite par date et la navigation des mois sans date imposée ; Bordeaux/Floirac/Mérignac et l’exclusion de Paris ; les rayons de déplacement variables, les lieux non reconnus et la pagination ; clics disponibles/indisponibles/effacement et API JSON ; périodes limitées aux jours choisis, idempotence et rejet sans écriture partielle ; conservation des notes/horaires ; isolement des groupes et adhésion ; comptes cumulant les trois usages, activité obligatoire et rejet d’un compte sans usage.

Les contrôles V1/V2 restent inclus : adhésion, révocation, protection des skills et versions, confirmation serveur, groupes privés, disponibilités obsolètes, concerts brouillons et annulations. Les tests géographiques utilisent des coordonnées connues et des réponses simulées : aucun appel réel au fournisseur.

## Limites

La copie de vérification utilise Ruby 3.2.3, Bundler 2.4.19 et SQLite. La livraison conserve Ruby 3.2.2, Bundler 2.4.10, PostgreSQL et le Gemfile.lock original. Le schéma temporaire de test ne remplace pas le schéma Slotbook livré.

En production, PostgreSQL calcule les distances par SQL fourni par Geocoder, après préfiltrage géographique, puis pagine les résultats sans charger tous les candidats dans Rails. Le test portable vérifie aussi cette expression SQL avec des fonctions trigonométriques SQLite ; cela ne remplace pas une exécution sur PostgreSQL. Les transactions et migrations de production, la base historique et la performance sur un volume réel restent à vérifier localement / en préproduction.

Les nouvelles vues et leurs formulaires sont rendus par Rails dans les tests. Aucun navigateur graphique n’était disponible : les interactions JavaScript, le rendu visuel sur mobile et le géocodage réseau réel nécessitent une revue locale. Les clics disposent d’un repli natif sans JavaScript.

Aucun accès ou changement de production, push GitHub, déploiement Render ou modification DNS. Les anciens parcours Slotbook conservés dans les fichiers ne sont pas exposés ni testés.
