    BEGIN;

-- ======================================= CONSULTAS =======================================


--CONSULTA 1
SELECT
    c.circuitRef,
    COUNT(gp.name) as numero_de_grandes_premios
FROM
    pl1_final.circuits_final c JOIN pl1_final.races_final gp
    ON c.circuitRef = gp.circuitRef
GROUP BY 
    c.circuitRef
ORDER BY  
    numero_de_grandes_premios DESC;


/*
 CONSULTA 7
SELECT
    forename
    FROM
        pl1_final.results_final AS r JOIN pl1_final.drivers_final AS pi ON
        r.driverRef = pi.driverRef
    WHERE
        posicion = 1;
*/



ROLLBACK;
