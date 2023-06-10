-- Requêtes SQL

DEALLOCATE PREPARE prochains_concerts;
-- Les concerts ayant lieu dans les n jours à venir
PREPARE prochains_concerts(INTEGER) AS
SELECT U.user_name, L.lieu, concert_date FROM concerts_a_venir C
JOIN utilisateurs U ON (C.artiste = U.user_id)
JOIN utilisateurs L ON (C.lieu = L.user_id)
WHERE CURRENT_DATE < concert_date
    AND CURRENT_DATE + $1 > concert_date
ORDER BY concert_date, U.user_name;

DEALLOCATE PREPARE photos_de;
-- Les concerts pris en photo par un utilisateur
PREPARE photos_de(VARCHAR(20)) AS
SELECT artiste, concert_date FROM photos_videos
NATURAL JOIN concerts_finis CF
WHERE $1 IN (SELECT user_name FROM photos_videos PV
    NATURAL JOIN utilisateurs
    WHERE CF.artiste = PV.artiste);

-- Nombre de concerts à venir pour chaque artiste
SELECT user_name, COUNT(*) FROM concerts_a_venir
JOIN utilisateurs ON (concerts_a_venir.artiste = utilisateurs.user_id)
GROUP BY user_name;

-- Nombre d'amis d'un utilisateur ayant au moins un follower
SELECT user_name, COUNT(*) FROM utilisateurs U
NATURAL JOIN amitie
WHERE EXISTS (SELECT * FROM amitie
    WHERE amitie.utilisateur_2 = U.user_id AND ami = FALSE)
GROUP BY user_name;

-- Requête avec condition de totalité (Les utilisateurs qui n'ont pas d'amis)
-- Sous-requête corrélée
SELECT user_name FROM utilisateurs U
WHERE NOT EXISTS (SELECT * FROM amitie A
    WHERE A.user_id = U.user_id AND ami = TRUE)
ORDER BY user_name;
-- Agrégation
SELECT user_name FROM utilisateurs U
LEFT JOIN amitie A ON (U.user_id = A.user_id AND ami = TRUE)
WHERE A.user_id IS NULL
GROUP BY user_name
ORDER BY user_name;

-- La moyenne des notes de chaque concert
SELECT S.user_name, S.concert_date, ROUND(AVG(S.note), 0) FROM (SELECT U.user_name, ACF.concert_date, A.note
FROM avis A
NATURAL JOIN avis_concert_fini ACF
JOIN utilisateurs U ON (ACF.artiste = U.user_id)) S
GROUP BY S.user_name, S.concert_date;

DEALLOCATE PREPARE get_amis;
-- Avoir les amis d'amis d'un utilisateur (Récursive)
PREPARE get_amis (VARCHAR) AS
WITH RECURSIVE amis_rec (user_id, utilisateur_2) AS (
    (SELECT user_id, utilisateur_2 FROM amitie
    WHERE user_id = (SELECT user_id FROM utilisateurs
        WHERE user_name = $1) AND ami = TRUE)
        UNION
    (SELECT amitie.user_id, amitie.utilisateur_2 FROM amitie
    JOIN amis_rec ON amitie.user_id = amis_rec.utilisateur_2
    WHERE ami = TRUE)
)
SELECT DISTINCT user_name AS "Amis d'amis" FROM utilisateurs
JOIN (SELECT utilisateur_2 FROM amis_rec) S ON (utilisateur_2 = user_id);

DEALLOCATE get_nbr_avis_user;
-- Trouver le nombre d'avis postés par un utilisateur (supérieur à 2)
PREPARE get_nbr_avis_user(INTEGER) AS
SELECT u.user_name, COUNT(av.id_avis) AS nombre_avis
FROM utilisateurs u, avis av
WHERE u.user_id = av.user_id
GROUP BY u.user_name
HAVING COUNT(av.id_avis) > $1;

-- EXECUTE get_nbr_avis_user(2);

