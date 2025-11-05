BEGIN;
-- Esquema temporal
\echo "Creando esquema temporal..."
CREATE SCHEMA IF NOT EXISTS pl1_temp;

\echo "Creando tablas temporales..."
CREATE TABLE IF NOT EXISTS pl1_temp.circuits_temp(
    circuitId       TEXT
    ,circuitRef     TEXT
    ,name           TEXT
    ,location       TEXT
    ,country        TEXT
    ,lat            TEXT
    ,lng            TEXT
    ,alt            TEXT
    ,url            TEXT
);

CREATE TABLE IF NOT EXISTS pl1_temp.constructors_temp(
    constructorId       TEXT
    ,constructorRef     TEXT
    ,name               TEXT
    ,nationality        TEXT
    ,url                TEXT
);

CREATE TABLE IF NOT EXISTS pl1_temp.drivers_temp(
    driverId        TEXT
    ,driverRef      TEXT
    ,number         TEXT
    ,code           TEXT
    ,forename       TEXT
    ,surname        TEXT
    ,dob            TEXT
    ,nationality    TEXT
    ,url            TEXT
);

CREATE TABLE IF NOT EXISTS pl1_temp.lap_times_temp(
    raceId          TEXT
    ,driverId       TEXT
    ,lap            TEXT
    ,position       TEXT
    ,time           TEXT
    ,milliseconds   TEXT
);

CREATE TABLE IF NOT EXISTS pl1_temp.races_temp(
    raceId          TEXT
    ,year           TEXT
    ,round          TEXT
    ,circuitId      TEXT
    ,name           TEXT
    ,date           TEXT
    ,time           TEXT
    ,url            TEXT
    ,fp1_date       TEXT
    ,fp1_time       TEXT
    ,fp2_date       TEXT
    ,fp2_time       TEXT
    ,fp3_date       TEXT
    ,fp3_time       TEXT
    ,quali_date     TEXT
    ,quali_time     TEXT
    ,sprint_date    TEXT
    ,sprint_time    TEXT
);

CREATE TABLE IF NOT EXISTS pl1_temp.results_temp(
    resultados_id           TEXT
    ,gpid                   TEXT
    ,pilotoid               TEXT
    ,escuderiaid            TEXT
    ,numero                 TEXT
    ,pos_parrilla           TEXT
    ,posicion               TEXT
    ,posiciontexto          TEXT
    ,posicionorden          TEXT
    ,puntos                 TEXT
    ,vueltas                TEXT
    ,tiempo                 TEXT
    ,tiempomilsgs           TEXT
    ,vueltarapida           TEXT
    ,puesto_campeonato      TEXT
    ,vueltarapida_tiempo    TEXT
    ,vueltarapida_velocidad TEXT
    ,estadoid               TEXT
);

CREATE TABLE IF NOT EXISTS pl1_temp.seasons_temp(
    year        TEXT
    ,url        TEXT
);

CREATE TABLE IF NOT EXISTS pl1_temp.status_temp(
    statusId        TEXT
    ,status         TEXT
);

CREATE TABLE IF NOT EXISTS pl1_temp.qualifying_temp(
    qualifyId           TEXT
    ,raceId             TEXT
    ,driverId           TEXT
    ,constructorId      TEXT
    ,number             TEXT
    ,position           TEXT
    ,q1                 TEXT
    ,q2                 TEXT
    ,q3                 TEXT
);

CREATE TABLE IF NOT EXISTS pl1_temp.pit_stops_temp(
    raceId          TEXT
    ,driverId       TEXT
    ,stop           TEXT
    ,lap            TEXT
    ,time           TEXT
    ,duration       TEXT
    ,milliseconds   TEXT
);

\echo "Cargando datos..."

\COPY pl1_temp.circuits_temp FROM circuits.csv WITH (FORMAT csv, HEADER, DELIMITER E',', NULL "\N", ENCODING "UTF-8")
\COPY pl1_temp.constructors_temp FROM constructors.csv WITH (FORMAT csv, HEADER, DELIMITER E',', NULL "\N", ENCODING "UTF-8")
\COPY pl1_temp.drivers_temp FROM drivers.csv WITH (FORMAT csv, HEADER, DELIMITER E',', NULL "\N", ENCODING "UTF-8")
\COPY pl1_temp.lap_times_temp FROM lap_times.csv WITH (FORMAT csv, HEADER, DELIMITER E',', NULL "\N", ENCODING "UTF-8")
\COPY pl1_temp.races_temp FROM races.csv WITH (FORMAT csv, HEADER, DELIMITER E',', NULL "\N", ENCODING "UTF-8")
\COPY pl1_temp.results_temp FROM results.csv WITH (FORMAT csv, HEADER, DELIMITER E',', NULL "\N", ENCODING "UTF-8")
\COPY pl1_temp.seasons_temp FROM seasons.csv WITH (FORMAT csv, HEADER, DELIMITER E',', NULL "\N", ENCODING "UTF-8")
\COPY pl1_temp.status_temp FROM status.csv WITH (FORMAT csv, HEADER, DELIMITER E',', NULL "\N", ENCODING "UTF-8")
\COPY pl1_temp.qualifying_temp FROM qualifying.csv WITH (FORMAT csv, HEADER, DELIMITER E',', NULL "\N", ENCODING "UTF-8")
\COPY pl1_temp.pit_stops_temp FROM pit_stops.csv WITH (FORMAT csv, HEADER, DELIMITER E',', NULL "\N", ENCODING "UTF-8")



            -- ESQUEMA DEFINITIVO / FINAL

