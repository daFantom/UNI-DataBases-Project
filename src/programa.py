import sys
import psycopg2
import getpass

class PortException(Exception):
    """Excepción personalizada para errores de puerto"""
    pass


def ask_port(msg):
    """
    Solicita un puerto TCP válido
    Args:
        msg: Mensaje a mostrar al usuario
    Returns:
        int: Número de puerto válido
    Raises:
        PortException: Si el puerto no es válido
    """
    try:
        answer = input(msg)
        port = int(answer)
        
        # Validación del puerto
        if port < 1024 or port > 65535:
            raise PortException(f"El puerto {port} no está en el rango válido (1024-65535)")
        
        return port
    except ValueError:
        raise PortException("Por favor, introduce un número válido")
    except PortException as e:
        raise e


def ask_conn_parameters():
    """
    Solicita los parámetros de conexión a la base de datos
    Returns:
        tuple: (host, port, user, password, database)
    """
    print("=== Parámetros de conexión a la base de datos ===")
    
    host = 'localhost'
    
    while True:
        try:
            port = ask_port('Puerto TCP [5432]: ') or 5432
            break
        except PortException as e:
            print(f"Error: {e}. Inténtalo de nuevo.")
    
    user = input("Usuario: ").strip()
    
    # Usar getpass para ocultar la contraseña al escribir
    password = getpass.getpass("Contraseña: ").strip()
    
    database = input("Base de datos [f1_bbdd]: ").strip() or 'f1_bbdd'
    
    return host, port, user, password, database


def test_connection(conn_params):
    """
    Prueba la conexión a la base de datos
    Args:
        conn_params: Tupla con parámetros de conexión
    Returns:
        tuple: (bool, str, connection) - Éxito, mensaje, conexión
    """
    try:
        host, port, user, password, database = conn_params
        
        connstring = (
            f'host={host} '
            f'port={port} '
            f'user={user} '
            f'password={password} '
            f'dbname={database}'
        )
        
        conn = psycopg2.connect(connstring)
        return True, "¡Conexión exitosa!", conn
    
    except psycopg2.OperationalError as e:
        return False, f"Error de conexión: {e}", None
    except Exception as e:
        return False, f"Error inesperado: {e}", None


def execute_query(conn, query, params=None):
    """
    Ejecuta una consulta SQL
    Args:
        conn: Conexión a la base de datos
        query: Consulta SQL
        params: Parámetros para la consulta (opcional)
    Returns:
        list: Resultados de la consulta
    """
    try:
        with conn.cursor() as cur:
            if params:
                cur.execute(query, params)
            else:
                cur.execute(query)
            
            # Si es una consulta SELECT, devolver resultados
            if query.strip().upper().startswith('SELECT'):
                results = cur.fetchall()
                return results
            else:
                conn.commit()
                return cur.rowcount  # Número de filas afectadas
    except Exception as e:
        conn.rollback()
        raise e


def display_menu():
    """
    Muestra el menú de opciones
    """
    print("\n=== MENÚ PRINCIPAL ===============")
    print("1. Ejecutar consultas de la Parte 1")
    print("2. Insertar un nuevo gran premio y mostrar sus resultados")
    print("3. Probar permisos")
    print("4. Salir")
    print("====================================")

def display_opt1():
    """
    Muestra la lista de comandos
    """
    print("1. Lista de todos los circuitos con los GP que han albergado cada uno")
    print("2. Grandes Premios corridos por Ayrton Senna y sus puntos totales")
    print("3. Listado de pilotos nacidos a partir del año 2000 junto con las carreras en las que han participado")
    print("4. Todas las escuderías españolas e italianas junto con los GP corridos por cada una")
    print("5. Listado de Temporadas con sus pilotos y los puntos que han obtenido en la misma")
    print("6. Listado de pilotos ganadores de la temporada 2010 a 2015")
    print("7. Todos los pilotos que han ganado un GP")
    print("8. Ranking de GPs por país")
    print("9. Piloto con la vuelta más rápida de la historia")
    print("10. Listado de pilotos ordenada por el número de paradas en boxes en el GP de Monaco 2023")
    print("11. Listado de pilotos que participaron en más de 100 GPs")

def get_user_choice():
    """
    Obtiene la opción seleccionada por el usuario
    """
    try:
        choice = input("Selecciona una opción (de las disponibles): ").strip()
        return int(choice)
    except ValueError:
        return 0


