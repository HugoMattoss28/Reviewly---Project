package controller;

import DAO.UsuarioDAO;
import model.Serie;
import model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet do Painel do Administrador (index.jsp) — CRUD Completo de Séries.
 * Mapeamento: /controller
 *
 * Protegido: exige que o usuário esteja logado na sessão com perfil ADMIN.
 */
@WebServlet(name = "SerieServlet", urlPatterns = {"/controller"})
public class SerieServlet extends HttpServlet {

    private final Controller controller = new Controller();
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    private boolean verificarAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        Usuario logado = (session != null) ? (Usuario) session.getAttribute("usuarioLogado") : null;

        if (logado == null || !logado.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/auth?restrito=1");
            return false;
        }
        return true;
    }

    // -------------------------------------------------------------------------
    // GET: verifica permissão de Admin, processa exclusão rápida (se houver)
    //      e carrega dados para o Painel do Administrador (index.jsp)
    // -------------------------------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!verificarAdmin(request, response)) {
            return;
        }

        String acao = request.getParameter("acao");
        String origem = request.getParameter("origem");

        if ("excluir".equalsIgnoreCase(acao)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                controller.excluir(id);
                if ("home".equalsIgnoreCase(origem)) {
                    response.sendRedirect(request.getContextPath() + "/home?excluido=1");
                } else {
                    response.sendRedirect(request.getContextPath() + "/controller?excluido=1");
                }
                return;
            } catch (Exception e) {
                request.setAttribute("erroFormulario", "Erro ao excluir série: " + e.getMessage());
            }
        }

        try {
            usuarioDAO.garantirEstruturaBanco();
            List<Serie> series = controller.listar();
            List<Usuario> usuarios = usuarioDAO.listar();
            request.setAttribute("series", series);
            request.setAttribute("usuarios", usuarios);
        } catch (SQLException e) {
            request.setAttribute("series", List.of());
            request.setAttribute("usuarios", List.of());
            request.setAttribute("erroListagem", "Não foi possível carregar os dados do banco: " + e.getMessage());
        }

        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    // -------------------------------------------------------------------------
    // POST: executa CADASTRAR, ATUALIZAR ou EXCLUIR no banco de dados (apenas Admin)
    // -------------------------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!verificarAdmin(request, response)) {
            return;
        }

        String acao = request.getParameter("acao");
        String origem = request.getParameter("origem");
        String baseRedirect = "home".equalsIgnoreCase(origem)
                ? (request.getContextPath() + "/home")
                : (request.getContextPath() + "/controller");

        try {
            if ("cadastrar".equalsIgnoreCase(acao)) {
                Serie serie = buildSerieFromRequest(request, false);
                controller.cadastrar(serie);
                response.sendRedirect(baseRedirect + "?sucesso=1");

            } else if ("atualizar".equalsIgnoreCase(acao)) {
                Serie serie = buildSerieFromRequest(request, true);
                controller.atualizar(serie);
                response.sendRedirect(baseRedirect + "?atualizado=1");

            } else if ("excluir".equalsIgnoreCase(acao)) {
                int id = Integer.parseInt(request.getParameter("id"));
                controller.excluir(id);
                response.sendRedirect(baseRedirect + "?excluido=1");

            } else {
                response.sendRedirect(baseRedirect);
            }

        } catch (IllegalArgumentException e) {
            request.setAttribute("erroFormulario", e.getMessage());
            doGet(request, response);

        } catch (SQLException e) {
            request.setAttribute("erroFormulario", "Erro ao salvar no banco: " + e.getMessage());
            doGet(request, response);
        }
    }

    // -------------------------------------------------------------------------
    // Monta o objeto Serie a partir dos parâmetros do formulário HTML
    // -------------------------------------------------------------------------
    private Serie buildSerieFromRequest(HttpServletRequest request, boolean incluirId) {
        Serie serie = new Serie();

        if (incluirId) {
            String idStr = request.getParameter("id");
            try {
                serie.setId(Integer.parseInt(idStr));
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("ID da série inválido para atualização.");
            }
        }

        serie.setTitulo(request.getParameter("titulo"));
        serie.setGenero(request.getParameter("genero"));
        serie.setDescricao(request.getParameter("descricao"));
        serie.setAutor(request.getParameter("autor"));
        serie.setSrcImagem(request.getParameter("srcImagem"));

        String anoStr  = request.getParameter("anoLancamento");
        String notaStr = request.getParameter("nota");

        try {
            serie.setAnoLancamento(Integer.parseInt(anoStr));
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Ano de lançamento inválido: \"" + anoStr + "\"");
        }

        try {
            serie.setNota(Double.parseDouble(notaStr.replace(",", ".")));
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Nota inválida: \"" + notaStr + "\"");
        }

        return serie;
    }
}
