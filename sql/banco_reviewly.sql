-- ============================================================================
-- SCRIPT SQL DO PROJETO REVIEWLY (PostgreSQL — Database: reviewfyBD)
-- Nota: O próprio sistema Java (UsuarioDAO.garantirEstruturaBanco) já cria
-- automaticamente estas tabelas e o usuário Admin padrão ao iniciar!
-- ============================================================================

CREATE TABLE IF NOT EXISTS serie (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    genero VARCHAR(120) NOT NULL,
    ano_lancamento INT NOT NULL,
    nota NUMERIC(4,2) NOT NULL,
    src_imagem TEXT,
    descricao TEXT,
    autor VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS usuario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    senha VARCHAR(120) NOT NULL,
    perfil VARCHAR(20) NOT NULL DEFAULT 'USER' -- 'USER' ou 'ADMIN'
);

-- Insere o Administrador padrão caso ainda não exista
INSERT INTO usuario (nome, email, senha, perfil)
VALUES ('Administrador Reviewly', 'admin@reviewly.com', 'admin123', 'ADMIN')
ON CONFLICT (email) DO NOTHING;

