CREATE TABLE IF NOT EXISTS auditoria(
    id_aud          SERIAL,
    event           TEXT,
    tablename       TEXT,
    user_from       TEXT,
    date_time       TIMESTAMP,
    trigger_from    TEXT,
    CONSTRAINT auditoria_pk PRIMARY KEY (id_aud)
);

-- ========== FUNCIONES PARA LOS TRIGGERS  ==========
CREATE OR REPLACE FUNCTION fn_auditoria() RETURNS TRIGGER AS $fn_auditoria$
    DECLARE
    -- nada xd
    BEGIN
        IF TG_OP='INSERT' THEN
            INSERT INTO auditoria(event, tablename, user_from, date_time, trigger_from) VALUES (TG_OP, TG_TABLE_NAME, current_user, current_timestamp, TG_NAME);
        ELSIF TG_OP='UPDATE' THEN
            INSERT INTO auditoria(event, tablename, user_from, date_time, trigger_from) VALUES (TG_OP, TG_TABLE_NAME, current_user, current_timestamp, TG_NAME);
        ELSIF TG_OP='DELETE' THEN
            INSERT INTO auditoria(event, tablename, user_from, date_time, trigger_from) VALUES (TG_OP, TG_TABLE_NAME, current_user, current_timestamp, TG_NAME);
        END IF;
        RETURN NULL;
    END
    $fn_auditoria$ LANGUAGE plpgsql;

-- ||||||||||||||||| FIN FUNCIONES PARA LOS TRIGGERS |||||||||||||||||

--  ========== TRIGGERS ==========
CREATE TRIGGER tg_auditoria_circuits after INSERT or UPDATE or DELETE
    ON pl1_final.circuits_final FOR EACH ROW
    EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria_constructors after INSERT or UPDATE or DELETE
    ON pl1_final.constructors_final FOR EACH ROW
    EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria_drivers after INSERT or UPDATE or DELETE
    ON pl1_final.drivers_final FOR EACH ROW
    EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria_seasons after INSERT or UPDATE or DELETE
    ON pl1_final.seasons_final FOR EACH ROW
    EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria_races after INSERT or UPDATE or DELETE
    ON pl1_final.races_final FOR EACH ROW
    EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria_lap_times after INSERT or UPDATE or DELETE
    ON pl1_final.lap_times_final FOR EACH ROW
    EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria_results after INSERT or UPDATE or DELETE
    ON pl1_final.results_final FOR EACH ROW
    EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria_qualifying after INSERT or UPDATE or DELETE
    ON pl1_final.qualifying_final FOR EACH ROW
    EXECUTE PROCEDURE fn_auditoria();

CREATE TRIGGER tg_auditoria_pit_stops after INSERT or UPDATE or DELETE
    ON pl1_final.pit_stops_final FOR EACH ROW
    EXECUTE PROCEDURE fn_auditoria();


