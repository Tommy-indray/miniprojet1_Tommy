-- =================================================================
-- MINIPROJET N°1 : SYSTÈME DE GESTION DE BIBLIOTHÈQUE UNIVERSITAIRE
-- =================================================================
-- Auteur : [INDRAY Christommy]
-- Date : Décembre 2025
-- Description : Script SQL complet pour la création, le peuplement et 
--               la gestion de la base de données d'une bibliothèque universitaire
-- =================================================================

-- ============================================
-- NIVEAU 1 : CRÉATION ET MANIPULATION DE BASE
-- ============================================

-- -----------------------------------------------------
-- QUESTION 1 : Création du schéma complet
-- -----------------------------------------------------
-- Objectif : Créer toutes les tables avec contraintes d'intégrité
-- Justification : 
-- - Utilisation de SERIAL pour les IDs auto-incrémentés
-- - Clés étrangères avec ON DELETE CASCADE pour maintenir l'intégrité
-- - Contraintes CHECK pour valider les valeurs autorisées
-- - Types de données adaptés à chaque champ
-- -----------------------------------------------------

-- 1. Table des succursales
-- Commentaire : Stocke les informations des différentes bibliothèques
CREATE TABLE Succursales (
    id SERIAL PRIMARY KEY,                    -- Identifiant unique auto-incrémenté
    nom VARCHAR(100) NOT NULL,                -- Nom de la succursale
    adresse TEXT,                             -- Adresse complète
    telephone VARCHAR(20)                     -- Numéro de téléphone
);

-- 2. Table des ouvrages
-- Commentaire : Contient les informations bibliographiques des ouvrages
CREATE TABLE Ouvrages (
    ISBN VARCHAR(20) PRIMARY KEY,            -- Identifiant international unique
    titre VARCHAR(255) NOT NULL,             -- Titre complet
    auteurs TEXT NOT NULL,                   -- Liste des auteurs
    editeur VARCHAR(100),                    -- Maison d'édition
    annee_publication INTEGER,               -- Année de publication
    categorie VARCHAR(50),                   -- Catégorie (Littérature, SF, etc.)
    nombre_exemplaires INTEGER DEFAULT 0     -- Nombre total d'exemplaires possédés
);

-- 3. Table des exemplaires
-- Commentaire : Gère les exemplaires physiques individuels
CREATE TABLE Exemplaires (
    id SERIAL PRIMARY KEY,                    -- Identifiant unique de l'exemplaire
    ISBN VARCHAR(20) REFERENCES Ouvrages(ISBN) ON DELETE CASCADE, -- Référence à l'ouvrage
    succursale_id INTEGER REFERENCES Succursales(id) ON DELETE CASCADE, -- Localisation
    numero_unique VARCHAR(50) UNIQUE NOT NULL, -- Numéro d'inventaire unique
    etat VARCHAR(20) CHECK (etat IN ('disponible', 'emprunté', 'en réparation')) DEFAULT 'disponible'
);

-- 4. Table des utilisateurs
-- Commentaire : Enregistre tous les utilisateurs du système
CREATE TABLE Utilisateurs (
    id SERIAL PRIMARY KEY,                    -- Identifiant unique
    nom VARCHAR(100) NOT NULL,                -- Nom de famille
    prenom VARCHAR(100) NOT NULL,             -- Prénom
    type VARCHAR(20) CHECK (type IN ('étudiant', 'professeur', 'personnel')), -- Catégorie
    email VARCHAR(255) UNIQUE NOT NULL,       -- Email unique
    date_inscription DATE DEFAULT CURRENT_DATE -- Date d'inscription
);

-- 5. Table des emprunts
-- Commentaire : Historique complet de tous les emprunts
CREATE TABLE Emprunts (
    id SERIAL PRIMARY KEY,                    -- Identifiant de l'emprunt
    utilisateur_id INTEGER REFERENCES Utilisateurs(id) ON DELETE CASCADE,
    exemplaire_id INTEGER REFERENCES Exemplaires(id) ON DELETE CASCADE,
    date_emprunt DATE DEFAULT CURRENT_DATE,   -- Date de début d'emprunt
    date_retour_prevue DATE NOT NULL,         -- Date de retour prévue
    date_retour_effective DATE,               -- Date de retour réelle
    CHECK (date_retour_prevue > date_emprunt) -- Validation : date retour > date emprunt
);

-- 6. Table des réservations
-- Commentaire : Gère les réservations d'ouvrages non disponibles
CREATE TABLE Reservations (
    id SERIAL PRIMARY KEY,
    utilisateur_id INTEGER REFERENCES Utilisateurs(id) ON DELETE CASCADE,
    ISBN VARCHAR(20) REFERENCES Ouvrages(ISBN) ON DELETE CASCADE,
    date_reservation DATE DEFAULT CURRENT_DATE,
    statut VARCHAR(20) CHECK (statut IN ('en attente', 'notifié', 'annulé')) DEFAULT 'en attente'
);

-- 7. Table des pénalités
-- Commentaire : Enregistre les amendes pour retards
CREATE TABLE Penalites (
    id SERIAL PRIMARY KEY,
    utilisateur_id INTEGER REFERENCES Utilisateurs(id) ON DELETE CASCADE,
    montant DECIMAL(10,2) NOT NULL,           -- Montant de la pénalité
    motif TEXT,                               -- Raison de la pénalité
    paye BOOLEAN DEFAULT FALSE                -- Statut de paiement
);

-- -----------------------------------------------------
-- QUESTION 2 : Insertion de données de test
-- -----------------------------------------------------
-- Objectif : Peupler la base avec des données réalistes pour tester
-- Justification :
-- - Données cohérentes et représentatives
-- - Couverture de différents scénarios
-- - Suffisamment de données pour tester les requêtes avancées
-- -----------------------------------------------------

-- Insertion de 3 succursales représentatives
INSERT INTO Succursales (nom, adresse, telephone) VALUES
('Bibliothèque Centrale', '123 Rue de l''Université, Paris', '01 23 45 67 89'),
('Bibliothèque des Sciences', '456 Avenue Descartes, Lyon', '04 56 78 90 12'),
('Bibliothèque des Lettres', '789 Boulevard Voltaire, Marseille', '04 98 76 54 32')
ON CONFLICT DO NOTHING;  -- Évite les erreurs si déjà inséré

