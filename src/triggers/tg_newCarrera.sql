\pset pager off

create table if not exists puntos(
    piloto_ref          text,
    puntos_totales      real,
    constraint puntosPK primary key (piloto_ref)          
);


-- ========== INSERCION DE DATOS EN LA TABLA DE PUNTOS ==========
-- Inserta a todos los pilotos y la suma de sus puntos totales.
insert into puntos
select c.pilotoRef as referenciaP, SUM(c.puntos)
from pl1_final.results_final as c
group by referenciaP
order by SUM(c.puntos);



-- ========== FUNCIONES PARA LOS TRIGGERS DE INSERCION DE NUEVA CARRERA ==========
create or replace function fn_nuevaCarrera() returns trigger as $fn_nuevaCarrera$
    declare
    --nada
    begin
        if TG_OP='INSERT' then
            if(NEW.piloto_ref in (select piloto_ref from puntos)) then
                update puntos
                set puntos_totales = puntos_totales + NEW.puntos
                where piloto_ref = NEW.pilotoRef;
            else
                insert into puntos(piloto_ref, puntos_totales) values (NEW.piloto_ref, NEW.puntos);
            end if;
        elsif TG_OP='UPDATE' then
            update puntos
            set puntos_totales = puntos_totales + (NEW.puntos - OLD.puntos)
            where piloto_ref = NEW.pilotoRef;
        elsif TG_OP='DELETE' then
            update puntos
            set puntos_totales = puntos_totales - OLD.puntos
            where piloto_ref = OLD.pilotoRef;
        end if;
        return null;
    end
$fn_nuevaCarrera$ language plpgsql;
-- ||||||||||||||||| FIN FUNCIONES PARA LOS TRIGGERS  DE INSERCION DE NUEVA CARRERA ||||||||||||||||| 

--  ========== TRIGGERS ==========
CREATE TRIGGER tg_insercionCarrera after INSERT or UPDATE or DELETE
    ON pl1_final.results_final FOR EACH ROW
    EXECUTE PROCEDURE fn_nuevaCarrera();


