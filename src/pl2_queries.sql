\pset pager off
BEGIN;

-- ======================================= CONSULTAS =======================================


--CONSULTA 1
\echo 'Consulta 1: Cantidad de Grandes Premios en los que se ha corrido en cada circuito en la base de datos, ordenados de mayor a menor.'
SELECT
    c.name AS nombreGP,
    COUNT(gp.name) as numero_de_grandes_premios
FROM
    pl1_final.circuits_final c JOIN pl1_final.races_final gp
    ON c.circuitRef = gp.circuitRef
GROUP BY 
    nombreGP
ORDER BY  
    numero_de_grandes_premios DESC;

-- Consulta 2
\echo 'Consulta 2: Numero de grandes premios que ha corrido Ayrton Senna y el todal de puntos conseguidos en las mismas.'
SELECT
        p.forename AS nombre,
        p.surname AS apellidos,
        COUNT(r.gpRef) AS num_carreras_totales,
        SUM(r.puntos) AS suma_puntos_totales
    FROM
        pl1_final.drivers_final AS p JOIN pl1_final.results_final AS r ON
        p.driverRef = r.pilotoRef
    WHERE
        p.forename = 'Ayrton' AND
        p.surname = 'Senna'
    GROUP BY
        nombre, apellidos;

-- Consulta 3
\echo 'Consulta 3: Nombre y apellidos de todos los pilotos nacidos despues del 31-12-1999 y el numero de carreras participado'
SELECT
    p.forename AS nombre,
    p.surname AS apellidos,
    COUNT(r.gpRef) AS num_carreras,
    p.dob AS cumple
    FROM
        pl1_final.drivers_final AS p JOIN pl1_final.results_final AS r ON
        p.driverRef = r.pilotoRef
    WHERE
        p.dob > '1999-12-31'
    GROUP BY
        nombre,
        apellidos,
        cumple
    ORDER BY
        cumple ASC;

-- Consulta 4
\echo 'Consulta 4: Mostrar el nombre de todas las escuerias ESP o IT junto con su numero de GP corridos.'
SELECT
    e.name AS nombre_escu,
    COUNT(r.gpRef) AS num_carreras
    FROM
    pl1_final.constructors_final AS e JOIN pl1_final.results_final AS r ON
    e.constructorRef = r.escuderiaRef
    WHERE
        e.nationality = 'Spanish' OR e.nationality = 'Italian'
    GROUP BY
        nombre_escu
    ORDER BY
        nombre_escu;


-- CONSULTA 7
\echo 'Consulta 7: Nombre de los pilotos que han ganado almenos 1 vez.'
SELECT
    p.forename AS nombre_piloto,
    p.surname AS apellido_piloto -- Opcional, pero para no confundir con los nombres duplicados.
    FROM
        pl1_final.results_final AS r JOIN pl1_final.drivers_final AS p ON
        r.pilotoRef = p.driverRef
    WHERE
        r.posicion = 1
    GROUP BY
        p.driverRef
    ORDER BY
        nombre_piloto ASC;

-- Consulta 8
\echo 'Consulta 8: Numero de GP por pais.'
SELECT
    cir.country, COUNT(gp.name)
    FROM
        pl1_final.races_final AS gp JOIN pl1_final.circuits_final AS cir ON
        gp.circuitRef = cir.circuitRef
    GROUP BY
        cir.country
    ORDER BY
        COUNT(gp.name) DESC;

-- CONSULTA 9
\echo 'Consulta 9: Nombre del piloto con la vuelta mas rapida de la historia.'
-- Tuve que mirar en una pagina de tutoriales PSQL, llamada NEON, para ver como se podia aplicar la subconsulta para el MIN()
SELECT
    p.forename AS nombre,
    p.surname AS apellidos,
    v.time AS tiempo_vuelta
    FROM
        pl1_final.drivers_final AS p JOIN pl1_final.lap_times_final AS v ON
        p.driverRef = v.driverRef
    WHERE
    v.time = (
        SELECT
            MIN(time)
            FROM
            pl1_final.lap_times_final
    )
    GROUP BY
        nombre,
        apellidos,
        tiempo_vuelta;

-- CONSULTA 10
\echo 'Consulta 10: Numero de parades en boxes de cada piloto en el GP Monaco 2023'
SELECT
    p.forename AS nombre_piloto,
    p.surname AS apellidos_piloto,
    COUNT(ps.driverRef)
    FROM
        pl1_final.pit_stops_final AS ps JOIN pl1_final.drivers_final AS p ON
        ps.driverRef = p.driverRef
    WHERE
        ps.raceRef = 'Monaco Grand Prix' AND ps.year = 2023
    GROUP BY
        nombre_piloto,
        apellidos_piloto;

-- CONSULTA 11
\echo 'Consulta 11: Nombre de todos los pilotos que hayanm participado en mas de 100 premios, ordenados de mayor a menos.'
SELECT
    p.driverRef AS referencia_piloto,
    COUNT(r.gpRef) AS cant_GP
    FROM
        pl1_final.results_final AS r JOIN pl1_final.drivers_final AS p ON
        r.pilotoRef = p.driverRef
    GROUP BY
        referencia_piloto
    HAVING
        COUNT(r.gpRef) > 100
    ORDER BY
        cant_GP DESC; 

ROLLBACK;