-- Insertion de 50 ouvrages variés (liste complète)
INSERT INTO Ouvrages (ISBN, titre, auteurs, editeur, annee_publication, categorie, nombre_exemplaires) VALUES
('978-2-07-036002-8', 'Le Petit Prince', 'Antoine de Saint-Exupéry', 'Gallimard', 1943, 'Littérature', 5),
('978-2-253-00501-5', '1984', 'George Orwell', 'Folio', 1949, 'Science-Fiction', 3),
('978-2-07-040081-6', 'L''Étranger', 'Albert Camus', 'Gallimard', 1942, 'Littérature', 4),
('978-2-07-036822-2', 'Madame Bovary', 'Gustave Flaubert', 'Gallimard', 1857, 'Littérature', 3),
('978-2-07-041311-3', 'Les Misérables', 'Victor Hugo', 'Gallimard', 1862, 'Littérature', 6),
('978-2-221-09515-5', 'Vingt mille lieues sous les mers', 'Jules Verne', 'Pocket', 1870, 'Science-Fiction', 4),
('978-2-253-00430-8', 'Le Meilleur des mondes', 'Aldous Huxley', 'Folio', 1932, 'Science-Fiction', 3),
('978-2-07-036394-4', 'À la recherche du temps perdu', 'Marcel Proust', 'Gallimard', 1913, 'Littérature', 2),
('978-2-07-037010-2', 'L''Écume des jours', 'Boris Vian', 'Gallimard', 1947, 'Littérature', 3),
('978-2-266-11101-1', 'Le Parfum', 'Patrick Süskind', 'Le Livre de Poche', 1985, 'Roman', 4),
('978-2-226-01029-9', 'La Peste', 'Albert Camus', 'Gallimard', 1947, 'Littérature', 4),
('978-2-253-00144-4', 'Fahrenheit 451', 'Ray Bradbury', 'Folio', 1953, 'Science-Fiction', 3),
('978-2-253-00567-1', 'Dune', 'Frank Herbert', 'Folio', 1965, 'Science-Fiction', 5),
('978-2-070-36102-8', 'Les Fleurs du mal', 'Charles Baudelaire', 'Gallimard', 1857, 'Poésie', 2),
('978-2-08-070414-8', 'Le Horla', 'Guy de Maupassant', 'Flammarion', 1887, 'Nouvelle', 3),
('978-2-253-00571-8', 'Fondation', 'Isaac Asimov', 'Folio', 1951, 'Science-Fiction', 4),
('978-2-080-70950-8', 'L''Alchimiste', 'Paulo Coelho', 'Flammarion', 1988, 'Roman', 5),
('978-2-253-00531-2', 'Les Robots', 'Isaac Asimov', 'Folio', 1950, 'Science-Fiction', 3),
('978-2-253-00548-0', 'Ubik', 'Philip K. Dick', 'Folio', 1969, 'Science-Fiction', 3),
('978-2-07-036295-4', 'Les Trois Mousquetaires', 'Alexandre Dumas', 'Gallimard', 1844, 'Roman', 4),
('978-2-253-00538-1', 'Chroniques martiennes', 'Ray Bradbury', 'Folio', 1950, 'Science-Fiction', 3),
('978-2-07-041726-5', 'Bel-Ami', 'Guy de Maupassant', 'Gallimard', 1885, 'Littérature', 3),
('978-2-253-00562-6', 'La Guerre des mondes', 'H.G. Wells', 'Folio', 1898, 'Science-Fiction', 3),
('978-2-07-036294-7', 'Germinal', 'Émile Zola', 'Gallimard', 1885, 'Littérature', 4),
('978-2-253-00532-9', 'Les androïdes rêvent-ils de moutons électriques?', 'Philip K. Dick', 'Folio', 1968, 'Science-Fiction', 3),
('978-2-07-036298-5', 'Le Comte de Monte-Cristo', 'Alexandre Dumas', 'Gallimard', 1844, 'Roman', 5),
('978-2-253-00552-7', 'La Nuit des temps', 'René Barjavel', 'Folio', 1968, 'Science-Fiction', 4),
('978-2-07-037295-6', 'Le Vieil Homme et la Mer', 'Ernest Hemingway', 'Gallimard', 1952, 'Littérature', 3),
('978-2-253-00541-1', 'La Planète des singes', 'Pierre Boulle', 'Folio', 1963, 'Science-Fiction', 3),
('978-2-07-036037-0', 'Candide', 'Voltaire', 'Gallimard', 1759, 'Philosophie', 3),
('978-2-266-01380-9', 'Le Nom de la rose', 'Umberto Eco', 'Le Livre de Poche', 1980, 'Roman', 4),
('978-2-253-00557-2', 'Ravage', 'René Barjavel', 'Folio', 1943, 'Science-Fiction', 3),
('978-2-07-040804-1', 'Les Raisins de la colère', 'John Steinbeck', 'Gallimard', 1939, 'Littérature', 3),
('978-2-253-00537-4', 'Le Maître du Haut Château', 'Philip K. Dick', 'Folio', 1962, 'Science-Fiction', 3),
('978-2-07-036851-2', 'L''Assommoir', 'Émile Zola', 'Gallimard', 1877, 'Littérature', 3),
('978-2-266-01700-5', 'Le Liseur', 'Bernhard Schlink', 'Le Livre de Poche', 1995, 'Roman', 4),
('978-2-253-00554-1', 'Les Dépossédés', 'Ursula K. Le Guin', 'Folio', 1974, 'Science-Fiction', 3),
('978-2-07-036028-8', 'Les Contemplations', 'Victor Hugo', 'Gallimard', 1856, 'Poésie', 2),
('978-2-253-00560-2', 'Le Monde des Ā', 'A. E. van Vogt', 'Folio', 1945, 'Science-Fiction', 3),
('978-2-07-040806-5', 'Pour qui sonne le glas', 'Ernest Hemingway', 'Gallimard', 1940, 'Littérature', 3),
('978-2-266-11156-1', 'La Carte et le Territoire', 'Michel Houellebecq', 'J''ai Lu', 2010, 'Roman', 4),
('978-2-253-00550-3', 'Les Enfants de la terre', 'Jean M. Auel', 'Folio', 1980, 'Préhistoire', 4),
('978-2-07-036826-0', 'Nana', 'Émile Zola', 'Gallimard', 1880, 'Littérature', 3),
('978-2-253-00555-8', 'Le Château des étoiles', 'José Luis G. Delgado', 'Folio', 1998, 'Science-Fiction', 3),
('978-2-07-040808-9', 'Le Soleil se lève aussi', 'Ernest Hemingway', 'Gallimard', 1926, 'Littérature', 3),
('978-2-266-11189-9', 'Les Particules élémentaires', 'Michel Houellebecq', 'J''ai Lu', 1998, 'Roman', 4),
('978-2-253-00559-6', 'La Horde du Contrevent', 'Alain Damasio', 'Folio', 2004, 'Fantasy', 5),
('978-2-07-037299-4', 'Au-dessous du volcan', 'Malcolm Lowry', 'Gallimard', 1947, 'Littérature', 3),
('978-2-253-00561-9', 'La Possibilité d''une île', 'Michel Houellebecq', 'J''ai Lu', 2005, 'Roman', 4),
('978-2-02-028153-5', 'Le Seigneur des Anneaux', 'J.R.R. Tolkien', 'Bourgois', 1954, 'Fantasy', 4)
ON CONFLICT (ISBN) DO NOTHING;

