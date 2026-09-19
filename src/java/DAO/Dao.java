package dao;

import model.Serie;
import util.Conexao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SerieDAO {

    // INSERIR
    public void inserir(Serie serie) throws SQLException {

        String sql = """
                INSERT INTO serie
                (titulo, genero, ano_lancamento, nota, src_imagem, descricao, autor)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection conn = Conexao.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, serie.getTitulo());
            stmt.setString(2, serie.getGenero());
            stmt.setInt(3, serie.getAnoLancamento());
            stmt.setDouble(4, serie.getNota());
            stmt.setString(5, serie.getSrcImagem());
            stmt.setString(6, serie.getDescricao());
            stmt.setString(7, serie.getAutor());
            stmt.executeUpdate();
        }
    }

    // LISTAR TODAS
    public List<Serie> listar() throws SQLException {

        String sql = """
                SELECT id, titulo, genero, ano_lancamento,
                       nota, src_imagem, descricao, autor
                FROM serie
                """;

        List<Serie> series = new ArrayList<>();

        try (Connection conn = Conexao.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {

                Serie serie = new Serie();

                serie.setId(rs.getInt("id"));
                serie.setTitulo(rs.getString("titulo"));
                serie.setGenero(rs.getString("genero"));
                serie.setAnoLancamento(rs.getInt("ano_lancamento"));
                serie.setNota(rs.getDouble("nota"));
                serie.setSrcImagem(rs.getString("src_imagem"));
                serie.setDescricao(rs.getString("descricao"));
                serie.setAutor(rs.getString("autor"));

                series.add(serie);
            }
        }

        return series;
    }

    // BUSCAR POR ID
    public Serie buscarPorId(int id) throws SQLException {

        String sql = """
                SELECT id, titulo, genero, ano_lancamento,
                       nota, src_imagem, descricao, autor
                FROM serie
                WHERE id = ?
                """;

        try (Connection conn = Conexao.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {

                if (rs.next()) {

                    Serie serie = new Serie();

                    serie.setId(rs.getInt("id"));
                    serie.setTitulo(rs.getString("titulo"));
                    serie.setGenero(rs.getString("genero"));
                    serie.setAnoLancamento(rs.getInt("ano_lancamento"));
                    serie.setNota(rs.getDouble("nota"));
                    serie.setSrcImagem(rs.getString("src_imagem"));
                    serie.setDescricao(rs.getString("descricao"));
                    serie.setAutor(rs.getString("autor"));

                    return serie;
                }
            }
        }

        return null;
    }

    // ATUALIZAR
    public void atualizar(Serie serie) throws SQLException {

        String sql = """
                UPDATE serie
                SET titulo = ?,
                    genero = ?,
                    ano_lancamento = ?,
                    nota = ?,
                    src_imagem = ?,
                    descricao = ?,
                    autor = ?
                WHERE id = ?
                """;

        try (Connection conn = Conexao.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, serie.getTitulo());
            stmt.setString(2, serie.getGenero());
            stmt.setInt(3, serie.getAnoLancamento());
            stmt.setDouble(4, serie.getNota());
            stmt.setString(5, serie.getSrcImagem());
            stmt.setString(6, serie.getDescricao());
            stmt.setString(7, serie.getAutor());
            stmt.setInt(8, serie.getId());

            stmt.executeUpdate();
        }
    }

    // EXCLUIR
    public void excluir(int id) throws SQLException {

        String sql = "DELETE FROM serie WHERE id = ?";

        try (Connection conn = Conexao.conectar();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            stmt.executeUpdate();
        }
    }
}