DEALLOCATE get_morceau_in_playlist;
-- Trouve les morceaux dans une playlist
PREPARE get_morceau_in_playlist (VARCHAR(20)) AS
SELECT m.nom AS nom_morceau
FROM morceau_de_playlist mp
JOIN morceaux m ON mp.user_morceau = m.artiste AND mp.nom_morceau = m.nom
JOIN playlists p ON mp.user_playlist = p.user_id AND mp.nom_playlist = p.nom
WHERE p.nom = $1;

-- EXECUTE get_morceau_in_playlist('Playlist de Léo');

-- Trouver la moyenne des avis de chaque utilisateur (supérieur à 3)
SELECT user_id, AVG(note) AS note_moyenne
FROM avis
GROUP BY user_id
HAVING AVG(note) > 3;

----Trouver les artistes ayant fini des concerts ayant plus de 1500 participant
SELECT user_name
FROM utilisateurs
WHERE user_id IN (
    SELECT artiste
    FROM concerts_finis
    WHERE nb_participants > 1500
);

-- Trouver le nombre de sous-genre d'un genre (Diff car valeurs NULL)
SELECT t1.nom, COUNT(t2.nom) AS sous_tags_count
FROM tags t1
JOIN tags t2 ON t1.nom = t2.sous_genre_de
GROUP BY t1.nom;

SELECT t1.nom, COUNT(t2.nom) AS sous_tags_count
FROM tags t1
LEFT JOIN tags t2 ON t1.nom = t2.sous_genre_de
GROUP BY t1.nom;
-- HAVING COUNT(t2.nom) <> 0;

-- Classe les utilisateurs en fonction de leur nombre d'avis
SELECT user_id, COUNT(id_avis) AS nombre_avis, RANK() OVER (ORDER BY COUNT(id_avis) DESC) AS classement
FROM avis
GROUP BY user_id
ORDER BY classement;

-- La moyenne des moyennes des notes des lieux
SELECT ROUND(AVG(moyenne), 2) AS "Moyenne des moyennes des lieux" FROM (
    SELECT AVG(note) AS moyenne
    FROM avis
    NATURAL JOIN avis_lieu
) AS sous_requete;

-- Classe les artistes par leur nombre d'avis
SELECT u.user_id, u.user_name, COUNT(a.id_avis) AS nombre_avis, RANK() OVER (ORDER BY COUNT(a.id_avis) DESC) AS classement
FROM utilisateurs u
JOIN avis a ON u.user_id = a.user_id AND u.user_type = 'artiste'
GROUP BY u.user_id;

-- Classe les artistes en fonction de leur note moyenne
SELECT u.user_id, u.user_name, AVG(a.note) AS note_moyenne, RANK() OVER (ORDER BY AVG(a.note) DESC) AS classement
FROM utilisateurs u
JOIN avis a ON u.user_id = a.user_id AND u.user_type = 'artiste'
GROUP BY u.user_id;

DEALLOCATE PREPARE recommandation;
-- Indice de recommandation
PREPARE recommandation (VARCHAR(20)) AS
SELECT t.nom, AVG(av.note) AS moyenne_note
FROM avis_tag a
JOIN tags t ON a.nom_tag = t.nom
NATURAL JOIN avis av
NATURAL JOIN utilisateurs u
WHERE u.user_name = $1
GROUP BY t.nom
HAVING AVG(av.note) >= 3
ORDER BY moyenne_note DESC;

-- EXECUTE recommandation('Léo');

DEALLOCATE PREPARE reco_morceaux;
-- Morceaux recommandés pour un utilisateur
PREPARE reco_morceaux (VARCHAR(20)) AS
SELECT m.nom AS nom_morceau, u.user_name AS nom_artiste
FROM morceaux m
JOIN avis_morceau am ON m.artiste = am.user_morceau
NATURAL JOIN avis
NATURAL JOIN avis_tag a
JOIN utilisateurs u ON m.artiste = u.user_id
WHERE a.nom_tag IN (
    SELECT t.nom FROM avis_tag avi
    JOIN tags t ON avi.nom_tag = t.nom
    NATURAL JOIN avis av
    NATURAL JOIN utilisateurs u
    WHERE u.user_name = $1
    GROUP BY t.nom
    HAVING AVG(av.note) >= 3);

-- EXECUTE reco_morceaux('Léo');