-- Insertion de 100 exemplaires répartis
INSERT INTO Exemplaires (ISBN, succursale_id, numero_unique, etat) VALUES
-- Succursale 1 (Bibliothèque Centrale)
('978-2-07-036002-8', 1, 'EX-001', 'disponible'),
('978-2-07-036002-8', 1, 'EX-002', 'emprunté'),
('978-2-253-00501-5', 1, 'EX-003', 'disponible'),
('978-2-07-040081-6', 1, 'EX-004', 'disponible'),
('978-2-07-036822-2', 1, 'EX-005', 'en réparation'),
('978-2-07-041311-3', 1, 'EX-006', 'disponible'),
('978-2-221-09515-5', 1, 'EX-007', 'emprunté'),
('978-2-253-00430-8', 1, 'EX-008', 'disponible'),
('978-2-07-036394-4', 1, 'EX-009', 'disponible'),
('978-2-07-037010-2', 1, 'EX-010', 'emprunté'),
('978-2-266-11101-1', 1, 'EX-011', 'disponible'),
('978-2-226-01029-9', 1, 'EX-012', 'disponible'),
('978-2-253-00144-4', 1, 'EX-013', 'emprunté'),
('978-2-253-00567-1', 1, 'EX-014', 'disponible'),
('978-2-070-36102-8', 1, 'EX-015', 'disponible'),
('978-2-08-070414-8', 1, 'EX-016', 'en réparation'),
('978-2-253-00571-8', 1, 'EX-017', 'disponible'),
('978-2-080-70950-8', 1, 'EX-018', 'emprunté'),
('978-2-253-00531-2', 1, 'EX-019', 'disponible'),
('978-2-253-00548-0', 1, 'EX-020', 'disponible'),
('978-2-07-036295-4', 1, 'EX-021', 'emprunté'),
('978-2-253-00538-1', 1, 'EX-022', 'disponible'),
('978-2-07-041726-5', 1, 'EX-023', 'disponible'),
('978-2-253-00562-6', 1, 'EX-024', 'emprunté'),
('978-2-07-036294-7', 1, 'EX-025', 'disponible'),
('978-2-253-00532-9', 1, 'EX-026', 'disponible'),
('978-2-07-036298-5', 1, 'EX-027', 'emprunté'),
('978-2-253-00552-7', 1, 'EX-028', 'disponible'),
('978-2-07-037295-6', 1, 'EX-029', 'disponible'),
('978-2-253-00541-1', 1, 'EX-030', 'disponible'),

-- Succursale 2 (Bibliothèque des Sciences)
('978-2-07-036037-0', 2, 'EX-031', 'disponible'),
('978-2-266-01380-9', 2, 'EX-032', 'emprunté'),
('978-2-253-00557-2', 2, 'EX-033', 'disponible'),
('978-2-07-040804-1', 2, 'EX-034', 'disponible'),
('978-2-253-00537-4', 2, 'EX-035', 'emprunté'),
('978-2-07-036851-2', 2, 'EX-036', 'disponible'),
('978-2-266-01700-5', 2, 'EX-037', 'disponible'),
('978-2-253-00554-1', 2, 'EX-038', 'emprunté'),
('978-2-07-036028-8', 2, 'EX-039', 'disponible'),
('978-2-253-00560-2', 2, 'EX-040', 'disponible'),
('978-2-07-040806-5', 2, 'EX-041', 'emprunté'),
('978-2-266-11156-1', 2, 'EX-042', 'disponible'),
('978-2-253-00550-3', 2, 'EX-043', 'disponible'),
('978-2-07-036826-0', 2, 'EX-044', 'emprunté'),
('978-2-253-00555-8', 2, 'EX-045', 'disponible'),
('978-2-07-040808-9', 2, 'EX-046', 'disponible'),
('978-2-266-11189-9', 2, 'EX-047', 'emprunté'),
('978-2-253-00559-6', 2, 'EX-048', 'disponible'),
('978-2-07-037299-4', 2, 'EX-049', 'disponible'),
('978-2-253-00561-9', 2, 'EX-050', 'emprunté'),
('978-2-02-028153-5', 2, 'EX-051', 'disponible'),
('978-2-253-00501-5', 2, 'EX-052', 'disponible'),
('978-2-07-040081-6', 2, 'EX-053', 'emprunté'),
('978-2-07-036822-2', 2, 'EX-054', 'disponible'),
('978-2-07-041311-3', 2, 'EX-055', 'disponible'),
('978-2-221-09515-5', 2, 'EX-056', 'en réparation'),
('978-2-253-00430-8', 2, 'EX-057', 'disponible'),
('978-2-07-036394-4', 2, 'EX-058', 'emprunté'),
('978-2-07-037010-2', 2, 'EX-059', 'disponible'),
('978-2-266-11101-1', 2, 'EX-060', 'disponible'),

-- Succursale 3 (Bibliothèque des Lettres)
('978-2-226-01029-9', 3, 'EX-061', 'emprunté'),
('978-2-253-00144-4', 3, 'EX-062', 'disponible'),
('978-2-253-00567-1', 3, 'EX-063', 'disponible'),
('978-2-070-36102-8', 3, 'EX-064', 'emprunté'),
('978-2-08-070414-8', 3, 'EX-065', 'disponible'),
('978-2-253-00571-8', 3, 'EX-066', 'disponible'),
('978-2-080-70950-8', 3, 'EX-067', 'emprunté'),
('978-2-253-00531-2', 3, 'EX-068', 'disponible'),
('978-2-253-00548-0', 3, 'EX-069', 'disponible'),
('978-2-07-036295-4', 3, 'EX-070', 'en réparation'),
('978-2-253-00538-1', 3, 'EX-071', 'disponible'),
('978-2-07-041726-5', 3, 'EX-072', 'emprunté'),
('978-2-253-00562-6', 3, 'EX-073', 'disponible'),
('978-2-07-036294-7', 3, 'EX-074', 'disponible'),
('978-2-253-00532-9', 3, 'EX-075', 'emprunté'),
('978-2-07-036298-5', 3, 'EX-076', 'disponible'),
('978-2-253-00552-7', 3, 'EX-077', 'disponible'),
('978-2-07-037295-6', 3, 'EX-078', 'emprunté'),
('978-2-253-00541-1', 3, 'EX-079', 'disponible'),
('978-2-07-036037-0', 3, 'EX-080', 'disponible'),
('978-2-266-01380-9', 3, 'EX-081', 'emprunté'),
('978-2-253-00557-2', 3, 'EX-082', 'disponible'),
('978-2-07-040804-1', 3, 'EX-083', 'disponible'),
('978-2-253-00537-4', 3, 'EX-084', 'en réparation'),
('978-2-07-036851-2', 3, 'EX-085', 'disponible'),
('978-2-266-01700-5', 3, 'EX-086', 'emprunté'),
('978-2-253-00554-1', 3, 'EX-087', 'disponible'),
('978-2-07-036028-8', 3, 'EX-088', 'disponible'),
('978-2-253-00560-2', 3, 'EX-089', 'emprunté'),
('978-2-07-040806-5', 3, 'EX-090', 'disponible'),
('978-2-266-11156-1', 3, 'EX-091', 'disponible'),
('978-2-253-00550-3', 3, 'EX-092', 'emprunté'),
('978-2-07-036826-0', 3, 'EX-093', 'disponible'),
('978-2-253-00555-8', 3, 'EX-094', 'disponible'),
('978-2-07-040808-9', 3, 'EX-095', 'en réparation'),
('978-2-266-11189-9', 3, 'EX-096', 'disponible'),
('978-2-253-00559-6', 3, 'EX-097', 'emprunté'),
('978-2-07-037299-4', 3, 'EX-098', 'disponible'),
('978-2-253-00561-9', 3, 'EX-099', 'disponible'),
('978-2-02-028153-5', 3, 'EX-100', 'emprunté')
ON CONFLICT (numero_unique) DO NOTHING;

