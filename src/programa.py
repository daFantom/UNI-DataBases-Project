import sys
import psycopg2
import pytest

class portException(Exception): pass

def ask_port(msg):
    """
        ask for a valid TCP port
        ask_port :: String -> IO Integer | Exception
    """
    try:                                                                        # try
        answer  = input(msg)                                                    # pide el puerto
        port    = int(answer)                                                   # convierte a entero
        if (port < 1024) or (port > 65535):                                     # si el puerto no es valido
            raise ValueError                                                    # lanza una excepción
        else:
            return port
    except ValueError:     
        raise portException                                                     # raise portException
    #finally:                                                                    # finally
    #    return port                                                             # return port

def ask_conn_parameters():
    """
        ask_conn_parameters:: () -> IO String
        pide los parámetros de conexión
        TODO: cada estudiante debe introducir los valores para su base de datos
    """
    host = 'localhost'                                                          # 
    port = ask_port('TCP port number: ')                                        # pide un puerto TCP
    user = input("Usuario: ")                                                   # TODO
    password = str(input("Contraseña: "))                                       # TODO
    database = 'f1_bbdd'                                                        # TODO
    return (host, port, user,
             password, database)

def main():
    """
        main :: () -> IO None
    """
    try:
        (host, port, user, password, database) = ask_conn_parameters()          #
        print(f"Conectando a {host}:{port} como {user}...")
        connstring = f'host={host} port={port} user={user} password={password} dbname={database}' 
        conn    = psycopg2.connect(connstring)                                                                      
        print("¡Conexión exitosa!")
        cur     = conn.cursor()                                                 # instacia un cursor
        query   = 'SELECT * FROM pl1_final.results_final;'                                       # prepara una consulta
        cur.execute(query)                                                      # ejecuta la consulta
        for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
            print(record)                                                       # imprime las filas
        cur.close                                                               # cierra el cursor
        conn.close                                                              # cierra la conexion
    except portException:
        print("The port is not valid!")
    except KeyboardInterrupt:
        print("Program interrupted by user.")
    except psycopg2.OperationalError:
        print("Error operacional de psycop2")
    except UnicodeDecodeError:
        print("Error de codificación")
    
    finally:
        print("Program finished")

#def prueba_conexion():


if __name__ == "__main__":                                                      # Es el modula principal?
    if '--test' in sys.argv:                                                    # chequea el argumento cmdline buscando el modo test
        import doctest                                                          # importa la libreria doctest
        doctest.testmod()                                                       # corre los tests
    else:                                                                       # else
        main()                                                                  # ejecuta el programa principal
