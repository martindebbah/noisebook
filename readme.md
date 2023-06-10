# Projet de Bases de Données

L3 Informatique - Université Paris Cité

## Auteurs

- DEBBAH Martin
- ZHOU Alexandre

## Sujet : NoiseBook, Un réseau social centré sur la musique

Les réseaux sociaux subissent les aléas de la mode (R.I.P. Myspace, Skyblog, bientôt Facebook et
Instagram ?) et des contraintes économiques et politiques (au revoir Twitter ?). Le critiquable algorithme
de TikTok impose de plus en plus sa loi aux esprits. Dans ce contexte, il est nécessaire de revenir à une
vraie valeur unificatrice : la Musique. Un nouveau réseau social open source, participatif et sans publicité
va voir le jour : NoiseBook. Il permettra à ses utilisateurs de découvrir une multitude de nouveaux sons
parmi les genres existants et d’aller à de vrais concerts écouter de la vraie musique et rencontrer de vrais
gens.

Dans ce projet, nous avons conçu une base de données qui permet de gérer NoiseBook.
1. Nous avons commencé par réaliser le modèle conceptuel de données. (schéma entités-associations)
2. Puis nous avons créé (et peuplé grâce à des fichiers CSV) les tables dans PostgreSQL.
3. Nous avons imaginé 20 questions sur la base de données et les avons écrites sous forme de requêtes SQL
(certaines requêtes devaient avoir une forme spécifique, par exemple : une requête récursive,
une requête portant sur trois tables, des requêtes avec agrégat, etc...)
4. Nous avons finalement imaginé un indice de recommandation, permettant de recommander des chansons
à un utilisateurs en fonction de ses goûts.

Vous retrouvez dans le fichier `rapport.txt` notre modélisation de la base de données utilisée par NoiseBook,
ainsi que les requêtes implémentées.