<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reviewly — Entrar ou Criar Conta</title>

  <!-- Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Montserrat:wght@400;500;600;700;800&display=swap" rel="stylesheet">

  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

  <!-- Folha de Estilos Externa -->
  <link rel="stylesheet" href="css/style.css">
</head>
<body class="auth-page-body">

  <!-- Alerta de segurança se tentou acessar área restrita de Admin -->
  <c:if test="${param.restrito == '1'}">
    <div class="reviewly-toast reviewly-toast--error" role="alert">
      <i class="bi bi-shield-lock-fill"></i>
      <span>Acesso restrito! Faça login com uma conta de Administrador para acessar o Painel CRUD.</span>
    </div>
  </c:if>

  <c:if test="${not empty erroAuth}">
    <div class="reviewly-toast reviewly-toast--error" role="alert">
      <i class="bi bi-exclamation-triangle-fill"></i>
      <span>${fn:escapeXml(erroAuth)}</span>
    </div>
  </c:if>

  <!-- Fundo Cinematográfico Estilo Netflix Login -->
  <div class="auth-backdrop"></div>

  <!-- Header Minimalista -->
  <header class="auth-header">
    <a href="${pageContext.request.contextPath}/home" class="netflix-logo">REVIEWLY</a>
    <a href="${pageContext.request.contextPath}/home" class="btn-pill-gray" style="text-decoration: none; font-size: 0.85rem; padding: 0.5rem 1.1rem;">
      <i class="bi bi-arrow-left"></i> Voltar ao Catálogo
    </a>
  </header>

  <!-- Container Central de Login / Cadastro -->
  <main class="auth-main-wrapper">
    <div class="auth-card">

      <!-- Abas: Entrar vs Cadastrar -->
      <div class="auth-tabs">
        <button type="button" id="tab-btn-login"
                class="auth-tab-btn ${abaAtiva == 'cadastro' ? '' : 'active'}"
                onclick="switchAuthTab('login')">
          <i class="bi bi-box-arrow-in-right"></i> Entrar
        </button>
        <button type="button" id="tab-btn-register"
                class="auth-tab-btn ${abaAtiva == 'cadastro' ? 'active' : ''}"
                onclick="switchAuthTab('cadastro')">
          <i class="bi bi-person-plus-fill"></i> Criar Conta
        </button>
      </div>

      <!-- =====================================================================
           ABA 1: FORMULÁRIO DE LOGIN
           ===================================================================== -->
      <div id="auth-panel-login" class="auth-panel ${abaAtiva == 'cadastro' ? 'hidden' : ''}">
        <h1 class="auth-title">Entrar</h1>
        <p class="auth-subtitle">Acesse sua conta ou entre como Administrador para gerenciar o catálogo.</p>

        <form method="POST" action="${pageContext.request.contextPath}/auth" class="auth-form">
          <input type="hidden" name="acao" value="login">
          <input type="hidden" name="destino" value="${param.restrito == '1' ? 'admin' : ''}">

          <div class="netflix-form-group">
            <label for="login-email" class="netflix-label">E-mail</label>
            <input type="email" id="login-email" name="email" class="netflix-input"
                   placeholder="Ex: admin@reviewly.com" required>
          </div>

          <div class="netflix-form-group">
            <label for="login-senha" class="netflix-label">Senha</label>
            <input type="password" id="login-senha" name="senha" class="netflix-input"
                   placeholder="Digite sua senha" required>
          </div>

          <button type="submit" class="btn-netflix-submit auth-submit-btn">
            <i class="bi bi-box-arrow-in-right"></i> Entrar na Plataforma
          </button>
        </form>

        <!-- Credencial padrão do Admin pré-configurada no banco -->
        <div class="auth-admin-hint">
          <div class="hint-header">
            <i class="bi bi-key-fill"></i>
            <span>Acesso Rápido de Administrador (Padrão do Banco)</span>
          </div>
          <p>E-mail: <code>admin@reviewly.com</code> | Senha: <code>admin123</code></p>
          <button type="button" class="btn-fill-admin" onclick="preencherAdminPadrao()">
            <i class="bi bi-magic"></i> Preencher Login Admin Automaticamente
          </button>
        </div>
      </div>

      <!-- =====================================================================
           ABA 2: FORMULÁRIO DE CADASTRO (Tabela 'usuario' no PostgreSQL)
           ===================================================================== -->
      <div id="auth-panel-register" class="auth-panel ${abaAtiva == 'cadastro' ? '' : 'hidden'}">
        <h1 class="auth-title">Criar Nova Conta</h1>
        <p class="auth-subtitle">Os dados serão salvos na tabela <code>usuario</code> do PostgreSQL.</p>

        <form method="POST" action="${pageContext.request.contextPath}/auth" class="auth-form">
          <input type="hidden" name="acao" value="registrar">

          <div class="netflix-form-group">
            <label for="reg-nome" class="netflix-label">Nome Completo *</label>
            <input type="text" id="reg-nome" name="nome" class="netflix-input"
                   placeholder="Seu nome ou apelido" required>
          </div>

          <div class="netflix-form-group">
            <label for="reg-email" class="netflix-label">E-mail *</label>
            <input type="email" id="reg-email" name="email" class="netflix-input"
                   placeholder="seuemail@exemplo.com" required>
          </div>

          <div class="netflix-form-group">
            <label for="reg-senha" class="netflix-label">Senha *</label>
            <input type="password" id="reg-senha" name="senha" class="netflix-input"
                   placeholder="Crie uma senha segura" minlength="4" required>
          </div>

          <div class="netflix-form-group">
            <label for="reg-perfil" class="netflix-label">Tipo de Conta (Perfil no Sistema) *</label>
            <select id="reg-perfil" name="perfil" class="netflix-input">
              <option value="USER">Usuário / Espectador (Visualiza o Catálogo)</option>
              <option value="ADMIN">Administrador (Acesso ao Painel CRUD + Opções Extras)</option>
            </select>
          </div>

          <button type="submit" class="btn-netflix-submit auth-submit-btn">
            <i class="bi bi-person-check-fill"></i> Cadastrar no Banco de Dados
          </button>
        </form>
      </div>

    </div>
  </main>

  <script>
    function switchAuthTab(aba) {
      const loginPanel = document.getElementById('auth-panel-login');
      const regPanel = document.getElementById('auth-panel-register');
      const loginBtn = document.getElementById('tab-btn-login');
      const regBtn = document.getElementById('tab-btn-register');

      if (aba === 'cadastro') {
        loginPanel.classList.add('hidden');
        regPanel.classList.remove('hidden');
        loginBtn.classList.remove('active');
        regBtn.classList.add('active');
      } else {
        regPanel.classList.add('hidden');
        loginPanel.classList.remove('hidden');
        regBtn.classList.remove('active');
        loginBtn.classList.add('active');
      }
    }

    function preencherAdminPadrao() {
      document.getElementById('login-email').value = 'admin@reviewly.com';
      document.getElementById('login-senha').value = 'admin123';
    }
  </script>
  <script src="js/script.js" defer></script>
</body>
</html>

