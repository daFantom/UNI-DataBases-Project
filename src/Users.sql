\pset pager off
\set search_path = pl1_final, public;

create role administrador with login password 'admin';
create role gestor with login password 'gestionar';
create role analista with login password 'analizar';
create role invitado with login password 'guest';

revoke all privileges on database f1_bbdd from administrador, gestor, analista, invitado; -- Se les quita todos los permisos de antemano por seguridad.

grant usage on schema pl1_final to administrador, gestor, analista, invitado; -- Se les da el acceso al esquema pl1_final.

grant all privileges on all tables in schema pl1_final to administrador; -- El administrador tiene todos los privilegios sobre la bbdd

grant select, insert, update, delete on all tables in schema pl1_final to gestor; -- El gestor solo puede gestionar todas las tablas de las bases de datos.

grant select on all tables in schema pl1_final to analista; -- El analista solo puede ver el contenido de todas las tablas

grant select on table -- El invitado solo puede ver el contenido de ciertas tablas, a diferencia del analista.
    pl1_final.drivers_final, 
    pl1_final.circuits_final,
    pl1_final.constructors_final,
    pl1_final.races_final,
    pl1_final.results_final,
    pl1_final.seasons_final
to invitado;
