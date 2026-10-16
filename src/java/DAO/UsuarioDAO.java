package DAO;

import model.Usuario;
import util.ConexaoBD;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {

    /**
     * Garante que a tabela 'usuario' (e 'serie') exista no banco PostgreSQL
     * e cria um usuário ADMIN padrão caso ainda não exista.
     */
    public void garantirEstruturaBanco() throws SQLException {
        String sqlTabelaSerie = """
                CREATE TABLE IF NOT EXISTS serie (
                    id SERIAL PRIMARY KEY,
                    titulo VARCHAR(255) NOT NULL,
                    genero VARCHAR(120) NOT NULL,
                    ano_lancamento INT NOT NULL,
                    nota NUMERIC(4,2) NOT NULL,
                    src_imagem TEXT,
                    descricao TEXT,
                    autor VARCHAR(120)
                )
                """;

        String sqlTabelaUsuario = """
                CREATE TABLE IF NOT EXISTS usuario (
                    id SERIAL PRIMARY KEY,
                    nome VARCHAR(120) NOT NULL,
                    email VARCHAR(150) UNIQUE NOT NULL,
                    senha VARCHAR(120) NOT NULL,
                    perfil VARCHAR(20) NOT NULL DEFAULT 'USER'
                )
                """;

        String sqlCheckAdmin = "SELECT COUNT(*) FROM usuario WHERE UPPER(perfil) = 'ADMIN'";
        String sqlInsertAdmin = """
                INSERT INTO usuario (nome, email, senha, perfil)
                VALUES ('Administrador Reviewly', 'admin@reviewly.com', 'admin123', 'ADMIN')
                ON CONFLICT (email) DO NOTHING
                """;

        try (Connection conn = ConexaoBD.conectar();
             Statement stmt = conn.createStatement()) {

            stmt.execute(sqlTabelaSerie);
            stmt.execute(sqlTabelaUsuario);

            try (ResultSet rs = stmt.executeQuery(sqlCheckAdmin)) {
                if (rs.next() && rs.getInt(1) == 0) {
                    stmt.executeUpdate(sqlInsertAdmin);
                }
            }
        }
    }

    // AUTENTICAR LOGIN
    public Usuario autenticar(String email, String senha) throws SQLException {
        garantirEstruturaBanco();

        String sql = """
                SELECT id, nome, email, senha, perfil
                FROM usuario
                WHERE LOWER(email) = LOWER(?) AND senha = ?
                """;

        try (Connection conn = ConexaoBD.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email != null ? email.trim() : "");
            stmt.setString(2, senha != null ? senha : "");

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Usuario u = new Usuario();
                    u.setId(rs.getInt("id"));
                    u.setNome(rs.getString("nome"));
                    u.setEmail(rs.getString("email"));
                    u.setSenha(rs.getString("senha"));
                    u.setPerfil(rs.getString("perfil"));
                    return u;
                }
            }
        }
        return null;
    }

    // VERIFICAR SE EMAIL JÁ EXISTE
    public boolean emailExiste(String email) throws SQLException {
        garantirEstruturaBanco();

        String sql = "SELECT 1 FROM usuario WHERE LOWER(email) = LOWER(?)";

        try (Connection conn = ConexaoBD.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email != null ? email.trim() : "");
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    // CADASTRAR NOVO USUÁRIO
    public void cadastrar(Usuario usuario) throws SQLException {
        garantirEstruturaBanco();

        String sql = """
                INSERT INTO usuario (nome, email, senha, perfil)
                VALUES (?, ?, ?, ?)
                """;

        try (Connection conn = ConexaoBD.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, usuario.getNome().trim());
            stmt.setString(2, usuario.getEmail().trim().toLowerCase());
            stmt.setString(3, usuario.getSenha());
            stmt.setString(4, (usuario.getPerfil() != null && !usuario.getPerfil().isBlank())
                    ? usuario.getPerfil().toUpperCase()
                    : "USER");
            stmt.executeUpdate();
        }
    }

    // LISTAR TODOS OS USUÁRIOS
    public List<Usuario> listar() throws SQLException {
        garantirEstruturaBanco();

        String sql = "SELECT id, nome, email, perfil FROM usuario ORDER BY id ASC";
        List<Usuario> lista = new ArrayList<>();

        try (Connection conn = ConexaoBD.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Usuario u = new Usuario();
                u.setId(rs.getInt("id"));
                u.setNome(rs.getString("nome"));
                u.setEmail(rs.getString("email"));
                u.setPerfil(rs.getString("perfil"));
                lista.add(u);
            }
        }
        return lista;
    }
}

