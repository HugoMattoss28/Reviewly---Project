package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexaoBD {

    private static final String URL =
        "jdbc:postgresql://localhost:5432/reviewfyBD";

    private static final String USUARIO = "postgres";
    private static final String SENHA = "hugo2018";

    public static Connection conectar() throws SQLException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver JDBC do PostgreSQL não encontrado no classpath.", e);
        }
        return DriverManager.getConnection(URL, USUARIO, SENHA);
    }
}