-- Insertion de 30 utilisateurs types
INSERT INTO Utilisateurs (nom, prenom, type, email, date_inscription) VALUES
('Dupont', 'Jean', 'étudiant', 'jean.dupont@email.com', '2024-01-15'),
('Martin', 'Marie', 'professeur', 'marie.martin@email.com', '2023-09-10'),
('Bernard', 'Pierre', 'étudiant', 'pierre.bernard@email.com', '2024-02-10'),
('Thomas', 'Julie', 'personnel', 'julie.thomas@email.com', '2023-11-05'),
('Petit', 'Luc', 'étudiant', 'luc.petit@email.com', '2024-03-12'),
('Robert', 'Sophie', 'professeur', 'sophie.robert@email.com', '2023-08-20'),
('Richard', 'Thomas', 'étudiant', 'thomas.richard@email.com', '2024-01-30'),
('Durand', 'Claire', 'personnel', 'claire.durand@email.com', '2023-10-15'),
('Dubois', 'Marc', 'étudiant', 'marc.dubois@email.com', '2024-02-25'),
('Moreau', 'Isabelle', 'professeur', 'isabelle.moreau@email.com', '2023-07-18'),
('Laurent', 'Nicolas', 'étudiant', 'nicolas.laurent@email.com', '2024-03-05'),
('Simon', 'Catherine', 'personnel', 'catherine.simon@email.com', '2023-12-10'),
('Michel', 'François', 'étudiant', 'francois.michel@email.com', '2024-01-20'),
('Lefebvre', 'Valérie', 'professeur', 'valerie.lefebvre@email.com', '2023-09-25'),
('Leroy', 'Philippe', 'étudiant', 'philippe.leroy@email.com', '2024-02-15'),
('Roux', 'Anne-Marie', 'personnel', 'annemarie.roux@email.com', '2023-11-30'),
('David', 'Patrick', 'étudiant', 'patrick.david@email.com', '2024-03-08'),
('Bertrand', 'Élise', 'professeur', 'elise.bertrand@email.com', '2023-08-05'),
('Morel', 'Jacques', 'étudiant', 'jacques.morel@email.com', '2024-01-10'),
('Fournier', 'Hélène', 'personnel', 'helene.fournier@email.com', '2023-10-28'),
('Girard', 'Sébastien', 'étudiant', 'sebastien.girard@email.com', '2024-02-28'),
('Bonnet', 'Christine', 'professeur', 'christine.bonnet@email.com', '2023-07-12'),
('Dupuis', 'Rémy', 'étudiant', 'remy.dupuis@email.com', '2024-03-15'),
('Lambert', 'Patricia', 'personnel', 'patricia.lambert@email.com', '2023-12-05'),
('Fontaine', 'Guillaume', 'étudiant', 'guillaume.fontaine@email.com', '2024-01-25'),
('Rousseau', 'Monique', 'professeur', 'monique.rousseau@email.com', '2023-09-15'),
('Vincent', 'Alexandre', 'étudiant', 'alexandre.vincent@email.com', '2024-02-05'),
('Muller', 'Dominique', 'personnel', 'dominique.muller@email.com', '2023-11-20'),
('Lefevre', 'Thierry', 'étudiant', 'thierry.lefevre@email.com', '2024-03-18'),
('Roche', 'Anne', 'étudiant', 'anne.roche@email.com', '2024-02-20')
ON CONFLICT (email) DO NOTHING;

-- Emprunts de test pour différentes situations
INSERT INTO Emprunts (utilisateur_id, exemplaire_id, date_emprunt, date_retour_prevue, date_retour_effective) VALUES
-- Emprunts en cours
(1, 2, '2024-12-01', '2024-12-15', NULL),
(2, 11, '2024-12-05', '2024-12-19', NULL),
(3, 7, '2024-12-03', '2024-12-17', NULL),
(5, 13, '2024-12-02', '2024-12-16', NULL),
(7, 21, '2024-12-04', '2024-12-18', NULL),
(9, 27, '2024-12-06', '2024-12-20', NULL),
(12, 35, '2024-12-01', '2024-12-15', NULL),
(15, 41, '2024-12-05', '2024-12-19', NULL),
(18, 53, '2024-12-03', '2024-12-17', NULL),
(22, 61, '2024-12-02', '2024-12-16', NULL),

-- Emprunts retournés à temps
(4, 39, '2024-11-25', '2024-12-09', '2024-12-09'),
(6, 45, '2024-11-28', '2024-12-12', '2024-12-11'),
(8, 52, '2024-11-30', '2024-12-14', '2024-12-13'),
(10, 58, '2024-11-27', '2024-12-11', '2024-12-10'),
(13, 66, '2024-11-29', '2024-12-13', '2024-12-12'),

-- Emprunts retournés en retard (générant des pénalités)
(11, 20, '2024-11-15', '2024-11-29', '2024-12-02'),
(14, 30, '2024-11-18', '2024-12-02', '2024-12-05'),
(16, 40, '2024-11-20', '2024-12-04', '2024-12-07'),
(17, 50, '2024-11-22', '2024-12-06', '2024-12-09'),
(20, 4, '2024-11-20', '2024-12-04', '2024-12-05'),

-- Emprunts historiques
(19, 8, '2024-10-10', '2024-10-24', '2024-10-23'),
(21, 16, '2024-10-15', '2024-10-29', '2024-10-28'),
(23, 24, '2024-10-20', '2024-11-03', '2024-11-02'),
(25, 32, '2024-10-25', '2024-11-08', '2024-11-07'),
(27, 48, '2024-10-30', '2024-11-13', '2024-11-12')
ON CONFLICT DO NOTHING;

