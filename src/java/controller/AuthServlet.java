package controller;

import DAO.UsuarioDAO;
import model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Servlet responsável por Autenticação (Login, Cadastro de Usuário/Admin e Logout).
 * Mapeamento: /auth
 */
@WebServlet(name = "AuthServlet", urlPatterns = {"/auth"})
public class AuthServlet extends HttpServlet {

    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String acao = request.getParameter("acao");

        if ("logout".equalsIgnoreCase(acao)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/home?logout=1");
            return;
        }

        // Garante que a tabela usuario e o admin padrão existam ao abrir a tela de login
        try {
            usuarioDAO.garantirEstruturaBanco();
        } catch (SQLException ignored) {
        }

        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String acao = request.getParameter("acao");

        if ("login".equalsIgnoreCase(acao)) {
            processarLogin(request, response);
        } else if ("registrar".equalsIgnoreCase(acao)) {
            processarCadastro(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/auth");
        }
    }

    private void processarLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String senha = request.getParameter("senha");
        String destino = request.getParameter("destino");

        try {
            Usuario usuario = usuarioDAO.autenticar(email, senha);

            if (usuario == null) {
                request.setAttribute("erroAuth", "E-mail ou senha inválidos. Verifique suas credenciais.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("usuarioLogado", usuario);

            // Se for ADMIN e o destino for o painel (ou padrão admin), pode ir ao painel ou home
            if ("admin".equalsIgnoreCase(destino) && usuario.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/controller");
            } else {
                response.sendRedirect(request.getContextPath() + "/home?login=1");
            }

        } catch (SQLException e) {
            request.setAttribute("erroAuth", "Erro ao conectar ao banco de dados: " + e.getMessage());
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    private void processarCadastro(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String nome = request.getParameter("nome");
        String email = request.getParameter("email");
        String senha = request.getParameter("senha");
        String perfil = request.getParameter("perfil"); // "USER" ou "ADMIN"

        if (nome == null || nome.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            senha == null || senha.trim().isEmpty()) {
            request.setAttribute("erroAuth", "Preencha todos os campos obrigatórios para criar sua conta.");
            request.setAttribute("abaAtiva", "cadastro");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        try {
            if (usuarioDAO.emailExiste(email)) {
                request.setAttribute("erroAuth", "Este e-mail já está cadastrado no banco de dados.");
                request.setAttribute("abaAtiva", "cadastro");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            String perfilFinal = "ADMIN".equalsIgnoreCase(perfil) ? "ADMIN" : "USER";
            Usuario novo = new Usuario(0, nome.trim(), email.trim().toLowerCase(), senha, perfilFinal);
            usuarioDAO.cadastrar(novo);

            // Autentica automaticamente após o cadastro
            Usuario logado = usuarioDAO.autenticar(email, senha);
            HttpSession session = request.getSession(true);
            session.setAttribute("usuarioLogado", logado);

            response.sendRedirect(request.getContextPath() + "/home?cadastro=1");

        } catch (SQLException e) {
            request.setAttribute("erroAuth", "Erro ao cadastrar usuário no banco: " + e.getMessage());
            request.setAttribute("abaAtiva", "cadastro");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}

