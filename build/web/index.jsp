<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%-- Proteção de acesso: apenas ADMIN logado pode acessar index.jsp --%>
<c:if test="${empty sessionScope.usuarioLogado or not sessionScope.usuarioLogado.admin}">
  <c:redirect url="/auth?restrito=1"/>
</c:if>
<c:if test="${series == null}">
  <c:redirect url="/controller"/>
</c:if>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Reviewly - Painel do Administrador (CRUD de Séries e Banco de Dados).">
  <meta name="theme-color" content="#141414">
  <title>Reviewly — Painel do Administrador (CRUD)</title>

  <!-- Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Montserrat:wght@400;500;600;700;800&display=swap" rel="stylesheet">

  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

  <!-- Folha de Estilos Externa -->
  <link rel="stylesheet" href="css/style.css">
</head>
<body>

  <%-- Toasts de Feedback de CRUD --%>
  <c:if test="${not empty erroFormulario}">
    <div class="reviewly-toast reviewly-toast--error" role="alert">
      <i class="bi bi-exclamation-triangle-fill"></i>
      <span>${fn:escapeXml(erroFormulario)}</span>
    </div>
  </c:if>
  <c:if test="${not empty erroListagem}">
    <div class="reviewly-toast reviewly-toast--error" role="alert">
      <i class="bi bi-database-fill-exclamation"></i>
      <span>${fn:escapeXml(erroListagem)}</span>
    </div>
  </c:if>
  <c:if test="${param.sucesso == '1'}">
    <div class="reviewly-toast reviewly-toast--success" role="alert">
      <i class="bi bi-check-circle-fill"></i>
      <span>Série cadastrada com sucesso no PostgreSQL!</span>
    </div>
  </c:if>
  <c:if test="${param.atualizado == '1'}">
    <div class="reviewly-toast reviewly-toast--success" role="alert">
      <i class="bi bi-pencil-square"></i>
      <span>Série atualizada com sucesso no banco de dados!</span>
    </div>
  </c:if>
  <c:if test="${param.excluido == '1'}">
    <div class="reviewly-toast reviewly-toast--error" role="alert">
      <i class="bi bi-trash3-fill"></i>
      <span>Série excluída do banco de dados com sucesso!</span>
    </div>
  </c:if>

  <!-- =========================================================================
       1. Alerta de Segurança Oficial: Cuidado com o site falso "Metflix"
       ========================================================================= -->
  <aside id="metflix-security-alert" class="security-alert-bar" role="alert" aria-live="assertive">
    <div class="security-alert-content">
      <i class="bi bi-shield-exclamation security-icon" aria-hidden="true"></i>
      <span class="security-text">
        <strong>ALERTA DE SEGURANÇA OFICIAL:</strong> Cuidado com clones e sites falsos! O único domínio oficial é o <strong>Reviewly</strong>. Fique atento e <u>NÃO insira seus dados</u> no site falso <span class="fake-name">Metflix</span>.
      </span>
    </div>
    <div class="security-alert-actions">
      <button id="ack-alert-btn" class="btn-alert-ack">Entendido</button>
      <button id="close-alert-btn" class="btn-alert-close" aria-label="Fechar alerta de segurança">
        <i class="bi bi-x-lg"></i>
      </button>
    </div>
  </aside>

  <!-- =========================================================================
       2. Barra de Navegação do Painel do Administrador
       ========================================================================= -->
  <header class="netflix-header" role="banner">
    <div class="header-left">
      <a href="${pageContext.request.contextPath}/controller" class="netflix-logo" aria-label="Reviewly Admin">REVIEWLY</a>
      <span class="badge-admin-header"><i class="bi bi-shield-lock-fill"></i> PAINEL ADMIN</span>
      <nav class="header-nav" role="navigation" aria-label="Menu do Administrador">
        <a href="#secao-crud" class="nav-item-pill">Gerenciar CRUD</a>
        <a href="#secao-usuarios" class="nav-item-link">Usuários no BD</a>
        <a href="#rows-section" class="nav-item-link">Prévia das Fileiras</a>
        <a href="${pageContext.request.contextPath}/home" class="nav-item-link nav-user-view-link">
          <i class="bi bi-eye-fill"></i> Ver Tela do Usuário
        </a>
      </nav>
    </div>

    <div class="header-right">
      <!-- Busca rápida no CRUD -->
      <div class="netflix-search-box">
        <button class="search-toggle-btn" aria-label="Buscar séries">
          <i class="bi bi-search"></i>
        </button>
        <i class="bi bi-search search-input-icon" aria-hidden="true"></i>
        <input type="text" id="catalog-search-input" class="netflix-search-input" placeholder="Filtrar séries no CRUD..." aria-label="Campo de busca">
      </div>

      <!-- Sino de Notificações -->
      <div class="notification-btn-wrap">
        <button id="notification-bell-btn" class="search-toggle-btn" title="Reabrir Alerta de Segurança" aria-label="Notificações">
          <i class="bi bi-bell"></i>
          <span class="bell-badge-count">1</span>
        </button>
      </div>

      <!-- Botão Cadastrar Nova Série -->
      <button type="button" class="btn-netflix-add" onclick="openCreateModal()">
        <i class="bi bi-plus-lg"></i>
        <span>Cadastrar Série</span>
      </button>

      <!-- Admin Logado + Logout -->
      <div class="user-logged-pill">
        <div class="avatar-square avatar-admin">
          ${fn:substring(sessionScope.usuarioLogado.nome, 0, 2)}
        </div>
        <div class="user-logged-info">
          <span class="user-logged-name">${fn:escapeXml(sessionScope.usuarioLogado.nome)}</span>
          <span class="user-logged-role role-admin">ADMIN</span>
        </div>
        <a href="${pageContext.request.contextPath}/auth?acao=logout" class="btn-logout-icon" title="Sair do Painel Admin">
          <i class="bi bi-box-arrow-right"></i>
        </a>
      </div>
    </div>
  </header>

  <main role="main">
    <!-- =========================================================================
         3. Painel Principal de Administração (CRUD Completo no PostgreSQL)
         ========================================================================= -->
    <section id="secao-crud" class="admin-dashboard-section">
      <div class="admin-dashboard-header">
        <div>
          <span class="admin-kicker"><i class="bi bi-database-fill-gear"></i> CONECTADO AO POSTGRESQL (reviewfyBD)</span>
          <h1 class="admin-main-title">CENTRAL DE CONTROLE &amp; CRUD DE SÉRIES</h1>
          <p class="admin-subtitle">Cadastre, consulte, atualize e exclua séries em tempo real. Todas as alterações refletem imediatamente na Tela Inicial do Usuário.</p>
        </div>
        <div class="admin-header-buttons">
          <a href="${pageContext.request.contextPath}/home" class="btn-pill-gray" style="text-decoration: none;">
            <i class="bi bi-box-arrow-up-right"></i> Ir para Tela do Usuário
          </a>
          <button type="button" class="btn-pill-white" onclick="openCreateModal()">
            <i class="bi bi-plus-circle-fill"></i> Nova Série
          </button>
        </div>
      </div>

      <!-- Métricas do Banco -->
      <div class="admin-stats-grid">
        <div class="admin-stat-card">
          <div class="stat-icon red"><i class="bi bi-film"></i></div>
          <div>
            <span class="stat-value">${fn:length(series)}</span>
            <span class="stat-label">Séries Cadastradas</span>
          </div>
        </div>
        <div class="admin-stat-card">
          <div class="stat-icon gold"><i class="bi bi-people-fill"></i></div>
          <div>
            <span class="stat-value">${fn:length(usuarios)}</span>
            <span class="stat-label">Contas na Tabela Usuario</span>
          </div>
        </div>
        <div class="admin-stat-card">
          <div class="stat-icon green"><i class="bi bi-shield-check"></i></div>
          <div>
            <span class="stat-value">ATIVO</span>
            <span class="stat-label">Status JDBC PostgreSQL</span>
          </div>
        </div>
      </div>

      <!-- Tabela CRUD de Séries -->
      <div class="admin-crud-card">
        <div class="admin-crud-card-header">
          <h2><i class="bi bi-table"></i> Registros da Tabela <code>serie</code></h2>
          <button type="button" class="btn-netflix-add" onclick="openCreateModal()">
            <i class="bi bi-plus-lg"></i> Adicionar Registro
          </button>
        </div>

        <c:choose>
          <c:when test="${not empty series}">
            <div class="admin-table-responsive">
              <table class="admin-crud-table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Capa</th>
                    <th>Título</th>
                    <th>Gênero</th>
                    <th>Ano</th>
                    <th>Nota</th>
                    <th>Autor</th>
                    <th style="text-align: right;">Ações CRUD</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="s" items="${series}">
                    <tr class="crud-row-item" data-title="${fn:escapeXml(s.titulo)}" data-genre="${fn:escapeXml(s.genero)}">
                      <td class="td-id">#${s.id}</td>
                      <td>
                        <div class="td-thumb">
                          <c:choose>
                            <c:when test="${not empty s.srcImagem}">
                              <img src="${fn:escapeXml(s.srcImagem)}" alt="${fn:escapeXml(s.titulo)}">
                            </c:when>
                            <c:otherwise>
                              <i class="bi bi-film"></i>
                            </c:otherwise>
                          </c:choose>
                        </div>
                      </td>
                      <td class="td-title">${fn:escapeXml(s.titulo)}</td>
                      <td><span class="td-badge-genre">${fn:escapeXml(s.genero)}</span></td>
                      <td>${s.anoLancamento}</td>
                      <td>
                        <span class="td-nota"><i class="bi bi-star-fill"></i> ${s.nota}</span>
                      </td>
                      <td>${fn:escapeXml(s.autor)}</td>
                      <td class="td-actions">
                        <button type="button" class="btn-crud-action view" title="Ver Detalhes" onclick="openDetailModal(${s.id})">
                          <i class="bi bi-eye-fill"></i> Ver
                        </button>
                        <button type="button" class="btn-crud-action edit" title="Editar Série" onclick="openEditModal(${s.id})">
                          <i class="bi bi-pencil-square"></i> Editar
                        </button>
                        <a href="${pageContext.request.contextPath}/controller?acao=excluir&id=${s.id}"
                           class="btn-crud-action delete"
                           onclick="return confirm('Confirma a exclusão permanente da série #${s.id} (${fn:escapeXml(s.titulo)}) do banco de dados?');">
                          <i class="bi bi-trash3-fill"></i> Excluir
                        </a>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
          </c:when>
          <c:otherwise>
            <div class="netflix-empty-state" style="margin: 1.5rem 0;">
              <i class="bi bi-inbox empty-icon"></i>
              <p class="empty-text">Nenhuma série cadastrada na tabela <code>serie</code> ainda. Clique abaixo para cadastrar a primeira!</p>
              <button type="button" class="btn-netflix-add" onclick="openCreateModal()">
                <i class="bi bi-plus-lg"></i> Cadastrar Primeira Série
              </button>
            </div>
          </c:otherwise>
        </c:choose>
      </div>

      <!-- Tabela de Usuários Cadastrados no Banco -->
      <div id="secao-usuarios" class="admin-crud-card" style="margin-top: 2rem;">
        <div class="admin-crud-card-header">
          <h2><i class="bi bi-people-fill"></i> Contas Registradas na Tabela <code>usuario</code></h2>
          <a href="${pageContext.request.contextPath}/auth" class="btn-pill-gray" style="text-decoration: none; font-size: 0.8rem; padding: 0.45rem 0.9rem;">
            <i class="bi bi-person-plus-fill"></i> Cadastrar Novo Usuário/Admin
          </a>
        </div>
        <div class="admin-table-responsive">
          <table class="admin-crud-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Nome</th>
                <th>E-mail</th>
                <th>Perfil de Acesso</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="u" items="${usuarios}">
                <tr>
                  <td class="td-id">#${u.id}</td>
                  <td class="td-title">${fn:escapeXml(u.nome)}</td>
                  <td>${fn:escapeXml(u.email)}</td>
                  <td>
                    <span class="user-logged-role ${u.admin ? 'role-admin' : 'role-user'}">
                      ${u.admin ? 'ADMINISTRADOR' : 'USUÁRIO'}
                    </span>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </div>
    </section>

    <!-- =========================================================================
         4. Prévia das Fileiras do Catálogo no Painel Admin
         ========================================================================= -->
    <div id="rows-section" class="netflix-content-body">
      <section id="row-policiais" class="netflix-row" aria-labelledby="heading-policiais">
        <h2 id="heading-policiais" class="row-title">Prévia: Catálogo Geral (${fn:length(series)} séries)</h2>
        <div class="row-cards-container">
          <c:forEach var="s" items="${series}">
            <article class="netflix-card" data-id="${s.id}" data-title="${fn:escapeXml(s.titulo)}" data-genre="${fn:escapeXml(s.genero)}" onclick="openDetailModal(${s.id})">
              <div class="card-thumb">
                <c:choose>
                  <c:when test="${not empty s.srcImagem}">
                    <img src="${fn:escapeXml(s.srcImagem)}" alt="${fn:escapeXml(s.titulo)}" loading="lazy">
                  </c:when>
                  <c:otherwise>
                    <div class="card-thumb-placeholder"><i class="bi bi-film"></i></div>
                  </c:otherwise>
                </c:choose>
                <div class="card-hover-info">
                  <p class="card-hover-title">${fn:escapeXml(s.titulo)}</p>
                  <div class="card-hover-meta">
                    <span class="card-hover-nota"><i class="bi bi-star-fill"></i> ${s.nota}</span>
                    <span class="card-hover-year">${s.anoLancamento}</span>
                  </div>
                </div>
                <div class="card-admin-quick-actions">
                  <button type="button" class="btn-card-admin edit" title="Editar série" onclick="event.stopPropagation(); openEditModal(${s.id});">
                    <i class="bi bi-pencil-fill"></i>
                  </button>
                  <a href="${pageContext.request.contextPath}/controller?acao=excluir&id=${s.id}"
                     class="btn-card-admin delete" title="Excluir série"
                     onclick="event.stopPropagation(); return confirm('Deseja excluir esta série?');">
                    <i class="bi bi-trash3-fill"></i>
                  </a>
                </div>
              </div>
              <div class="card-below-caption">
                <p class="card-below-title">${fn:escapeXml(s.titulo)}</p>
              </div>
            </article>
          </c:forEach>
          <c:if test="${empty series}">
            <div class="netflix-empty-state">
              <i class="bi bi-film empty-icon" aria-hidden="true"></i>
              <p class="empty-text">Nenhuma série cadastrada no banco de dados.</p>
            </div>
          </c:if>
        </div>
      </section>
    </div>
  </main>

  <!-- =========================================================================
       5. Modal Estilo Netflix: "Mais Informações"
       ========================================================================= -->
  <div id="netflix-detail-modal" class="netflix-modal-overlay" role="dialog" aria-modal="true" aria-labelledby="modal-title-text">
    <div class="netflix-modal-container">
      <button class="modal-close-btn" onclick="closeDetailModal()" aria-label="Fechar janela">
        <i class="bi bi-x-lg"></i>
      </button>

      <div class="modal-hero-cover">
        <img id="modal-cover-img" src="" alt="Capa da série">
        <div class="modal-hero-vignette"></div>
        <div class="modal-title-overlay">
          <h2 id="modal-title-text">—</h2>
        </div>
      </div>

      <div class="modal-body-content">
        <div>
          <div class="billboard-meta-line" style="margin-bottom: 1rem; color: #aaa;">
            <span id="modal-ano">—</span>
            <span class="badge-age-netflix">A16</span>
            <span style="color: #ffbe0b; font-weight: 700;">
              <i class="bi bi-star-fill"></i> <span id="modal-nota">—</span>
            </span>
            <span class="hd-badge" style="border: 1px solid #555; padding: 2px 4px; border-radius: 2px; font-size: 0.7rem;">HD</span>
          </div>
          <p id="modal-synopsis-text" class="modal-synopsis-full">—</p>
        </div>

        <div class="modal-info-sidebar">
          <span>Gênero: <strong id="modal-genero">—</strong></span>
          <span>Autor da Crítica: <strong id="modal-autor">—</strong></span>
        </div>
      </div>
    </div>
  </div>

  <!-- =========================================================================
       6. Modal de Formulário CRUD: CADASTRAR e ATUALIZAR Série no PostgreSQL
       ========================================================================= -->
  <div id="netflix-add-modal" class="netflix-modal-overlay" role="dialog" aria-modal="true" aria-labelledby="add-form-heading">
    <div class="netflix-form-modal">
      <div class="netflix-form-header">
        <h3 id="add-form-heading">Cadastrar Nova Série no Banco de Dados</h3>
        <button id="close-add-modal-btn" class="modal-close-btn" style="position: static;" aria-label="Fechar formulário">
          <i class="bi bi-x-lg"></i>
        </button>
      </div>

      <form id="netflix-add-form" method="POST" action="${pageContext.request.contextPath}/controller">
        <input type="hidden" id="form-acao" name="acao" value="cadastrar">
        <input type="hidden" id="form-id" name="id" value="">

        <div class="netflix-form-grid">
          <div class="netflix-form-group full">
            <label for="form-titulo" class="netflix-label">Título da Série *</label>
            <input type="text" id="form-titulo" name="titulo" class="netflix-input" placeholder="Ex: Cyberpunk: Mercenários" required>
          </div>

          <div class="netflix-form-group">
            <label for="form-genero" class="netflix-label">Gênero Principal *</label>
            <input type="text" id="form-genero" name="genero" class="netflix-input" placeholder="Ex: Policial, Anime, Drama..." required>
          </div>

          <div class="netflix-form-group">
            <label for="form-ano" class="netflix-label">Ano de Lançamento *</label>
            <input type="number" id="form-ano" name="anoLancamento" class="netflix-input" placeholder="Ex: 2026" min="1900" max="2099" required>
          </div>

          <div class="netflix-form-group">
            <label for="form-nota" class="netflix-label">Nota Avaliada (0 a 10) *</label>
            <input type="number" id="form-nota" name="nota" class="netflix-input" placeholder="Ex: 9.6" min="0" max="10" step="0.1" required>
          </div>

          <div class="netflix-form-group">
            <label for="form-autor" class="netflix-label">Nome do Autor / Crítico *</label>
            <input type="text" id="form-autor" name="autor" class="netflix-input" value="${fn:escapeXml(sessionScope.usuarioLogado.nome)}" required>
          </div>

          <div class="netflix-form-group full">
            <label for="form-imagem" class="netflix-label">URL da Imagem de Capa (16:9 ou Pôster)</label>
            <input type="url" id="form-imagem" name="srcImagem" class="netflix-input" placeholder="https://exemplo.com/imagem.jpg">
          </div>

          <div class="netflix-form-group full">
            <label for="form-descricao" class="netflix-label">Sinopse / Crítica *</label>
            <textarea id="form-descricao" name="descricao" class="netflix-textarea" placeholder="Descreva a sinopse e os pontos altos da produção..." required></textarea>
          </div>
        </div>

        <div class="netflix-form-actions">
          <button type="button" class="btn-netflix-cancel" onclick="closeFormModal()">Cancelar</button>
          <button type="submit" id="form-submit-btn" class="btn-netflix-submit">Salvar no Banco</button>
        </div>
      </form>
    </div>
  </div>

  <!-- =========================================================================
       7. Rodapé Estilo Netflix
       ========================================================================= -->
  <footer class="netflix-footer" role="contentinfo">
    <div class="footer-inner">
      <p class="footer-contact">Reviewly — Painel Administrativo conectado ao PostgreSQL.</p>
      <div class="footer-links-grid">
        <a href="${pageContext.request.contextPath}/home">Ver Site (Visão do Usuário)</a>
        <a href="${pageContext.request.contextPath}/controller">Painel Admin (CRUD)</a>
        <a href="${pageContext.request.contextPath}/auth?acao=logout">Encerrar Sessão</a>
      </div>
      <div class="footer-service-code">Código de Serviço: 2026-RVW-ADMIN</div>
      <p class="footer-copy">&copy; 2026 Reviewly Inc. — Todos os direitos reservados.</p>
    </div>
  </footer>

  <script id="series-data-json" type="application/json">
    [<c:forEach var="s" items="${series}" varStatus="loop">
      {
        "id": ${s.id},
        "titulo": "${fn:escapeXml(s.titulo)}",
        "genero": "${fn:escapeXml(s.genero)}",
        "anoLancamento": ${s.anoLancamento},
        "nota": ${s.nota},
        "autor": "${fn:escapeXml(s.autor)}",
        "srcImagem": "${fn:escapeXml(s.srcImagem)}",
        "descricao": "${fn:escapeXml(s.descricao)}"
      }<c:if test="${not loop.last}">,</c:if>
    </c:forEach>]
  </script>

  <script src="js/script.js" defer></script>
</body>
</html>