def test_user_permissions(conn):
    """
    Prueba los permisos del usuario conectado
    """
    print("\n=== Prueba de permisos ===")
    
    tests = [
        ("SELECT", "SELECT * FROM information_schema.tables LIMIT 1;"),
        ("INSERT", "INSERT INTO prueba_permisos VALUES (1) -- Asumiendo tabla prueba_permisos;"),
        ("CREATE", "CREATE TABLE prueba_permisos_temp (id INT);"),
        ("DROP", "DROP TABLE IF EXISTS prueba_permisos_temp;"),
    ]
    
    for perm_type, query in tests:
        try:
            with conn.cursor() as cur:
                cur.execute(query)
                if perm_type == "SELECT":
                    cur.fetchone()  # Consumir resultado
                print(f"✓ Permiso {perm_type}: OK")
        except Exception as e:
            print(f"✗ Permiso {perm_type}: DENEGADO - {str(e).split('ERROR:')[1] if 'ERROR:' in str(e) else str(e)}")
    
    print("==========================")

def do_query(conn, query_num):
    """
    Ejecuta una consulta específica según el número
    """
    queries = {
        1: """
            SELECT
                c.name AS nombreGP,
                COUNT(gp.name) as numero_de_grandes_premios
            FROM
                pl1_final.circuits_final c 
                JOIN pl1_final.races_final gp ON c.circuitRef = gp.circuitRef
            GROUP BY 
                nombreGP
            ORDER BY  
                numero_de_grandes_premios DESC;
        """,
        
        2: """
            SELECT
                p.forename AS nombre,
                p.surname AS apellidos,
                COUNT(r.gpRef) AS num_carreras_totales,
                SUM(r.puntos) AS suma_puntos_totales
            FROM
                pl1_final.drivers_final AS p 
                JOIN pl1_final.results_final AS r ON p.driverRef = r.pilotoRef
            WHERE
                p.forename = 'Ayrton' AND p.surname = 'Senna'
            GROUP BY
                nombre, apellidos;
        """,
        
        3: """
            SELECT
                p.forename AS nombre,
                p.surname AS apellidos,
                COUNT(r.gpRef) AS num_carreras,
                p.dob AS cumple
            FROM
                pl1_final.drivers_final AS p 
                JOIN pl1_final.results_final AS r ON p.driverRef = r.pilotoRef
            WHERE
                p.dob > '1999-12-31'
            GROUP BY
                nombre, apellidos, cumple
            ORDER BY
                cumple ASC;
        """,
        
        4: """
            SELECT
                e.name AS nombre_escu,
                COUNT(r.gpRef) AS num_carreras
            FROM
                pl1_final.constructors_final AS e 
                JOIN pl1_final.results_final AS r ON e.constructorRef = r.escuderiaRef
            WHERE
                e.nationality = 'Spanish' OR e.nationality = 'Italian'
            GROUP BY
                nombre_escu
            ORDER BY
                nombre_escu;
        """,
        
        5: """
            CREATE OR REPLACE VIEW puntos_por_temporada AS
            SELECT
                rf.year AS anno,
                d.driverRef AS referencia,
                SUM(rf.puntos) AS puntos_totales
            FROM 
                pl1_final.results_final rf 
                JOIN pl1_final.drivers_final d ON rf.pilotoRef = d.driverRef
            GROUP BY 
                anno, referencia;
            
            SELECT * FROM puntos_por_temporada ORDER BY anno ASC, puntos_totales DESC;
        """,
        
        6: """
            SELECT
                *
            FROM
                puntos_por_temporada p1
            WHERE 
                anno >= 2010 AND anno <= 2015
                AND p1.puntos_totales = (
                    SELECT MAX(p2.puntos_totales)
                    FROM puntos_por_temporada p2
                    WHERE p2.anno = p1.anno
                )
            ORDER BY
                anno ASC;
        """,
        
        7: """
            SELECT
                p.forename AS nombre_piloto,
                p.surname AS apellido_piloto
            FROM
                pl1_final.results_final AS r 
                JOIN pl1_final.drivers_final AS p ON r.pilotoRef = p.driverRef
            WHERE
                r.posicion = 1
            GROUP BY
                p.driverRef, nombre_piloto, apellido_piloto
            ORDER BY
                nombre_piloto ASC;
        """,
        
        8: """
            SELECT
                cir.country,
                COUNT(gp.name) as numero_gp
            FROM
                pl1_final.races_final AS gp 
                JOIN pl1_final.circuits_final AS cir ON gp.circuitRef = cir.circuitRef
            GROUP BY
                cir.country
            ORDER BY
                COUNT(gp.name) DESC;
        """,
        
        9: """
            SELECT
                p.forename AS nombre,
                p.surname AS apellidos,
                v.time AS tiempo_vuelta
            FROM
                pl1_final.drivers_final AS p 
                JOIN pl1_final.lap_times_final AS v ON p.driverRef = v.driverRef
            WHERE
                v.time = (
                    SELECT MIN(time) FROM pl1_final.lap_times_final
                )
            GROUP BY
                nombre, apellidos, tiempo_vuelta;
        """,
        
        10: """
            SELECT
                p.forename AS nombre_piloto,
                p.surname AS apellidos_piloto,
                COUNT(ps.driverRef) as paradas_boxes
            FROM
                pl1_final.pit_stops_final AS ps 
                JOIN pl1_final.drivers_final AS p ON ps.driverRef = p.driverRef
            WHERE
                ps.raceRef = 'Monaco Grand Prix' AND ps.year = 2023
            GROUP BY
                nombre_piloto, apellidos_piloto
            ORDER BY
                paradas_boxes DESC;
        """,
        
        11: """
            SELECT
                p.driverRef AS referencia_piloto,
                p.forename AS nombre,
                p.surname AS apellido,
                COUNT(r.gpRef) AS cant_GP
            FROM
                pl1_final.results_final AS r 
                JOIN pl1_final.drivers_final AS p ON r.pilotoRef = p.driverRef
            GROUP BY
                referencia_piloto, nombre, apellido
            HAVING
                COUNT(r.gpRef) > 100
            ORDER BY
                cant_GP DESC;
        """
    }
    
    if query_num in queries:
        try:
            query = queries[query_num]
            
            # Ejecutar la consulta
            results = execute_query(conn, query)
            
            # Mostrar resultados
            if isinstance(results, list):
                if results:
                    print(f"\nResultados de la consulta {query_num}:")
                    print("-" * 50)
                    # Determinar el ancho de columna para mejor formato
                    for row in results:
                        print(row)
                    print(f"\nTotal de filas: {len(results)}")
                else:
                    print("No se encontraron resultados.")
            else:
                print(f"Consulta ejecutada exitosamente. Filas afectadas: {results}")
                
        except Exception as e:
            print(f"Error al ejecutar la consulta {query_num}: {e}")
    else:
        print("Número de consulta no válido.")
    