\echo "Creando esquema definitivo / final..."
CREATE SCHEMA IF NOT EXISTS pl1_final;
\echo "Creando tablas finales..."
-- ====================== TABLA DE CIRCUITOS ======================
\echo "Creando tabla definitiva de circuitos..."
CREATE TABLE pl1_final.circuits_final(
    circuitRef     TEXT, -- PK
    name           TEXT,
    location       TEXT,
    country        TEXT,
    lat            REAL,
    lng            REAL,
    alt            INTEGER,
    url            TEXT,
    CONSTRAINT circuits_pk PRIMARY KEY (circuitRef)
);

-- ====================== TABLA DE ESCUDERIAS ======================
\echo "Creando tabla definitiva de las escuderias..."
CREATE TABLE pl1_final.constructors_final(
    constructorRef     TEXT, -- PK
    name               TEXT,
    nationality        TEXT,
    url                TEXT,
    CONSTRAINT constructors_pk PRIMARY KEY (constructorRef)
);
-- ====================== TABLA DE CONDUCTORES ======================
\echo "Creando tabla definitiva de los conductores..."
CREATE TABLE pl1_final.drivers_final(
    driverRef      TEXT, -- PK
    number         SMALLINT,
    code           TEXT,
    forename       TEXT,
    surname        TEXT,
    dob            TEXT,
    nationality    TEXT,
    url            TEXT,
    CONSTRAINT drivers_pk PRIMARY KEY (driverRef)
);

-- ====================== TABLA FINAL DE TEMPORADA ======================
\echo "Creando tabla definitiva de las temporadas..."
CREATE TABLE pl1_final.seasons_final(
    year       SMALLINT, -- PK
    url        TEXT,
    CONSTRAINT seasons_pk PRIMARY KEY (year)
);

-- ====================== TABLA DE GRANDES PREMIOS ======================
\echo "Creando tabla definitiva de los Grandes Premios..."
CREATE TABLE pl1_final.races_final(
    year           SMALLINT, -- Proveniente de Temporada [season] (FK, PK)
    round          SMALLINT,
    circuitRef     TEXT, -- Proveniente de circuito (FK)
    name           TEXT, -- PK
    date           DATE, 
    time           TIME WITHOUT TIME ZONE,
    url            TEXT, 
    CONSTRAINT races_pk PRIMARY KEY (name, year),
    CONSTRAINT races_fk1 FOREIGN KEY (year) REFERENCES pl1_final.seasons_final (year) ON DELETE RESTRICT ON UPDATE CASCADE, -- FK proveniente de la PK de Temporada.
    CONSTRAINT races_fk2 FOREIGN KEY (circuitRef) REFERENCES pl1_final.circuits_final (circuitRef) ON DELETE RESTRICT ON UPDATE CASCADE -- FK proveniente de la PK de circuito.
);

