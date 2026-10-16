package controller;

import DAO.Dao;
import model.Serie;

import java.sql.SQLException;
import java.util.List;

public class Controller {

    private final Dao dao;

    public Controller() {
        this.dao = new Dao();
    }

    // CADASTRAR
    public void cadastrar(Serie serie) throws SQLException, IllegalArgumentException {
        validarSerie(serie);
        dao.inserir(serie);
    }

    // LISTAR TODAS
    public List<Serie> listar() throws SQLException {
        return dao.listar();
    }

    // BUSCAR POR ID
    public Serie buscarPorId(int id) throws SQLException, IllegalArgumentException {
        if (id <= 0) {
            throw new IllegalArgumentException("O ID deve ser um número inteiro positivo.");
        }
        return dao.buscarPorId(id);
    }

    // ATUALIZAR
    public void atualizar(Serie serie) throws SQLException, IllegalArgumentException {
        if (serie == null || serie.getId() <= 0) {
            throw new IllegalArgumentException("ID inválido para atualização.");
        }
        validarSerie(serie);
        dao.atualizar(serie);
    }

    // EXCLUIR
    public void excluir(int id) throws SQLException, IllegalArgumentException {
        if (id <= 0) {
            throw new IllegalArgumentException("O ID deve ser um número inteiro positivo.");
        }
        dao.excluir(id);
    }

    // VALIDAÇÕES DE REGRAS DE NEGÓCIO
    private void validarSerie(Serie serie) {
        if (serie == null) {
            throw new IllegalArgumentException("Os dados da série não podem estar vazios.");
        }
        if (serie.getTitulo() == null || serie.getTitulo().trim().isEmpty()) {
            throw new IllegalArgumentException("O título da série é obrigatório.");
        }
        if (serie.getNota() < 0.0 || serie.getNota() > 10.0) {
            throw new IllegalArgumentException("A nota deve estar entre 0.0 e 10.0.");
        }
        if (serie.getAnoLancamento() <= 1800) {
            throw new IllegalArgumentException("O ano de lançamento informado é inválido.");
        }
    }
}