def main():
    """
    Función principal del programa
    """
    try:
        print("=== Conexión a Base de Datos Fórmula 1 ===")
        
        # Obtener parámetros de conexión
        conn_params = ask_conn_parameters()
        
        # Probar conexión
        success, message, conn = test_connection(conn_params)
        print(f"\n{message}")
        
        if not success:
            return
        
        # Menú principal
        while True:
            display_menu()
            choice = get_user_choice()
            match choice:
                case 1:
                    display_opt1()
                    sub_choice = get_user_choice()
                    if 1 <= sub_choice <= 11:
                        do_query(conn, sub_choice)
                    else:
                        print("Opción no válida.")
            
                case 2:
                    print("2")
            
                case 3:
                    # Probar permisos
                    test_user_permissions(conn)
            
                case 4:
                    print("¡Hasta luego!")
                    break
            
                case _:
                    print("Opción no válida. Inténtalo de nuevo.")
    
    except KeyboardInterrupt:
        print("\n\nPrograma interrumpido por el usuario.")
    except Exception as e:
        print(f"\nError inesperado: {e}")
    finally:
        # Cerrar conexión si existe
        if 'conn' in locals() and conn:
            conn.close()
            print("Conexión cerrada.")
        print("Programa finalizado.")


if __name__ == "__main__":
    # Verificar si estamos en modo prueba
    if '--test' in sys.argv:
        print("Modo prueba activado")
        # Aquí podrías añadir pruebas unitarias con pytest
        # pytest.main([__file__])
    else:
        main()