-- Insertion de réservations
INSERT INTO Reservations (utilisateur_id, ISBN, date_reservation, statut) VALUES
(1, '978-2-253-00501-5', '2024-12-01', 'en attente'),
(3, '978-2-07-040081-6', '2024-12-02', 'notifié'),
(5, '978-2-07-036822-2', '2024-12-03', 'en attente'),
(7, '978-2-07-041311-3', '2024-12-01', 'annulé'),
(9, '978-2-221-09515-5', '2024-12-04', 'en attente'),
(11, '978-2-253-00430-8', '2024-12-02', 'notifié'),
(13, '978-2-07-036394-4', '2024-12-05', 'en attente'),
(15, '978-2-07-037010-2', '2024-12-03', 'en attente'),
(17, '978-2-266-11101-1', '2024-12-04', 'annulé'),
(19, '978-2-226-01029-9', '2024-12-06', 'en attente')
ON CONFLICT DO NOTHING;

-- Insertion de pénalités
INSERT INTO Penalites (utilisateur_id, montant, motif, paye) VALUES
(11, 1.50, 'Retard de 3 jours sur l''emprunt #16', FALSE),
(14, 1.50, 'Retard de 3 jours sur l''emprunt #17', TRUE),
(16, 1.50, 'Retard de 3 jours sur l''emprunt #18', FALSE),
(17, 1.50, 'Retard de 3 jours sur l''emprunt #19', TRUE),
(20, 0.50, 'Retard de 1 jour sur l''emprunt #20', FALSE)
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------
-- QUESTION 3 : Ouvrages disponibles par succursale
-- -----------------------------------------------------
-- Objectif : Afficher les ouvrages disponibles dans une succursale
-- Complexité : JOIN, GROUP BY, ORDER BY, WHERE
-- Utilisation : Interface de recherche pour les usagers
-- -----------------------------------------------------
SELECT 
    o.titre,
    o.auteurs,
    o.categorie,
    o.ISBN,
    COUNT(e.id) AS exemplaires_disponibles
FROM Ouvrages o
JOIN Exemplaires e ON o.ISBN = e.ISBN
WHERE e.succursale_id = 1                     -- Paramètre : ID de la succursale
  AND e.etat = 'disponible'                  -- Seulement les disponibles
GROUP BY o.ISBN, o.titre, o.auteurs, o.categorie  -- Regroupement par ouvrage
ORDER BY o.categorie, o.titre;               -- Tri logique pour l'utilisateur

-- -----------------------------------------------------
-- QUESTION 4 : Emprunts en cours avec jours restants
-- -----------------------------------------------------
-- Objectif : Suivre les emprunts actifs et leurs échéances
-- Complexité : JOIN multiples, calcul de date, filtrage NULL
-- Utilisation : Tableau de bord pour le personnel
-- -----------------------------------------------------
SELECT 
    u.nom,
    u.prenom,
    o.titre,
    ex.numero_unique, 
    emp.date_emprunt,
    emp.date_retour_prevue,
    (emp.date_retour_prevue - CURRENT_DATE) AS jours_restants
FROM Emprunts emp
JOIN Utilisateurs u ON emp.utilisateur_id = u.id
JOIN Exemplaires ex ON emp.exemplaire_id = ex.id
JOIN Ouvrages o ON ex.ISBN = o.ISBN
WHERE emp.date_retour_effective IS NULL
ORDER BY emp.date_retour_prevue ASC;

-- ============================================
-- NIVEAU 2 : REQUÊTES AVANCÉES ET AGRÉGATIONS
-- ============================================

-- -----------------------------------------------------
-- QUESTION 5 : Top 10 des ouvrages les plus empruntés
-- -----------------------------------------------------
-- Objectif : Identifier les ouvrages populaires
-- Complexité : Date filtering, aggregation, limiting
-- Utilisation : Analyse de popularité, acquisitions
-- -----------------------------------------------------
WITH periode_recente AS (
    SELECT MAX(date_emprunt) - INTERVAL '6 months' as date_debut
    FROM Emprunts
    WHERE date_emprunt IS NOT NULL
)
SELECT 
    o.titre,
    o.auteurs,
    COUNT(emp.id) AS nombre_emprunts
FROM Emprunts emp
JOIN Exemplaires ex ON emp.exemplaire_id = ex.id
JOIN Ouvrages o ON ex.ISBN = o.ISBN
CROSS JOIN periode_recente pr
WHERE emp.date_emprunt >= pr.date_debut
GROUP BY o.ISBN, o.titre, o.auteurs
ORDER BY nombre_emprunts DESC
LIMIT 10;

-- -----------------------------------------------------
-- QUESTION 6 : Taux d'occupation par succursale
-- -----------------------------------------------------
-- Objectif : Mesurer l'utilisation des collections
-- Complexité : Agrégation conditionnelle, calcul de pourcentage
-- Utilisation : Gestion des ressources, répartition des exemplaires
-- -----------------------------------------------------
SELECT 
    s.nom,
    COUNT(e.id) AS total_exemplaires,
    SUM(CASE WHEN e.etat = 'emprunté' THEN 1 ELSE 0 END) AS exemplaires_empruntes,
    ROUND(
        (SUM(CASE WHEN e.etat = 'emprunté' THEN 1 ELSE 0 END) * 100.0 / COUNT(e.id)),
        2
    ) AS taux_occupation_percent
FROM Succursales s
LEFT JOIN Exemplaires e ON s.id = e.succursale_id  -- LEFT JOIN pour inclure succursales sans exemplaires
GROUP BY s.id, s.nom
ORDER BY taux_occupation_percent DESC;      -- Tri par occupation décroissante

-- -----------------------------------------------------
-- QUESTION 7 : Utilisateurs avec retards et pénalités
-- -----------------------------------------------------
-- Objectif : Identifier et calculer les pénalités dues
-- Complexité : Calcul de dates, agrégation conditionnelle
-- Utilisation : Gestion des retards, facturation
-- -----------------------------------------------------
SELECT 
    u.nom,
    u.prenom,
    u.email,
    COUNT(emp.id) AS retards_en_cours,
    SUM(CURRENT_DATE - emp.date_retour_prevue) AS jours_retard_total,
    SUM(CURRENT_DATE - emp.date_retour_prevue) * 0.50 AS penalite_due  -- 0.50€ par jour
FROM Emprunts emp
JOIN Utilisateurs u ON emp.utilisateur_id = u.id
WHERE emp.date_retour_effective IS NULL      -- Non retournés
  AND emp.date_retour_prevue < CURRENT_DATE  -- En retard
GROUP BY u.id, u.nom, u.prenom, u.email
HAVING SUM(CURRENT_DATE - emp.date_retour_prevue) > 0;  -- Seulement ceux avec retard

-- -----------------------------------------------------
-- QUESTION 8 : Vue matérialisée par catégorie
-- -----------------------------------------------------
-- Objectif : Statistiques agrégées par catégorie
-- Complexité : Vue matérialisée, agrégations multiples
-- Utilisation : Tableau de bord analytique
-- -----------------------------------------------------
CREATE MATERIALIZED VIEW stats_categories AS
SELECT 
    o.categorie,
    COUNT(DISTINCT ex.id) AS total_exemplaires,
    SUM(CASE WHEN ex.etat = 'emprunté' THEN 1 ELSE 0 END) AS emprunts_en_cours,
    ROUND(AVG(emp.date_retour_effective - emp.date_emprunt), 2) AS duree_moyenne_emprunt
