-- Suppression des tables si elles existent
DROP TABLE IF EXISTS utilisateurs CASCADE;
DROP TABLE IF EXISTS amitie CASCADE;
DROP TABLE IF EXISTS concerts_a_venir CASCADE;
DROP TABLE IF EXISTS concerts_finis CASCADE;
DROP TABLE IF EXISTS interet CASCADE;
DROP TABLE IF EXISTS photos_videos CASCADE;
DROP TABLE IF EXISTS tags CASCADE;
DROP TABLE IF EXISTS morceaux CASCADE;
DROP TABLE IF EXISTS playlists CASCADE;
DROP TABLE IF EXISTS morceau_de_playlist CASCADE;
DROP TABLE IF EXISTS avis CASCADE;
DROP TABLE IF EXISTS avis_artiste CASCADE;
DROP TABLE IF EXISTS avis_lieu CASCADE;
DROP TABLE IF EXISTS avis_morceau CASCADE;
DROP TABLE IF EXISTS avis_playlist CASCADE;
DROP TABLE IF EXISTS avis_concert_fini CASCADE;
DROP TABLE IF EXISTS avis_tag CASCADE;

-- Création des tables
CREATE TABLE utilisateurs (
    user_id INTEGER PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL,
    lieu VARCHAR(20),
    user_type VARCHAR(20) NOT NULL
);

CREATE TABLE amitie (
    user_id INTEGER REFERENCES utilisateurs,
    utilisateur_2 INTEGER REFERENCES utilisateurs,
    ami BOOLEAN NOT NULL, -- FALSE -> follow, TRUE -> ami
    PRIMARY KEY (user_id, utilisateur_2)
);

CREATE TABLE concerts_a_venir (
    artiste INTEGER REFERENCES utilisateurs,
    concert_date DATE,
    lieu INTEGER REFERENCES utilisateurs,
    prix INTEGER,
    places INTEGER,
    volontaires INTEGER CHECK (volontaires >= 0),
    cause TEXT,
    enfants BOOLEAN NOT NULL,
    extérieur BOOLEAN NOT NULL,
    PRIMARY KEY (artiste, concert_date),
    CHECK ((places > 0 AND prix > 0) OR (places = 0 AND prix = 0))
);

CREATE TABLE concerts_finis (
    artiste INTEGER REFERENCES utilisateurs,
    concert_date DATE,
    lieu INTEGER REFERENCES utilisateurs,
    nb_participants INTEGER CHECK (nb_participants >= 0),
    PRIMARY KEY (artiste, concert_date)
);

CREATE TABLE interet (
    user_id INTEGER REFERENCES utilisateurs,
    artiste INTEGER,
    concert_date DATE,
    participe BOOLEAN NOT NULL, -- FALSE -> intéressé, TRUE -> participe
    FOREIGN KEY (artiste, concert_date) REFERENCES concerts_a_venir,
    PRIMARY KEY (user_id, artiste, concert_date)
);

CREATE TABLE photos_videos (
    id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES utilisateurs,
    taille INTEGER CHECK (taille > 0),
    artiste INTEGER,
    concert_date DATE,
    FOREIGN KEY (artiste, concert_date) REFERENCES concerts_finis(artiste, concert_date)
);

CREATE TABLE tags (
    nom VARCHAR(20) PRIMARY KEY,
    sous_genre_de VARCHAR(20) REFERENCES tags
);

CREATE TABLE morceaux (
	artiste INTEGER REFERENCES utilisateurs,
	nom VARCHAR(50),
	PRIMARY KEY (artiste, nom)
);

CREATE TABLE playlists (
	user_id INTEGER REFERENCES utilisateurs,
	nom VARCHAR(50),
	PRIMARY KEY (user_id, nom)
);

CREATE TABLE morceau_de_playlist (
    user_morceau INTEGER,
    nom_morceau VARCHAR(50),
    user_playlist INTEGER,
	nom_playlist VARCHAR(50),
    FOREIGN KEY (user_morceau, nom_morceau) REFERENCES morceaux,
    FOREIGN KEY (user_playlist, nom_playlist) REFERENCES playlists,
	PRIMARY KEY (user_morceau, nom_morceau, user_playlist, nom_playlist)
);

