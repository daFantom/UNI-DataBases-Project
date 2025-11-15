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
        COUNT(r.gpRef) AS num_carreras,
        SUM(r.puntos) AS suma_puntos
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
    p.forename AS nombre_piloto 
    FROM
        pl1_final.results_final AS r JOIN pl1_final.drivers_final AS p ON
        r.pilotoRef = p.driverRef
    WHERE
        r.posicion = 1
    GROUP BY
        p.driverRef
    ORDER BY
        nombre_piloto ASC;

ROLLBACK;
