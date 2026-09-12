package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class conexao {

    private static final String URL = "jdbc:postgresql://localhost:5432/reviewfyBD";
    private static final String USUARIO = "postgres";
    private static final String SENHA = "SUA_SENHA";

    public static Connection conectar() throws SQLException {
        return DriverManager.getConnection(URL, USUARIO, SENHA);
    }
}