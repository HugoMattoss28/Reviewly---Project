<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<c:if test="${series == null}">
  <c:redirect url="/home"/>
</c:if>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Reviewly - O portal de críticas e catálogo de séries no estilo streaming.">
  <meta name="theme-color" content="#141414">
  <title>Reviewly — Catálogo de Séries e Críticas</title>

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

  <%-- Toasts de Feedback --%>
  <c:if test="${param.login == '1'}">
    <div class="reviewly-toast reviewly-toast--success" role="alert">
      <i class="bi bi-person-check-fill"></i>
      <span>Bem-vindo(a), ${fn:escapeXml(sessionScope.usuarioLogado.nome)}!</span>
    </div>
  </c:if>
  <c:if test="${param.cadastro == '1'}">
    <div class="reviewly-toast reviewly-toast--success" role="alert">
      <i class="bi bi-check-circle-fill"></i>
      <span>Conta criada com sucesso no banco de dados!</span>
    </div>
  </c:if>
  <c:if test="${param.logout == '1'}">
    <div class="reviewly-toast reviewly-toast--success" role="alert">
      <i class="bi bi-box-arrow-right"></i>
      <span>Sessão encerrada com sucesso.</span>
    </div>
  </c:if>
  <c:if test="${param.sucesso == '1'}">
    <div class="reviewly-toast reviewly-toast--success" role="alert">
      <i class="bi bi-check-circle-fill"></i>
      <span>Série cadastrada com sucesso no banco!</span>
    </div>
  </c:if>
  <c:if test="${param.atualizado == '1'}">
    <div class="reviewly-toast reviewly-toast--success" role="alert">
      <i class="bi bi-pencil-square"></i>
      <span>Série atualizada com sucesso!</span>
    </div>
  </c:if>
  <c:if test="${param.excluido == '1'}">
    <div class="reviewly-toast reviewly-toast--error" role="alert">
      <i class="bi bi-trash3-fill"></i>
      <span>Série removida do catálogo.</span>
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
       2. Barra de Navegação Estilo Netflix
       ========================================================================= -->
  <header class="netflix-header" role="banner">
    <div class="header-left">
      <a href="${pageContext.request.contextPath}/home" class="netflix-logo" aria-label="Reviewly Início">REVIEWLY</a>
      <nav class="header-nav" role="navigation" aria-label="Menu Principal">
        <a href="${pageContext.request.contextPath}/home" class="nav-item-pill">Início</a>
        <a href="#row-catalogo" class="nav-item-link">Catálogo</a>
        <a href="#row-policiais" class="nav-item-link">Séries</a>
        <a href="#row-aclamadas" class="nav-item-link">Aclamadas</a>
        <a href="#row-anime" class="nav-item-link">Animes</a>
        <a href="#row-alta" class="nav-item-link">Bombando</a>
        <%-- Opção extra de menu exclusiva para o Admin --%>
        <c:if test="${not empty sessionScope.usuarioLogado and sessionScope.usuarioLogado.admin}">
          <a href="${pageContext.request.contextPath}/controller" class="nav-item-link nav-admin-highlight">
            <i class="bi bi-sliders"></i> Painel Admin (CRUD)
          </a>
        </c:if>
      </nav>
    </div>

    <div class="header-right">
      <!-- Barra de Busca Expansível -->
      <div class="netflix-search-box">
        <button class="search-toggle-btn" aria-label="Buscar séries">
          <i class="bi bi-search"></i>
        </button>
        <i class="bi bi-search search-input-icon" aria-hidden="true"></i>
        <input type="text" id="catalog-search-input" class="netflix-search-input" placeholder="Títulos, gêneros, autores..." aria-label="Campo de busca">
      </div>

      <!-- Sino de Notificações -->
      <div class="notification-btn-wrap">
        <button id="notification-bell-btn" class="search-toggle-btn" title="Reabrir Aviso de Segurança Metflix" aria-label="Notificações">
          <i class="bi bi-bell"></i>
          <span class="bell-badge-count">1</span>
        </button>
      </div>

      <%-- Botão rápido de Cadastrar na barra se for ADMIN --%>
      <c:if test="${not empty sessionScope.usuarioLogado and sessionScope.usuarioLogado.admin}">
        <button type="button" class="btn-netflix-add" onclick="openCreateModal()">
          <i class="bi bi-plus-lg"></i>
          <span>Adicionar Série</span>
        </button>
      </c:if>

      <%-- Área de Login / Usuário Logado --%>
      <c:choose>
        <c:when test="${not empty sessionScope.usuarioLogado}">
          <div class="user-logged-pill">
            <div class="avatar-square ${sessionScope.usuarioLogado.admin ? 'avatar-admin' : ''}">
              ${fn:substring(sessionScope.usuarioLogado.nome, 0, 2)}
            </div>
            <div class="user-logged-info">
              <span class="user-logged-name">${fn:escapeXml(sessionScope.usuarioLogado.nome)}</span>
              <span class="user-logged-role ${sessionScope.usuarioLogado.admin ? 'role-admin' : 'role-user'}">
                ${sessionScope.usuarioLogado.admin ? 'ADMIN' : 'USUÁRIO'}
              </span>
            </div>
            <a href="${pageContext.request.contextPath}/auth?acao=logout" class="btn-logout-icon" title="Sair da conta">
              <i class="bi bi-box-arrow-right"></i>
            </a>
          </div>
        </c:when>
        <c:otherwise>
          <a href="${pageContext.request.contextPath}/auth" class="btn-netflix-add" style="text-decoration: none;">
            <i class="bi bi-person-fill"></i>
            <span>Entrar / Cadastrar</span>
          </a>
        </c:otherwise>
      </c:choose>
    </div>
  </header>

  <main role="main">
    <!-- =========================================================================
         3. Billboard Hero em Card Arredondado
         ========================================================================= -->
    <section class="billboard-wrapper" aria-label="Destaque Principal">
      <div id="hero-billboard-card" class="billboard-rounded-card">

        <div class="billboard-ribbon-logo" aria-hidden="true">R</div>

        <!-- Controles manuais de Anterior / Próximo no Hero -->
        <c:if test="${fn:length(series) > 1}">
          <div class="billboard-carousel-controls">
            <button type="button" id="hero-prev-btn" class="billboard-nav-btn" aria-label="Série anterior" title="Série anterior">
              <i class="bi bi-chevron-left"></i>
            </button>
            <span id="hero-slide-counter" class="billboard-slide-counter">1 / ${fn:length(series)}</span>
            <button type="button" id="hero-next-btn" class="billboard-nav-btn" aria-label="Próxima série" title="Próxima série">
              <i class="bi bi-chevron-right"></i>
            </button>
          </div>
        </c:if>

        <div class="billboard-card-backdrop">
          <c:choose>
            <c:when test="${not empty series and not empty series[0].srcImagem}">
              <img id="hero-backdrop-img" src="${fn:escapeXml(series[0].srcImagem)}" alt="Capa em destaque: ${fn:escapeXml(series[0].titulo)}">
            </c:when>
            <c:otherwise>
              <img id="hero-backdrop-img" src="https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=1920&q=85" alt="Cena épica de animação cinematográfica">
            </c:otherwise>
          </c:choose>
        </div>
        <div class="billboard-card-vignette-left"></div>
        <div class="billboard-card-vignette-bottom"></div>

        <div class="billboard-card-content">
          <div id="hero-info-side" class="billboard-info-side">
            <c:choose>
              <c:when test="${not empty series}">
                <h1 id="hero-title" class="billboard-logo-title">${fn:escapeXml(series[0].titulo)}</h1>
                <div class="billboard-meta-line">
                  <span style="color: #ffbe0b; font-weight: 700;"><i class="bi bi-star-fill"></i> <span id="hero-nota">${series[0].nota}</span></span>
                  <span>•</span>
                  <span id="hero-genero">${fn:escapeXml(series[0].genero)}</span>
                  <span>•</span>
                  <span id="hero-ano">${series[0].anoLancamento}</span>
                  <span>•</span>
                  <span class="badge-age-netflix">A16</span>
                </div>
                <p id="hero-synopsis" class="billboard-synopsis-text">${fn:escapeXml(series[0].descricao)}</p>
              </c:when>
              <c:otherwise>
                <h1 id="hero-title" class="billboard-logo-title">REVIEWLY ORIGINALS</h1>
                <div class="billboard-meta-line">
                  <span>Série</span>
                  <span>•</span>
                  <span>Catálogo &amp; Reviews</span>
                  <span>•</span>
                  <span>2026</span>
                  <span>•</span>
                  <span class="badge-age-netflix">A16</span>
                </div>
                <p id="hero-synopsis" class="billboard-synopsis-text">
                  Bem-vindo ao Reviewly! Explore as críticas e notas das melhores séries. O catálogo é gerenciado pelos Administradores diretamente no PostgreSQL.
                </p>
              </c:otherwise>
            </c:choose>

            <div class="billboard-actions-pill">
              <c:choose>
                <c:when test="${not empty series}">
                  <button id="hero-btn-play" class="btn-pill-white" onclick="openDetailModal(${series[0].id})">
                    <i class="bi bi-play-fill" style="font-size: 1.15rem;"></i>
                    <span>Ver Crítica Completa</span>
                  </button>
                  <button id="hero-btn-info" class="btn-pill-gray" onclick="openDetailModal(${series[0].id})">
                    <i class="bi bi-info-circle"></i>
                    <span>Mais informações</span>
                  </button>
                </c:when>
                <c:otherwise>
                  <button id="hero-btn-info" class="btn-pill-gray" onclick="openDetailModal(0)">
                    <i class="bi bi-info-circle"></i>
                    <span>Mais informações</span>
                  </button>
                </c:otherwise>
              </c:choose>

              <%-- Botões extras no Hero exclusivos para o Administrador --%>
              <c:if test="${not empty sessionScope.usuarioLogado and sessionScope.usuarioLogado.admin}">
                <button class="btn-pill-admin" onclick="openCreateModal()">
                  <i class="bi bi-plus-lg"></i>
                  <span>Cadastrar Série (Admin)</span>
                </button>
                <a href="${pageContext.request.contextPath}/controller" class="btn-pill-gray" style="text-decoration: none;">
                  <i class="bi bi-sliders"></i>
                  <span>Gerenciar CRUD</span>
                </a>
              </c:if>
            </div>
          </div>

          <div class="billboard-pill-tags-right">
            <div class="billboard-pill-tag">
              <i class="bi bi-collection-play-fill"></i>
              <span>${fn:length(series)} série(s) no catálogo</span>
            </div>
            <div class="billboard-pill-tag">
              <i class="bi bi-hand-thumbs-up-fill" style="color: #46d369;"></i>
              <span>Curadoria Oficial Reviewly</span>
            </div>
          </div>
        </div>

      </div>
    </section>

    <!-- =========================================================================
         4. Fileiras de Conteúdo (Visão do Usuário + Botões Rápidos se for Admin)
         ========================================================================= -->
    <div id="rows-section" class="netflix-content-body">

      <!-- Fileira Principal: Todas as Séries do Catálogo -->
      <section id="row-catalogo" class="netflix-row" aria-labelledby="heading-catalogo">
        <h2 id="heading-catalogo" class="row-title">Catálogo Completo no Reviewly</h2>
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

                <%-- Opções extras no card se o usuário logado for ADMIN --%>
                <c:if test="${not empty sessionScope.usuarioLogado and sessionScope.usuarioLogado.admin}">
                  <div class="card-admin-quick-actions">
                    <button type="button" class="btn-card-admin edit" title="Editar série (Admin)" onclick="event.stopPropagation(); openEditModal(${s.id});">
                      <i class="bi bi-pencil-fill"></i>
                    </button>
                    <a href="${pageContext.request.contextPath}/controller?acao=excluir&id=${s.id}&origem=home"
                       class="btn-card-admin delete" title="Excluir série (Admin)"
                       onclick="event.stopPropagation(); return confirm('Deseja realmente excluir esta série do banco de dados?');">
                      <i class="bi bi-trash3-fill"></i>
                    </a>
                  </div>
                </c:if>
              </div>

              <div class="card-below-caption">
                <p class="card-below-title">${fn:escapeXml(s.titulo)}</p>
              </div>
            </article>
          </c:forEach>

          <c:if test="${empty series}">
            <div class="netflix-empty-state">
              <i class="bi bi-collection-play empty-icon" aria-hidden="true"></i>
              <p class="empty-text">O catálogo ainda não possui séries cadastradas.</p>
              <c:if test="${not empty sessionScope.usuarioLogado and sessionScope.usuarioLogado.admin}">
                <button class="btn-netflix-add" onclick="openCreateModal()">
                  <i class="bi bi-plus-lg"></i> Cadastrar Primeira Série
                </button>
              </c:if>
            </div>
          </c:if>
        </div>
      </section>

      <!-- Fileira 1: Séries Policiais -->
      <section id="row-policiais" class="netflix-row" aria-labelledby="heading-policiais">
        <h2 id="heading-policiais" class="row-title">Séries policiais</h2>
        <div class="row-cards-container">
          <c:set var="hasPoliciais" value="false" />
          <c:forEach var="s" items="${series}">
            <c:if test="${fn:containsIgnoreCase(s.genero, 'policial') or fn:containsIgnoreCase(s.genero, 'crime') or fn:containsIgnoreCase(s.genero, 'thriller') or fn:containsIgnoreCase(s.genero, 'investig')}">
              <c:set var="hasPoliciais" value="true" />
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
                </div>
                <div class="card-below-caption">
                  <p class="card-below-title">${fn:escapeXml(s.titulo)}</p>
                </div>
              </article>
            </c:if>
          </c:forEach>
          <c:if test="${not hasPoliciais}">
            <div class="netflix-empty-state">
              <i class="bi bi-shield-shaded empty-icon" aria-hidden="true"></i>
              <p class="empty-text">Nenhuma série policial cadastrada no momento.</p>
            </div>
          </c:if>
        </div>
      </section>

      <!-- Fileira 2: Séries Aclamadas pela Crítica -->
      <section id="row-aclamadas" class="netflix-row" aria-labelledby="heading-aclamadas">
        <h2 id="heading-aclamadas" class="row-title">Séries aclamadas pela crítica (Nota 8.5+)</h2>
        <div class="row-cards-container">
          <c:set var="hasAclamadas" value="false" />
          <c:forEach var="s" items="${series}">
            <c:if test="${s.nota >= 8.5}">
              <c:set var="hasAclamadas" value="true" />
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
                </div>
                <div class="card-below-caption">
                  <p class="card-below-title">${fn:escapeXml(s.titulo)}</p>
                </div>
              </article>
            </c:if>
          </c:forEach>
          <c:if test="${not hasAclamadas}">
            <div class="netflix-empty-state">
              <i class="bi bi-star-fill empty-icon" style="color: #ffbe0b;" aria-hidden="true"></i>
              <p class="empty-text">As produções com nota 8.5 ou superior aparecerão aqui.</p>
            </div>
          </c:if>
        </div>
      </section>

      <!-- Fileira 3: Animes -->
      <section id="row-anime" class="netflix-row" aria-labelledby="heading-anime">
        <h2 id="heading-anime" class="row-title">Você pediu anime? Toma anime!</h2>
        <div class="row-cards-container">
          <c:set var="hasAnime" value="false" />
          <c:forEach var="s" items="${series}">
            <c:if test="${fn:containsIgnoreCase(s.genero, 'anime') or fn:containsIgnoreCase(s.genero, 'anima')}">
              <c:set var="hasAnime" value="true" />
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
                </div>
                <div class="card-below-caption">
                  <p class="card-below-title">${fn:escapeXml(s.titulo)}</p>
                </div>
              </article>
            </c:if>
          </c:forEach>
          <c:if test="${not hasAnime}">
            <div class="netflix-empty-state">
              <i class="bi bi-lightning-charge-fill empty-icon" style="color: #00f2fe;" aria-hidden="true"></i>
              <p class="empty-text">Nenhum anime registrado no momento.</p>
            </div>
          </c:if>
        </div>
      </section>

      <!-- Fileira 4: Novas temporadas e em alta -->
      <section id="row-alta" class="netflix-row" aria-labelledby="heading-alta">
        <h2 id="heading-alta" class="row-title">Novas temporadas e em alta (2023+)</h2>
        <div class="row-cards-container">
          <c:set var="hasAlta" value="false" />
          <c:forEach var="s" items="${series}">
            <c:if test="${s.anoLancamento >= 2023}">
              <c:set var="hasAlta" value="true" />
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
                </div>
                <div class="card-below-caption">
                  <p class="card-below-title">${fn:escapeXml(s.titulo)}</p>
                </div>
              </article>
            </c:if>
          </c:forEach>
          <c:if test="${not hasAlta}">
            <div class="netflix-empty-state">
              <i class="bi bi-fire empty-icon" style="color: #E50914;" aria-hidden="true"></i>
              <p class="empty-text">Nenhuma produção recente cadastrada ainda.</p>
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

  <%-- Modal de Cadastro/Edição rápida na Home (disponível apenas se logado como Admin) --%>
  <c:if test="${not empty sessionScope.usuarioLogado and sessionScope.usuarioLogado.admin}">
    <div id="netflix-add-modal" class="netflix-modal-overlay" role="dialog" aria-modal="true" aria-labelledby="add-form-heading">
      <div class="netflix-form-modal">
        <div class="netflix-form-header">
          <h3 id="add-form-heading">Cadastrar Nova Série (Atalho Admin)</h3>
          <button id="close-add-modal-btn" class="modal-close-btn" style="position: static;" aria-label="Fechar formulário">
            <i class="bi bi-x-lg"></i>
          </button>
        </div>

        <form id="netflix-add-form" method="POST" action="${pageContext.request.contextPath}/controller">
          <input type="hidden" id="form-acao" name="acao" value="cadastrar">
          <input type="hidden" id="form-id" name="id" value="">
          <input type="hidden" name="origem" value="home">

          <div class="netflix-form-grid">
            <div class="netflix-form-group full">
              <label for="form-titulo" class="netflix-label">Título da Série *</label>
              <input type="text" id="form-titulo" name="titulo" class="netflix-input" placeholder="Ex: Cyberpunk: Mercenários" required>
            </div>

            <div class="netflix-form-group">
              <label for="form-genero" class="netflix-label">Gênero Principal *</label>
              <input type="text" id="form-genero" name="genero" class="netflix-input" placeholder="Ex: Policial / Anime / Drama" required>
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
  </c:if>

  <!-- =========================================================================
       7. Rodapé Estilo Netflix
       ========================================================================= -->
  <footer class="netflix-footer" role="contentinfo">
    <div class="footer-inner">
      <p class="footer-contact">Reviewly — Sistema de Avaliação e Catálogo de Séries com Java e PostgreSQL.</p>
      <div class="footer-links-grid">
        <a href="${pageContext.request.contextPath}/home">Tela Inicial (Catálogo)</a>
        <a href="${pageContext.request.contextPath}/auth">Login / Cadastro</a>
        <a href="${pageContext.request.contextPath}/controller">Painel do Administrador (CRUD)</a>
        <a href="#">Termos de Uso</a>
      </div>
      <div class="footer-service-code">Código de Serviço: 2026-RVW-001</div>
      <p class="footer-copy">&copy; 2026 Reviewly Inc. — Todos os direitos reservados. Não associado ao Metflix.</p>
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