CREATE TABLE avis (
	id_avis INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES utilisateurs,
	note INTEGER CONSTRAINT note_pos CHECK(note > 0 AND note < 6),
	com VARCHAR(50)
);

-- TABLES D'ASSOCIATION AVIS -- 
CREATE TABLE avis_morceau (
	id_avis INTEGER REFERENCES avis,
    user_morceau INTEGER,
	nom_morceau VARCHAR(50),
    FOREIGN KEY (user_morceau, nom_morceau) REFERENCES morceaux,
	PRIMARY KEY (id_avis, user_morceau, nom_morceau)
);

CREATE TABLE avis_playlist (
	id_avis INTEGER REFERENCES avis,
    user_playlist INTEGER,
	nom_playlist VARCHAR(50),
    FOREIGN KEY (user_playlist, nom_playlist) REFERENCES playlists,
	PRIMARY KEY (id_avis, user_playlist, nom_playlist)
);

CREATE TABLE avis_concert_fini (
	id_avis INTEGER REFERENCES avis,
    artiste INTEGER,
	concert_date DATE,
    FOREIGN KEY (artiste, concert_date) REFERENCES concerts_finis,
	PRIMARY KEY (id_avis, artiste, concert_date)
);

CREATE TABLE avis_lieu (
    id_avis INTEGER REFERENCES avis,
    lieu INTEGER REFERENCES utilisateurs,
    PRIMARY KEY (id_avis, lieu)
);

CREATE TABLE avis_artiste (
    id_avis INTEGER REFERENCES avis,
    artiste INTEGER REFERENCES utilisateurs,
    PRIMARY KEY (id_avis, artiste)
);

CREATE TABLE avis_tag (
	id_avis INTEGER REFERENCES avis,
	nom_tag VARCHAR(50) REFERENCES tags,
	PRIMARY KEY (id_avis, nom_tag)
);

-- Copie des données depuis les fichiers au format CSV
\COPY utilisateurs FROM 'csv/utilisateurs.csv' WITH (FORMAT CSV, HEADER);
\COPY amitie FROM 'csv/amitie.csv' WITH (FORMAT CSV, HEADER);
\COPY concerts_a_venir FROM 'csv/concerts_a_venir.csv' WITH (FORMAT CSV, HEADER);
\COPY concerts_finis FROM 'csv/concerts_finis.csv' WITH (FORMAT CSV, HEADER);
\COPY interet FROM 'csv/interet.csv' WITH (FORMAT CSV, HEADER);
\COPY photos_videos FROM 'csv/photos_videos.csv' WITH (FORMAT CSV, HEADER);
\COPY tags FROM 'csv/tags.csv' WITH (FORMAT CSV, HEADER);
\COPY morceaux FROM 'csv/morceaux.csv' WITH (FORMAT CSV, HEADER);
\COPY playlists FROM 'csv/playlists.csv' WITH (FORMAT CSV, HEADER);
\COPY morceau_de_playlist FROM 'csv/morceau_de_playlist.csv' WITH (FORMAT CSV, HEADER);
\COPY avis FROM 'csv/avis.csv' WITH (FORMAT CSV, HEADER);
\COPY avis_morceau FROM 'csv/avis_morceau.csv' WITH (FORMAT CSV, HEADER);
\COPY avis_playlist FROM 'csv/avis_playlist.csv' WITH (FORMAT CSV, HEADER);
\COPY avis_concert_fini FROM 'csv/avis_concert_fini.csv' WITH (FORMAT CSV, HEADER);
\COPY avis_lieu FROM 'csv/avis_lieu.csv' WITH (FORMAT CSV, HEADER);
\COPY avis_artiste FROM 'csv/avis_artiste.csv' WITH (FORMAT CSV, HEADER);
\COPY avis_tag FROM 'csv/avis_tag.csv' WITH (FORMAT CSV, HEADER);
