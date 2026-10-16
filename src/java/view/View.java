package view;

import controller.Controller;
import model.Serie;

import java.sql.SQLException;
import java.util.List;
import java.util.Scanner;

public class View {

    private final Controller controller;
    private final Scanner scanner;

    public View() {
        this.controller = new Controller();
        this.scanner = new Scanner(System.in);
    }

    public static void main(String[] args) {
        View view = new View();
        view.iniciar();
    }

    public void iniciar() {
        int opcao = -1;
        do {
            exibirMenu();
            opcao = lerInteiro("Escolha uma opção: ");
            System.out.println();

            switch (opcao) {
                case 1:
                    cadastrarSerie();
                    break;
                case 2:
                    listarSeries();
                    break;
                case 3:
                    buscarSeriePorId();
                    break;
                case 4:
                    atualizarSerie();
                    break;
                case 5:
                    excluirSerie();
                    break;
                case 0:
                    System.out.println("Encerrando o Reviewly... Até logo!");
                    break;
                default:
                    System.out.println("Opção inválida! Escolha uma opção entre 0 e 5.");
                    break;
            }
            System.out.println();
        } while (opcao != 0);
    }

    private void exibirMenu() {
        System.out.println("=========================================");
        System.out.println("        REVIEWLY - CATÁLOGO DE SÉRIES    ");
        System.out.println("=========================================");
        System.out.println("1. Cadastrar nova série");
        System.out.println("2. Listar todas as séries");
        System.out.println("3. Buscar série por ID");
        System.out.println("4. Atualizar série");
        System.out.println("5. Excluir série");
        System.out.println("0. Sair");
        System.out.println("=========================================");
    }