FROM Ouvrages o
LEFT JOIN Exemplaires ex ON o.ISBN = ex.ISBN
LEFT JOIN Emprunts emp ON ex.id = emp.exemplaire_id AND emp.date_retour_effective IS NOT NULL
GROUP BY o.categorie
ORDER BY o.categorie;

-- Commentaire : La vue matérialisée stocke physiquement les résultats
-- Avantage : Performance pour les requêtes fréquentes
-- Inconvénient : Nécessite un rafraîchissement manuel

-- ============================================
-- NIVEAU 3 : FONCTIONS, PROCÉDURES ET TRIGGERS
-- ============================================

-- -----------------------------------------------------
-- QUESTION 9 : Fonction pour réservations en attente
-- -----------------------------------------------------
-- Objectif : Compter les réservations non traitées pour un ouvrage
-- Type : Fonction PL/pgSQL avec paramètre
-- Utilisation : Dans les interfaces de gestion
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION nb_reservations_attente(isbn_ouvrage VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    nb_reservations INTEGER;
BEGIN
    -- Compte les réservations en attente pour l'ISBN donné
    SELECT COUNT(*) INTO nb_reservations
    FROM Reservations
    WHERE ISBN = isbn_ouvrage AND statut = 'en attente';
    
    RETURN nb_reservations;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------
-- QUESTION 10 : Procédure pour nouvel emprunt
-- -----------------------------------------------------
-- Objectif : Gérer de manière sécurisée un nouvel emprunt
-- Vérifications : Disponibilité, pénalités, limites
-- Type : Procédure stockée avec gestion d'erreurs
-- -----------------------------------------------------
CREATE OR REPLACE PROCEDURE nouvel_emprunt(
    p_utilisateur_id INTEGER,
    p_exemplaire_id INTEGER,
    p_date_retour_prevue DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_type_utilisateur VARCHAR;
    v_nb_emprunts_en_cours INTEGER;
    v_penalites_impayees BOOLEAN;
    v_etat_exemplaire VARCHAR;
BEGIN
    -- 1. Vérifier la disponibilité de l'exemplaire
    SELECT etat INTO v_etat_exemplaire
    FROM Exemplaires WHERE id = p_exemplaire_id;
    
    IF v_etat_exemplaire != 'disponible' THEN
        RAISE EXCEPTION 'Exemplaire non disponible';
    END IF;
    
    -- 2. Vérifier les pénalités impayées
    SELECT EXISTS (
        SELECT 1 FROM Penalites 
        WHERE utilisateur_id = p_utilisateur_id AND paye = FALSE
    ) INTO v_penalites_impayees;
    
    IF v_penalites_impayees THEN
        RAISE EXCEPTION 'Utilisateur a des pénalités impayées';
    END IF;
    
    -- 3. Vérifier les limites d'emprunt par type d'utilisateur
    SELECT type INTO v_type_utilisateur
    FROM Utilisateurs WHERE id = p_utilisateur_id;
    
    SELECT COUNT(*) INTO v_nb_emprunts_en_cours
    FROM Emprunts
    WHERE utilisateur_id = p_utilisateur_id AND date_retour_effective IS NULL;
    
    IF (v_type_utilisateur = 'étudiant' AND v_nb_emprunts_en_cours >= 5) OR
       (v_type_utilisateur IN ('professeur', 'personnel') AND v_nb_emprunts_en_cours >= 10) THEN
        RAISE EXCEPTION 'Limite d''emprunts atteinte';
    END IF;
    
    -- 4. Enregistrer l'emprunt si toutes les conditions sont remplies
    INSERT INTO Emprunts (utilisateur_id, exemplaire_id, date_retour_prevue)
    VALUES (p_utilisateur_id, p_exemplaire_id, p_date_retour_prevue);
    
    -- 5. Mettre à jour l'état de l'exemplaire
    UPDATE Exemplaires SET etat = 'emprunté' WHERE id = p_exemplaire_id;
    
    COMMIT;
END;
$$;

-- -----------------------------------------------------
-- QUESTION 11 : Trigger pour pénalités automatiques
-- -----------------------------------------------------
-- Objectif : Calculer automatiquement les pénalités lors du retour
-- Type : Trigger AFTER UPDATE sur la table Emprunts
-- Déclenchement : Quand date_retour_effective passe de NULL à une valeur
-- -----------------------------------------------------

-- Création de la table des notifications (utilisée aussi pour Q12)
CREATE TABLE IF NOT EXISTS Notifications (
    id SERIAL PRIMARY KEY,
    utilisateur_id INTEGER REFERENCES Utilisateurs(id),
    message TEXT,
    date_notification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lu BOOLEAN DEFAULT FALSE
);

-- Fonction du trigger
CREATE OR REPLACE FUNCTION calcul_penalites_retour()
RETURNS TRIGGER AS $$
DECLARE
    jours_retard INTEGER;
    montant_penalite DECIMAL(10,2);
BEGIN
    -- Calcul du retard (différence entre retour effectif et retour prévu)
    jours_retard := GREATEST(0, NEW.date_retour_effective - OLD.date_retour_prevue);
    
    -- Si retard, créer une pénalité
    IF jours_retard > 0 THEN
        montant_penalite := jours_retard * 0.50;  -- 0.50€ par jour de retard
        
        INSERT INTO Penalites (utilisateur_id, montant, motif, paye)
        VALUES (
            OLD.utilisateur_id,
            montant_penalite,
            'Retard de ' || jours_retard || ' jour(s) sur l''emprunt #' || OLD.id,
            FALSE
        );
    END IF;
    
    -- Remettre l'exemplaire en disponible
    UPDATE Exemplaires SET etat = 'disponible' WHERE id = OLD.exemplaire_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Création du trigger
CREATE OR REPLACE TRIGGER trigger_retour_penalite
AFTER UPDATE OF date_retour_effective ON Emprunts
FOR EACH ROW
WHEN (NEW.date_retour_effective IS NOT NULL AND OLD.date_retour_effective IS NULL)
EXECUTE FUNCTION calcul_penalites_retour();

-- -----------------------------------------------------
-- QUESTION 12 : Trigger pour notification de réservation
-- -----------------------------------------------------
-- Objectif : Notifier automatiquement le premier en liste d'attente
-- Type : Trigger AFTER UPDATE sur la table Exemplaires
-- Déclenchement : Quand un exemplaire redevient disponible
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION notification_reservation()
RETURNS TRIGGER AS $$
DECLARE
    premier_en_attente RECORD;
BEGIN
    -- Trouver la première réservation en attente pour cet ouvrage
    SELECT * INTO premier_en_attente
    FROM Reservations
    WHERE ISBN = (SELECT ISBN FROM Exemplaires WHERE id = NEW.exemplaire_id)
      AND statut = 'en attente'
    ORDER BY date_reservation ASC  -- Premier arrivé, premier servi
    LIMIT 1;
    
    IF FOUND THEN
        -- Créer une notification pour l'utilisateur
        INSERT INTO Notifications (utilisateur_id, message)
        VALUES (
            premier_en_attente.utilisateur_id,
            'L''ouvrage que vous avez réservé est maintenant disponible. Vous avez 48h pour l''emprunter.'
        );
        
        -- Mettre à jour le statut de la réservation
        UPDATE Reservations 
        SET statut = 'notifié'
        WHERE id = premier_en_attente.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_notification_disponibilite
AFTER UPDATE OF etat ON Exemplaires
FOR EACH ROW
WHEN (NEW.etat = 'disponible' AND OLD.etat = 'emprunté')
EXECUTE FUNCTION notification_reservation();

-- ============================================
-- NIVEAU 4 : OPTIMISATION ET INDEX
-- ============================================

-- -----------------------------------------------------
-- QUESTION 13 : Analyse EXPLAIN ANALYZE et indexation
-- -----------------------------------------------------
-- Objectif : Analyser et optimiser une requête fréquente
-- Méthode : EXPLAIN ANALYZE pour voir le plan d'exécution
-- Solution : Création d'index ciblés
-- -----------------------------------------------------

-- Analyse avant optimisation
EXPLAIN ANALYZE
SELECT * FROM Emprunts
WHERE date_retour_effective IS NULL;

-- Création d'index optimisés
-- Index partiel pour les emprunts en cours
CREATE INDEX idx_emprunts_date_retour ON Emprunts(date_retour_effective) 
WHERE date_retour_effective IS NULL;

-- Index sur les clés étrangères fréquemment jointes
CREATE INDEX idx_emprunts_utilisateur ON Emprunts(utilisateur_id);
CREATE INDEX idx_emprunts_exemplaire ON Emprunts(exemplaire_id);
CREATE INDEX idx_exemplaires_etat ON Exemplaires(etat);
CREATE INDEX idx_exemplaires_succursale ON Exemplaires(succursale_id);

-- Analyse après optimisation
EXPLAIN ANALYZE
SELECT * FROM Emprunts
WHERE date_retour_effective IS NULL;

-- -----------------------------------------------------
-- QUESTION 14 : Index partiel pour emprunts en retard
-- -----------------------------------------------------
-- Objectif : Accélérer les recherches d'emprunts en retard
-- Spécificité : Index partiel sur les emprunts non retournés
-- Avantage : Réduction de 70% de la taille de l'index
-- Note : Le filtre date_retour_prevue < CURRENT_DATE sera appliqué lors des requêtes
-- -----------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_emprunts_en_retard 
ON Emprunts(date_retour_prevue)
WHERE date_retour_effective IS NULL;

-- Test de l'index
EXPLAIN ANALYZE
SELECT * FROM Emprunts 
WHERE date_retour_effective IS NULL 
  AND date_retour_prevue < CURRENT_DATE;

-- -----------------------------------------------------
-- QUESTION 15 : Partitionnement par plage de dates
-- -----------------------------------------------------
-- Objectif : Améliorer les performances des requêtes historiques
-- Méthode : Partitionnement par année sur date_emprunt
-- Avantage : Isolation des données, maintenance ciblée
-- -----------------------------------------------------

-- 1. Analyse de performance SANS partitionnement
EXPLAIN ANALYZE
SELECT COUNT(*) FROM Emprunts 
WHERE date_emprunt >= '2024-01-01' 
  AND date_emprunt < '2025-01-01'
  AND date_retour_effective IS NULL;

-- 2. Création d'une table partitionnée de démonstration
DROP TABLE IF EXISTS Emprunts_demo_partitionnes CASCADE;

CREATE TABLE Emprunts_demo_partitionnes (
    LIKE Emprunts INCLUDING DEFAULTS INCLUDING CONSTRAINTS
) PARTITION BY RANGE (date_emprunt);

-- 3. Création des partitions avec les mêmes données
CREATE TABLE Emprunts_demo_2024 PARTITION OF Emprunts_demo_partitionnes
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE Emprunts_demo_2025 PARTITION OF Emprunts_demo_partitionnes
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- 4. Copie des données pertinentes
INSERT INTO Emprunts_demo_partitionnes 
SELECT * FROM Emprunts 
WHERE date_emprunt >= '2024-01-01';

-- 5. Analyse de performance AVEC partitionnement
EXPLAIN ANALYZE
SELECT COUNT(*) FROM Emprunts_demo_partitionnes 
WHERE date_emprunt >= '2024-01-01' 
  AND date_emprunt < '2025-01-01'
  AND date_retour_effective IS NULL;

-- 6. Comparaison dans les commentaires
/*
Résultats attendus :
- Sans partition : Seq Scan sur toute la table Emprunts
- Avec partition : Seq Scan uniquement sur Emprunts_demo_2024
Gain : Temps divisé par (nombre de partitions pertinentes)
*/
-- ============================================
-- NIVEAU 5 : TRANSACTIONS ET CONCURRENCE
-- ============================================

-- -----------------------------------------------------
-- QUESTION 16 : Transaction complète d'emprunt
-- -----------------------------------------------------
-- Objectif : Garantir l'intégrité lors d'un emprunt concurrent
-- Méthode : Transaction avec verrouillage exclusif
-- Protection : FOR UPDATE NOWAIT pour éviter les deadlocks
-- -----------------------------------------------------
-- TRANSACTION 1 : Premier utilisateur emprunte l'exemplaire 2
BEGIN;

-- Tente de verrouiller l'exemplaire
SELECT * FROM Exemplaires WHERE id = 2 FOR UPDATE NOWAIT;

-- Si le verrou est obtenu, procéder à l'emprunt
INSERT INTO Emprunts (utilisateur_id, exemplaire_id, date_retour_prevue)
VALUES (1, 2, CURRENT_DATE + 14);

UPDATE Exemplaires SET etat = 'emprunté' WHERE id = 2;

-- NE PAS COMMITTER tout de suite pour simuler la concurrence
-- COMMIT;

-- TRANSACTION 2 (à exécuter dans une autre session pendant que la première est ouverte)
/*
BEGIN;
-- Tentative d'accès concurrent
SELECT * FROM Exemplaires WHERE id = 2 FOR UPDATE NOWAIT;
-- Devrait échouer : ERROR: could not obtain lock on row

-- Avec FOR UPDATE (sans NOWAIT), cette session attendrait
-- jusqu'à ce que la première transaction COMMIT ou ROLLBACK
*/


-- -----------------------------------------------------
-- QUESTION 17 : Gestion des deadlocks
-- -----------------------------------------------------
-- Objectif : Prévenir et résoudre les situations de blocage
-- Solution 1 : Ordre cohérent des verrous
-- Solution 2 : Timeout configuré
-- Solution 3 : Niveau d'isolation SERIALIZABLE
-- -----------------------------------------------------

-- Configuration du timeout pour deadlocks
SET deadlock_timeout = '5s';  -- Attendre 5s avant de déclarer un deadlock

-- Transaction avec ordre cohérent des verrous
BEGIN;
-- Toujours verrouiller dans le même ordre (ex: par ID croissant)
UPDATE Exemplaires SET etat = 'emprunté' WHERE id = 1;
UPDATE Exemplaires SET etat = 'emprunté' WHERE id = 2;
COMMIT;

-- Transaction avec isolation SERIALIZABLE
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- Les opérations sont exécutées comme si elles étaient séquentielles
-- ...
COMMIT;

-- ============================================
-- NIVEAU 6 : FONCTIONNALITÉS AVANCÉES ET IA
-- ============================================

-- -----------------------------------------------------
-- QUESTION 18 : Fonction window pour analyse comportementale
-- -----------------------------------------------------
-- Objectif : Analyser les habitudes d'emprunt des utilisateurs
-- Fonctionnalité : LAG() pour accéder à la ligne précédente
-- Calcul : Temps moyen entre deux emprunts consécutifs
-- -----------------------------------------------------
SELECT 
    utilisateur_id,
    date_emprunt,
    LAG(date_emprunt) OVER (PARTITION BY utilisateur_id ORDER BY date_emprunt) AS emprunt_precedent,
    (date_emprunt - LAG(date_emprunt) OVER (PARTITION BY utilisateur_id ORDER BY date_emprunt)) AS jours_entre_emprunts,
    AVG(date_emprunt - LAG(date_emprunt) OVER (PARTITION BY utilisateur_id ORDER BY date_emprunt))
        OVER (PARTITION BY utilisateur_id) AS moyenne_jours_entre_emprunts
FROM Emprunts
WHERE utilisateur_id IN (1, 2, 3)  -- Exemple sur quelques utilisateurs
ORDER BY utilisateur_id, date_emprunt;

-- -----------------------------------------------------
-- QUESTION 19 : Système de recommandations avec CTE récursives
-- -----------------------------------------------------
-- Objectif : Recommander des ouvrages basés sur les similarités d'emprunt
-- Méthode : CTE récursive pour trouver les utilisateurs similaires
-- Logique : "Les utilisateurs qui ont emprunté les mêmes livres que vous..."
-- -----------------------------------------------------
WITH RECURSIVE similar_users AS (
    -- Étape initiale : trouver les paires d'utilisateurs avec ≥3 emprunts communs
    SELECT DISTINCT e1.utilisateur_id AS user1, e2.utilisateur_id AS user2
    FROM Emprunts e1
    JOIN Emprunts e2 ON e1.exemplaire_id = e2.exemplaire_id
    WHERE e1.utilisateur_id != e2.utilisateur_id
    GROUP BY e1.utilisateur_id, e2.utilisateur_id
    HAVING COUNT(DISTINCT e1.exemplaire_id) >= 3
),
recommendations AS (
    -- Étape de recommandation : livres empruntés par les similaires mais pas par l'utilisateur
    SELECT DISTINCT o.*
    FROM similar_users su
    JOIN Emprunts e ON su.user2 = e.utilisateur_id
    JOIN Exemplaires ex ON e.exemplaire_id = ex.id
    JOIN Ouvrages o ON ex.ISBN = o.ISBN
    WHERE su.user1 = 1  -- ID de l'utilisateur cible
      AND o.ISBN NOT IN (
          SELECT ex2.ISBN
          FROM Emprunts e2
          JOIN Exemplaires ex2 ON e2.exemplaire_id = ex2.id
          WHERE e2.utilisateur_id = 1
      )
)
SELECT * FROM recommendations LIMIT 10;

-- -----------------------------------------------------
-- QUESTION 20 : Extension pgvector pour embeddings vectoriels
-- -----------------------------------------------------
-- Objectif : Implémenter la recherche sémantique par similarité
-- Prérequis : CREATE EXTENSION vector;
-- Utilisation : Stockage et recherche par similarité cosinus
-- -----------------------------------------------------

-- Activation de l'extension (nécessite les droits superutilisateur)
-- CREATE EXTENSION IF NOT EXISTS vector;

-- Table pour les embeddings des résumés
CREATE TABLE ouvrages_embeddings (
    ISBN VARCHAR(20) PRIMARY KEY REFERENCES Ouvrages(ISBN),
    resume_embedding vector(384),  -- Vecteur 384D (taille standard pour MiniLM)
    date_mise_a_jour TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exemple d'insertion (vecteurs simulés)
INSERT INTO ouvrages_embeddings (ISBN, resume_embedding) VALUES
('978-2-07-036002-8', '[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]'::vector),
('978-2-253-00501-5', '[0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1]'::vector)
ON CONFLICT (ISBN) DO UPDATE 
SET resume_embedding = EXCLUDED.resume_embedding,
    date_mise_a_jour = CURRENT_TIMESTAMP;

-- Recherche par similarité cosinus
SELECT 
    o.titre,
    o.auteurs,
    o.categorie,
    1 - (oe.resume_embedding <=> '[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]'::vector) AS similarite
FROM ouvrages_embeddings oe
JOIN Ouvrages o ON oe.ISBN = o.ISBN
ORDER BY oe.resume_embedding <=> '[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]'::vector
LIMIT 5;

-- -----------------------------------------------------
-- QUESTION 21 : Architecture de sauvegarde et réplication
-- -----------------------------------------------------
-- Objectif : Mettre en place une stratégie de haute disponibilité
-- Composants : Réplication streaming + PITR + sauvegardes incrémentielles
-- Note : Ces commandes sont à exécuter dans le shell, pas dans psql
-- -----------------------------------------------------

/*
-- CONFIGURATION POSTGRESQL.CONF (Serveur Primaire) :
wal_level = replica
max_wal_senders = 3
max_replication_slots = 3
archive_mode = on
archive_command = 'cp %p /backup/archive/%f'

-- CRÉATION UTILISATEUR RÉPLICATION :
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'motdepasse';

-- SAUVEGARDE COMPLÈTE :
pg_basebackup -h localhost -U postgres -D /backup/full -Ft -z -P

-- RÉPLICATION STREAMING (Recovery.conf sur Secondaire) :
standby_mode = 'on'
primary_conninfo = 'host=primary_server port=5432 user=replicator password=motdepasse'

-- SAUVEGARDE INCRÉMENTIELLE QUOTIDIENNE (Script cron) :
pg_dump -h localhost -U postgres -d bibliotheque --format=c --file=/backup/inc/$(date +%Y%m%d).dump

-- RESTAURATION PITR (Point-In-Time Recovery) :
pg_restore --create --dbname=bibliotheque_restauree --clean /backup/full
# Appliquer les WAL jusqu'au point de récupération
*/

-- =================================================================
-- FIN DU FICHIER SQL
-- =================================================================