-- ====================== TABLA FINAL DE VUELTAS ======================
\echo "Creando tabla definitiva de las vueltas..."
CREATE TABLE pl1_final.lap_times_final(
    raceRef        TEXT, -- Proveniente de Gran Premio [races] (PK, FK)
    driverRef      TEXT, -- Proveniente de Piloto [drivers] (PK, FK)
    lap            SMALLINT, -- PK
    position       SMALLINT,
    time           TEXT,
    year           SMALLINT, -- Proveniente de temporada, pero forma parte de la PK de Gran Premio (PK, FK)
    CONSTRAINT lap_times_pk PRIMARY KEY (lap, driverRef, raceRef, year),
    CONSTRAINT lap_times_fk1 FOREIGN KEY (raceRef, year) REFERENCES pl1_final.races_final(name, year) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT lap_times_fk2 FOREIGN KEY (driverRef) REFERENCES pl1_final.drivers_final(driverRef) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ====================== TABLA FINAL DE CORRE / CARRERAS ======================
\echo "Creando tabla definitiva de las carreras..."
CREATE TABLE pl1_final.results_final(
    gpRef                  TEXT, -- Proveniente de Gran Premio [races] (PK,FK)
    pilotoRef              TEXT, -- Proveniente de Piloto [drivers] (PK, FK)
    escuderiaRef           TEXT, -- Proveniente de Escuderia [constructors] (PK, FK)
    posicion               SMALLINT,
    puntos                 REAL,
    estado                 TEXT, -- Proveniente de Estado [status] (FK)
    year                   SMALLINT,
    CONSTRAINT results_pk PRIMARY KEY (gpRef, pilotoRef, escuderiaRef, year),
    CONSTRAINT results_fk1 FOREIGN KEY (pilotoRef) REFERENCES pl1_final.drivers_final(driverRef) ON DELETE RESTRICT ON UPDATE CASCADE, -- FK que es la PK proveniente de Pilotos
    CONSTRAINT results_fk2 FOREIGN KEY (escuderiaRef) REFERENCES pl1_final.constructors_final(constructorRef) ON DELETE RESTRICT ON UPDATE CASCADE, -- FK que es la PK proveniente de Escuderia
    CONSTRAINT results_fk3 FOREIGN KEY (year, gpRef) REFERENCES pl1_final.races_final(year, name) ON DELETE RESTRICT ON UPDATE CASCADE -- FKs que provienen de la PK compuesta por ambos atributos de Gran Premio
);

-- ====================== TABLA FINAL DE CALIFICA / CALIFICACIONES ======================
\echo "Creando tabla definitiva de las calificaciones..."
CREATE TABLE pl1_final.qualifying_final(
    raceRef            TEXT, -- Proveniente de Gran Premio [races] (PK, FK)
    driverRef          TEXT, -- Proveniente de Piloto [drivers] (PK, FK)
    position           TEXT,
    q1                 TEXT,
    q2                 TEXT,
    q3                 TEXT,
    year               SMALLINT, -- Proveniente de Gran Premio -> traspaso de la PK como FK
    CONSTRAINT qualifying_pk PRIMARY KEY (raceRef, driverRef, year),
    CONSTRAINT qualifying_fk1 FOREIGN KEY (raceRef, year) REFERENCES pl1_final.races_final(name, year) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT qualifying_fk2 FOREIGN KEY (driverRef) REFERENCES pl1_final.drivers_final(driverRef) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ====================== TABLA FINAL DE BOXES / PARADAS EN ESCUDERIA ======================
\echo "Creando tabla definitiva de los boxes / paradas en escuderias..."
CREATE TABLE pl1_final.pit_stops_final(
    raceRef        TEXT, -- Proveniente de Gran Premio [races] (PK, FK)
    driverRef      TEXT, -- Proveniente de Piloto [drivers] (PK, FK)
    lap            SMALLINT, -- Proveniente de Vuelta [lap_time] (PK, FK)
    year           SMALLINT, -- Proveniente de Temporada [season] (PK, FK)
    time           TEXT,
    duration       TEXT,
    CONSTRAINT pit_stops_pk PRIMARY KEY (lap, raceRef, driverRef, year),
    CONSTRAINT pit_stop_fk1 FOREIGN KEY (lap, driverRef, raceRef, year) REFERENCES pl1_final.lap_times_final(lap, driverRef, raceRef, year) ON DELETE RESTRICT ON UPDATE CASCADE
);








        -- CARGA DE DATOS

-- ====================== CARGA EN CIRCUITOS ======================
\echo "Cargando datos en a tabla de circuitos..."
INSERT INTO pl1_final.circuits_final(circuitRef, name, location, country, lat, lng, alt, url)
    SELECT
        circuitRef, name, location, country, lat::REAL, lng::REAL, alt::INTEGER, url -- Funciona
        FROM
            pl1_temp.circuits_temp;


-- ====================== CARGA EN ESCUDERIAS ======================
\echo "Cargando datos en a tabla de escuderias..."
INSERT INTO pl1_final.constructors_final(constructorRef, name, nationality, url)
    SELECT
        constructorRef, name, nationality, url -- Funciona
        FROM
            pl1_temp.constructors_temp;


-- ====================== CARGA EN CONDUCTORES ======================
\echo "Cargando datos en a tabla de conductores..."
INSERT INTO pl1_final.drivers_final(driverRef, number, code, forename, surname, dob, nationality, url)
    SELECT
        driverRef, number::SMALLINT, code, forename, surname, dob, nationality, url -- Funciona
        FROM
            pl1_temp.drivers_temp;


-- ====================== CARGA EN TEMPORADAS ======================
\echo "Cargando datos en a tabla de temporadas..."
INSERT INTO pl1_final.seasons_final(year, url)
    SELECT
        year::SMALLINT, url -- Funciona
        FROM
            pl1_temp.seasons_temp;

-- ====================== CARGA EN GRANDES PREMIOS ======================
\echo "Cargando datos en a tabla de Grandes Premios..."
INSERT INTO pl1_final.races_final(year, round, circuitRef, name, date, time, url)
    SELECT
        year::SMALLINT, round::SMALLINT, circuitRef, gp_temp.name, date::DATE, time::TIME WITHOUT TIME ZONE, gp_temp.url
        FROM
            pl1_temp.races_temp AS gp_temp JOIN pl1_temp.circuits_temp AS circuito_temp ON gp_temp.circuitId = circuito_temp.circuitId;

-- ====================== CARGA EN RESULTADOS ======================
\echo "Cargando datos en a tabla de carreras / relacion 'corre'..."
INSERT INTO pl1_final.results_final(gpRef, pilotoRef, escuderiaRef, posicion, puntos, year)
    SELECT 
        gp_temp.name, conductor_temp.driverRef, escu_temp.constructorRef, corre_temp.posicion::INTEGER, corre_temp.puntos::REAL, gp_temp.year::SMALLINT
        FROM
            pl1_temp.results_temp AS corre_temp JOIN pl1_temp.races_temp AS gp_temp ON corre_temp.gpid = gp_temp.raceId JOIN 
            pl1_temp.constructors_temp AS escu_temp ON corre_temp.escuderiaid = escu_temp.constructorId JOIN 
            pl1_temp.drivers_temp AS conductor_temp ON corre_temp.pilotoid = conductor_temp.driverId JOIN 
            pl1_temp.status_temp AS estado_temp ON corre_temp.estadoid = estado_temp.statusId;

-- ====================== CARGA EN VUELTAS ======================
\echo "Cargando datos en a tabla de Vueltas..."
INSERT INTO pl1_final.lap_times_final(raceRef, driverRef, lap, position, time, year)
    SELECT
        gp_temp.name, driverRef, lap::SMALLINT, position::SMALLINT, vueltas_temp.time, year::SMALLINT
        FROM
            pl1_temp.lap_times_temp AS vueltas_temp JOIN pl1_temp.races_temp AS gp_temp ON vueltas_temp.raceId = gp_temp.raceId JOIN
            pl1_temp.drivers_temp AS pilotos_temp ON vueltas_temp.driverId = pilotos_temp.driverId;

-- ====================== CARGA EN CALIFICACIONES ======================
\echo "Cargando datos en a tabla de Calificaciones..."
INSERT INTO pl1_final.qualifying_final(raceRef, driverRef, position, q1, q2, q3, year)
    SELECT
        gp_temp.name, pilotos_temp.driverRef, position::SMALLINT, q1, q2, q3, gp_temp.year::SMALLINT
        FROM
            pl1_temp.qualifying_temp AS calis_temp JOIN pl1_temp.races_temp AS gp_temp ON calis_temp.raceId = gp_temp.raceId JOIN
            pl1_temp.drivers_temp AS pilotos_temp ON calis_temp.driverId = pilotos_temp.driverId;

-- ====================== CARGA EN PIT-STOPS / BOXES ======================
\echo "Cargando datos en a tabla de Pit-Stops..."
INSERT INTO pl1_final.pit_stops_final(raceRef, driverRef, lap, year, time, duration)
    SELECT
        gp_temp.name, conductor_temp.driverRef, boxes_temp.lap::SMALLINT, gp_temp.year::SMALLINT, boxes_temp.time, boxes_temp.duration
        FROM
            pl1_temp.pit_stops_temp AS boxes_temp JOIN pl1_temp.races_temp AS gp_temp ON boxes_temp.raceId = gp_temp.raceId JOIN
            pl1_temp.drivers_temp AS conductor_temp ON boxes_temp.driverId = conductor_temp.driverId;









-- ======================================= Pruebas =======================================

\echo "Muestra la cantidad de elementos en cada tabla"
SELECT
    count(*)
    FROM
        pl1_final.circuits_final -- Cantidad  elems circuitos
        ;

SELECT
    count(*)
    FROM
        pl1_final.constructors_final -- Cantidad  elems constructores
        ;

SELECT
    count(*)
    FROM
        pl1_final.drivers_final -- Cantidad  elems conductores
        ;

SELECT
    count(*)
    FROM
        pl1_final.seasons_final -- Cantidad  elems temporadas
        ;

ROLLBACK; -- Para que no se guarden los datos.


