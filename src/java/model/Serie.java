package model;

public class Serie {
    
    // 1. Atributos (Estado do objeto)
    private int id;
    private String titulo;
    private String genero;
    private int anoLancamento;
    private double nota;

    // 2. Construtor Vazio
    public Serie() {
    }

    // 3. Construtor com Parâmetros
    public Serie(int id, String titulo, String genero, int anoLancamento, double nota) {
        this.id = id;
        this.titulo = titulo;
        this.genero = genero;
        this.anoLancamento = anoLancamento;
        this.nota = nota;
    }

    // 4. Métodos Getters e Setters (Comportamento de acesso)
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getGenero() {
        return genero;
    }

    public void setGenero(String genero) {
        this.genero = genero;
    }

    public int getAnoLancamento() {
        return anoLancamento;
    }

    public void setAnoLancamento(int anoLancamento) {
        this.anoLancamento = anoLancamento;
    }

    public double getNota() {
        return nota;
    }

    public void setNota(double nota) {
        this.nota = nota;
    }
}