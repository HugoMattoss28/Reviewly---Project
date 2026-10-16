package controller;

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
 * Servlet principal do Reviewly.
 *
 * Mapeamento: /controller
 *
 * GET  /controller          → Lista todas as séries do banco e encaminha para index.jsp
 * POST /controller (acao=cadastrar) → Lê os campos do formulário, constrói o
 *                                      objeto Serie, persiste via Controller e
 *                                      redireciona de volta para GET /controller
 */
@WebServlet(name = "SerieServlet", urlPatterns = {"/controller"})
public class SerieServlet extends HttpServlet {

    private final Controller controller = new Controller();

    // -------------------------------------------------------------------------
    // GET: carrega a lista de séries e encaminha ao index.jsp
    // -------------------------------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            List<Serie> series = controller.listar();
            request.setAttribute("series", series);
        } catch (SQLException e) {
            // Em caso de erro de BD, injeta lista vazia e registra o erro no log do servidor
            request.setAttribute("series", List.of());
            request.setAttribute("erroListagem", "Não foi possível carregar as séries: " + e.getMessage());
        }

        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    // -------------------------------------------------------------------------
    // POST: processa o formulário de cadastro e redireciona para GET
    // -------------------------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String acao = request.getParameter("acao");

        if ("cadastrar".equals(acao)) {
            try {
                Serie serie = buildSerieFromRequest(request);
                controller.cadastrar(serie);
                // Redireciona para GET /controller (padrão PRG: Post/Redirect/Get)
                response.sendRedirect(request.getContextPath() + "/controller?sucesso=1");

            } catch (IllegalArgumentException e) {
                // Validação de regra de negócio: devolve ao JSP com mensagem de erro
                request.setAttribute("erroFormulario", e.getMessage());
                doGet(request, response);

            } catch (SQLException e) {
                request.setAttribute("erroFormulario", "Erro ao salvar no banco: " + e.getMessage());
                doGet(request, response);
            }
        } else {
            // Ação não reconhecida: redireciona para a página principal
            response.sendRedirect(request.getContextPath() + "/controller");
        }
    }

    // -------------------------------------------------------------------------
    // Monta o objeto Serie a partir dos parâmetros do formulário HTML
    // -------------------------------------------------------------------------
    private Serie buildSerieFromRequest(HttpServletRequest request) {
        Serie serie = new Serie();

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
            serie.setNota(Double.parseDouble(notaStr));
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Nota inválida: \"" + notaStr + "\"");
        }

        return serie;
    }
}
