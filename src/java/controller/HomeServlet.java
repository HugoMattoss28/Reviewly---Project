package controller;

import DAO.UsuarioDAO;
import model.Serie;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet da Tela Inicial pública/usuário (/home).
 * Carrega o catálogo de séries do PostgreSQL e encaminha para home.jsp.
 * Caso o usuário logado na sessão seja ADMIN, home.jsp exibe opções extras de administração.
 */
@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    private final Controller controller = new Controller();
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            usuarioDAO.garantirEstruturaBanco();
            List<Serie> series = controller.listar();
            request.setAttribute("series", series);
        } catch (SQLException e) {
            request.setAttribute("series", List.of());
            request.setAttribute("erroListagem", "Erro ao carregar o catálogo do banco: " + e.getMessage());
        }

        request.getRequestDispatcher("/home.jsp").forward(request, response);
    }
}