    // 1. Cadastrar Série
    private void cadastrarSerie() {
        System.out.println("--- CADASTRO DE NOVA SÉRIE ---");
        String titulo = lerTextoObrigatorio("Título: ");
        String genero = lerTexto("Gênero: ");
        int anoLancamento = lerInteiro("Ano de Lançamento: ");
        double nota = lerNota("Nota (0.0 a 10.0): ");
        String srcImagem = lerTexto("URL / Caminho da Imagem: ");
        String descricao = lerTexto("Descrição / Sinopse: ");
        String autor = lerTexto("Autor da avaliação: ");

        Serie novaSerie = new Serie(0, titulo, genero, anoLancamento, nota, srcImagem, descricao, autor);

        try {
            controller.cadastrar(novaSerie);
            System.out.println(">>> Série cadastrada com sucesso!");
        } catch (IllegalArgumentException e) {
            System.out.println("Aviso: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("Erro ao cadastrar série no banco de dados: " + e.getMessage());
        }
    }

    // 2. Listar Séries
    private void listarSeries() {
        System.out.println("--- LISTA DE SÉRIES ---");
        try {
            List<Serie> series = controller.listar();
            if (series == null || series.isEmpty()) {
                System.out.println("Nenhuma série cadastrada até o momento.");
                return;
            }

            for (Serie s : series) {
                exibirDetalhesSerie(s);
                System.out.println("-----------------------------------------");
            }
        } catch (SQLException e) {
            System.err.println("Erro ao listar séries: " + e.getMessage());
        }
    }

    // 3. Buscar Série por ID
    private void buscarSeriePorId() {
        System.out.println("--- BUSCA DE SÉRIE POR ID ---");
        int id = lerInteiro("Informe o ID da série: ");

        try {
            Serie serie = controller.buscarPorId(id);
            if (serie != null) {
                System.out.println("Série encontrada:");
                exibirDetalhesSerie(serie);
            } else {
                System.out.println("Nenhuma série encontrada com o ID: " + id);
            }
        } catch (IllegalArgumentException e) {
            System.out.println("Aviso: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("Erro ao buscar série por ID: " + e.getMessage());
        }
    }

    // 4. Atualizar Série
    private void atualizarSerie() {
        System.out.println("--- ATUALIZAR SÉRIE ---");
        int id = lerInteiro("Informe o ID da série que deseja atualizar: ");

        try {
            Serie serie = controller.buscarPorId(id);
            if (serie == null) {
                System.out.println("Nenhuma série encontrada com o ID: " + id);
                return;
            }

            System.out.println("Série atual selecionada: " + serie.getTitulo());
            System.out.println("(Pressione ENTER diretamente para manter o valor atual)");

            String novoTitulo = lerTextoOpcional("Novo título [" + serie.getTitulo() + "]: ", serie.getTitulo());
            String novoGenero = lerTextoOpcional("Novo gênero [" + serie.getGenero() + "]: ", serie.getGenero());
            int novoAno = lerInteiroOpcional("Novo ano de lançamento [" + serie.getAnoLancamento() + "]: ", serie.getAnoLancamento());
            double novaNota = lerNotaOpcional("Nova nota [" + serie.getNota() + "]: ", serie.getNota());
            String novaImagem = lerTextoOpcional("Nova imagem [" + serie.getSrcImagem() + "]: ", serie.getSrcImagem());
            String novaDescricao = lerTextoOpcional("Nova descrição [" + serie.getDescricao() + "]: ", serie.getDescricao());
            String novoAutor = lerTextoOpcional("Novo autor [" + serie.getAutor() + "]: ", serie.getAutor());

            serie.setTitulo(novoTitulo);
            serie.setGenero(novoGenero);
            serie.setAnoLancamento(novoAno);
            serie.setNota(novaNota);
            serie.setSrcImagem(novaImagem);
            serie.setDescricao(novaDescricao);
            serie.setAutor(novoAutor);

            controller.atualizar(serie);
            System.out.println(">>> Série atualizada com sucesso!");
        } catch (IllegalArgumentException e) {
            System.out.println("Aviso: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("Erro ao atualizar série: " + e.getMessage());
        }
    }

    // 5. Excluir Série
    private void excluirSerie() {
        System.out.println("--- EXCLUSÃO DE SÉRIE ---");
        int id = lerInteiro("Informe o ID da série que deseja excluir: ");

        try {
            Serie serie = controller.buscarPorId(id);
            if (serie == null) {
                System.out.println("Nenhuma série encontrada com o ID: " + id);
                return;
            }

            System.out.print("Tem certeza que deseja excluir \"" + serie.getTitulo() + "\" (ID: " + id + ")? (S/N): ");
            String confirmacao = scanner.nextLine().trim();

            if (confirmacao.equalsIgnoreCase("S")) {
                controller.excluir(id);
                System.out.println(">>> Série excluída com sucesso!");
            } else {
                System.out.println("Operação de exclusão cancelada.");
            }
        } catch (IllegalArgumentException e) {
            System.out.println("Aviso: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("Erro ao excluir série: " + e.getMessage());
        }
    }

    // Exibição formatada dos dados da série
    private void exibirDetalhesSerie(Serie serie) {
        System.out.println("ID: " + serie.getId());
        System.out.println("Título: " + serie.getTitulo());
        System.out.println("Gênero: " + serie.getGenero());
        System.out.println("Ano de Lançamento: " + serie.getAnoLancamento());
        System.out.println("Nota: " + serie.getNota() + " / 10.0");
        System.out.println("Autor: " + serie.getAutor());
        System.out.println("Imagem: " + serie.getSrcImagem());
        System.out.println("Descrição: " + serie.getDescricao());
    }

    // Métodos utilitários de leitura segura via teclado
    private String lerTexto(String rotulo) {
        System.out.print(rotulo);
        return scanner.nextLine().trim();
    }

    private String lerTextoObrigatorio(String rotulo) {
        while (true) {
            System.out.print(rotulo);
            String valor = scanner.nextLine().trim();
            if (!valor.isEmpty()) {
                return valor;
            }
            System.out.println("Campo obrigatório! Por favor, informe um valor.");
        }
    }

    private String lerTextoOpcional(String rotulo, String valorPadrao) {
        System.out.print(rotulo);
        String entrada = scanner.nextLine().trim();
        return entrada.isEmpty() ? valorPadrao : entrada;
    }

    private int lerInteiro(String rotulo) {
        while (true) {
            System.out.print(rotulo);
            String entrada = scanner.nextLine().trim();
            try {
                return Integer.parseInt(entrada);
            } catch (NumberFormatException e) {
                System.out.println("Entrada inválida! Digite um número inteiro válido.");
            }
        }
    }

    private int lerInteiroOpcional(String rotulo, int valorPadrao) {
        while (true) {
            System.out.print(rotulo);
            String entrada = scanner.nextLine().trim();
            if (entrada.isEmpty()) {
                return valorPadrao;
            }
            try {
                return Integer.parseInt(entrada);
            } catch (NumberFormatException e) {
                System.out.println("Entrada inválida! Digite um número inteiro válido.");
            }
        }
    }

    private double lerNota(String rotulo) {
        while (true) {
            System.out.print(rotulo);
            String entrada = scanner.nextLine().trim().replace(',', '.');
            try {
                double nota = Double.parseDouble(entrada);
                if (nota >= 0.0 && nota <= 10.0) {
                    return nota;
                }
                System.out.println("A nota deve estar entre 0.0 e 10.0.");
            } catch (NumberFormatException e) {
                System.out.println("Entrada inválida! Digite uma nota numérica (ex: 8.5).");
            }
        }
    }

    private double lerNotaOpcional(String rotulo, double valorPadrao) {
        while (true) {
            System.out.print(rotulo);
            String entrada = scanner.nextLine().trim().replace(',', '.');
            if (entrada.isEmpty()) {
                return valorPadrao;
            }
            try {
                double nota = Double.parseDouble(entrada);
                if (nota >= 0.0 && nota <= 10.0) {
                    return nota;
                }
                System.out.println("A nota deve estar entre 0.0 e 10.0.");
            } catch (NumberFormatException e) {
                System.out.println("Entrada inválida! Digite uma nota numérica (ex: 8.5).");
            }
        }
    }
}
