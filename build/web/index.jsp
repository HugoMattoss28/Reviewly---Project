<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Reviewly - O portal de críticas e catálogo de séries no estilo streaming.">
  <meta name="theme-color" content="#141414">
  <title>Reviewly — Séries, Críticas e Catálogo</title>

  <!-- Google Fonts: Bebas Neue (Logo e Títulos) & Montserrat (Interface Netflix) -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Montserrat:wght@400;500;600;700;800&display=swap" rel="stylesheet">

  <!-- Bootstrap Icons (CDN Oficial) -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

  <!-- Folha de Estilos Externa (CSS3) -->
  <link rel="stylesheet" href="css/style.css">
</head>
<body>

  <%-- =========================================================================
       Feedback de operação (erro de banco ou sucesso de cadastro)
       ========================================================================= --%>
  <c:if test="${not empty erroFormulario}">
    <div class="reviewly-toast reviewly-toast--error" role="alert">
      <i class="bi bi-exclamation-triangle-fill"></i>
      <span>${erroFormulario}</span>
    </div>
  </c:if>
  <c:if test="${param.sucesso == '1'}">
    <div class="reviewly-toast reviewly-toast--success" role="alert">
      <i class="bi bi-check-circle-fill"></i>
      <span>Série cadastrada com sucesso no banco de dados!</span>
    </div>
  </c:if>

  <!-- =========================================================================
       1. Alerta de Segurança Oficial: Cuidado com o site falso "Metflix"
       Aparece apenas uma vez (armazenado no localStorage ao dispensar)
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
      <a href="${pageContext.request.contextPath}/controller" class="netflix-logo" aria-label="Reviewly Início">REVIEWLY</a>
      <nav class="header-nav" role="navigation" aria-label="Menu Principal">
        <a href="${pageContext.request.contextPath}/controller" class="nav-item-pill">Início</a>
        <a href="#row-policiais" class="nav-item-link">Séries</a>
        <a href="#row-aclamadas" class="nav-item-link">Filmes</a>
        <a href="#row-anime" class="nav-item-link">Jogos</a>
        <a href="#row-alta" class="nav-item-link">Bombando</a>
        <a href="#" class="nav-item-link">Minha Netflix</a>
        <a href="#" class="nav-item-link">Navegar por idiomas</a>
      </nav>
    </div>

    <div class="header-right">
      <!-- Barra de Busca Expansível -->
      <div class="netflix-search-box">
        <button class="search-toggle-btn" aria-label="Buscar séries">
          <i class="bi bi-search"></i>
        </button>
        <i class="bi bi-search search-input-icon" aria-hidden="true"></i>
        <input type="text" class="netflix-search-input" placeholder="Títulos, gêneros, pessoas..." aria-label="Campo de busca">
      </div>

      <!-- Sino de Notificações com Badge vermelho -->
      <div class="notification-btn-wrap">
        <button id="notification-bell-btn" class="search-toggle-btn" title="Notificações e Avisos de Segurança" aria-label="Notificações">
          <i class="bi bi-bell"></i>
          <span class="bell-badge-count">1</span>
        </button>
      </div>

      <!-- Perfil de Usuário com Avatar e Caret -->
      <div class="profile-pill-wrap" title="Perfil de Crítico">
        <div class="avatar-square">RV</div>
        <i class="bi bi-caret-down-fill profile-caret"></i>
      </div>

      <!-- Botão para Cadastrar Série no Banco de Dados -->
      <button class="btn-netflix-add open-add-modal-btn">
        <i class="bi bi-plus-lg"></i>
        <span>Adicionar Série</span>
      </button>
    </div>
  </header>

  <main role="main">
    <!-- =========================================================================
         3. Billboard Hero em Card Arredondado
         ========================================================================= -->
    <section class="billboard-wrapper" aria-label="Destaque Principal">
      <div class="billboard-rounded-card">
        
        <!-- Emblema "R" vermelho no topo esquerdo do card -->
        <div class="billboard-ribbon-logo" aria-hidden="true">R</div>

        <!-- Botão de volume redondo no topo direito do card -->
        <button class="billboard-volume-btn" aria-label="Alternar áudio" title="Som">
          <i class="bi bi-volume-up"></i>
        </button>

        <!-- Imagem de fundo com vinhetas cinematográficas -->
        <div class="billboard-card-backdrop">
          <%-- Se existir alguma série cadastrada, usa a imagem da primeira --%>
          <c:choose>
            <c:when test="${not empty series and not empty series[0].srcImagem}">
              <img src="${fn:escapeXml(series[0].srcImagem)}" alt="Capa em destaque: ${fn:escapeXml(series[0].titulo)}">
            </c:when>
            <c:otherwise>
              <img src="https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=1920&q=85" alt="Cena épica de animação cinematográfica">
            </c:otherwise>
          </c:choose>
        </div>
        <div class="billboard-card-vignette-left"></div>
        <div class="billboard-card-vignette-bottom"></div>

        <!-- Conteúdo inferior sobreposto no card -->
        <div class="billboard-card-content">
          <div class="billboard-info-side">
            <c:choose>
              <c:when test="${not empty series}">
                <h1 class="billboard-logo-title">${fn:escapeXml(series[0].titulo)}</h1>
                <div class="billboard-meta-line">
                  <span>${fn:escapeXml(series[0].genero)}</span>
                  <span>•</span>
                  <span>${series[0].anoLancamento}</span>
                  <span>•</span>
                  <span class="badge-age-netflix">A16</span>
                </div>
                <p class="billboard-synopsis-text">${fn:escapeXml(series[0].descricao)}</p>
              </c:when>
              <c:otherwise>
                <h1 class="billboard-logo-title">REVIEWLY ORIGINALS</h1>
                <div class="billboard-meta-line">
                  <span>Série</span>
                  <span>•</span>
                  <span>Catálogo &amp; Reviews</span>
                  <span>•</span>
                  <span>2026</span>
                  <span>•</span>
                  <span class="badge-age-netflix">A16</span>
                </div>
                <p class="billboard-synopsis-text">
                  Sua plataforma de streaming está pronta para receber os registros reais do banco PostgreSQL. Conecte sua base e cadastre suas séries para preencher as fileiras da curadoria.
                </p>
              </c:otherwise>
            </c:choose>

            <div class="billboard-actions-pill">
              <button class="btn-pill-white open-add-modal-btn">
                <i class="bi bi-play-fill" style="font-size: 1.15rem;"></i>
                <span>Assistir / Cadastrar</span>
              </button>
              <c:if test="${not empty series}">
                <button class="btn-pill-gray" onclick="openDetailModal(${series[0].id})">
                  <i class="bi bi-info-circle"></i>
                  <span>Mais informações</span>
                </button>
              </c:if>
              <c:if test="${empty series}">
                <button class="btn-pill-gray" onclick="openDetailModal(0)">
                  <i class="bi bi-info-circle"></i>
                  <span>Mais informações</span>
                </button>
              </c:if>
            </div>
          </div>

          <!-- Pílulas informativas no canto direito -->
          <div class="billboard-pill-tags-right">
            <div class="billboard-pill-tag">
              <i class="bi bi-calendar-event"></i>
              <span>Temporada 2: terça-feira</span>
            </div>
            <div class="billboard-pill-tag">
              <i class="bi bi-hand-thumbs-up-fill" style="color: #46d369;"></i>
              <span>Achamos que você vai amar isto!</span>
            </div>
          </div>
        </div>

      </div>
    </section>

    <!-- =========================================================================
         4. Fileiras de Conteúdo — populadas pelo banco de dados via JSTL
         ========================================================================= -->
    <div id="rows-section" class="netflix-content-body">
      
      <%-- Helper: macro que renderiza os cards de uma lista filtrada por gênero.
           Para cada fileira, filtramos a lista "series" pelo gênero-chave.
           Se não houver nenhum, exibe o empty-state. --%>

      <!-- Fileira 1: Séries Policiais -->
      <section id="row-policiais" class="netflix-row" aria-labelledby="heading-policiais">
        <h2 id="heading-policiais" class="row-title">Séries policiais</h2>
        <div class="row-cards-container">
          <%-- Renderiza cards para séries cujo gênero contenha "policial" (case-insensitive) --%>
          <c:set var="hasPoliciais" value="false" />
          <c:forEach var="s" items="${series}">
            <c:if test="${fn:containsIgnoreCase(s.genero, 'policial') or fn:containsIgnoreCase(s.genero, 'crime') or fn:containsIgnoreCase(s.genero, 'thriller')}">
              <c:set var="hasPoliciais" value="true" />
              <article class="netflix-card" data-id="${s.id}" onclick="openDetailModal(${s.id})">
                <div class="card-thumb">
                  <c:choose>
                    <c:when test="${not empty s.srcImagem}">
                      <img src="${fn:escapeXml(s.srcImagem)}" alt="${fn:escapeXml(s.titulo)}" loading="lazy">
                    </c:when>
                    <c:otherwise>
                      <div class="card-thumb-placeholder"><i class="bi bi-film"></i></div>
                    </c:otherwise>
                  </c:choose>
                </div>
                <div class="card-hover-info">
                  <p class="card-hover-title">${fn:escapeXml(s.titulo)}</p>
                  <span class="card-hover-nota"><i class="bi bi-star-fill"></i> ${s.nota}</span>
                </div>
              </article>
            </c:if>
          </c:forEach>
          <c:if test="${not hasPoliciais}">
            <div class="netflix-empty-state">
              <i class="bi bi-shield-shaded empty-icon" aria-hidden="true"></i>
              <p class="empty-text">Nenhuma série policial cadastrada no banco de dados.</p>
              <button class="btn-netflix-add open-add-modal-btn">
                <i class="bi bi-plus-lg"></i> Cadastrar Série
              </button>
            </div>
          </c:if>
        </div>
      </section>

      <!-- Fileira 2: Séries Aclamadas pela Crítica (nota >= 8.5) -->
      <section id="row-aclamadas" class="netflix-row" aria-labelledby="heading-aclamadas">
        <h2 id="heading-aclamadas" class="row-title">Séries aclamadas pela crítica</h2>
        <div class="row-cards-container">
          <c:set var="hasAclamadas" value="false" />
          <c:forEach var="s" items="${series}">
            <c:if test="${s.nota >= 8.5}">
              <c:set var="hasAclamadas" value="true" />
              <article class="netflix-card" data-id="${s.id}" onclick="openDetailModal(${s.id})">
                <div class="card-thumb">
                  <c:choose>
                    <c:when test="${not empty s.srcImagem}">
                      <img src="${fn:escapeXml(s.srcImagem)}" alt="${fn:escapeXml(s.titulo)}" loading="lazy">
                    </c:when>
                    <c:otherwise>
                      <div class="card-thumb-placeholder"><i class="bi bi-film"></i></div>
                    </c:otherwise>
                  </c:choose>
                </div>
                <div class="card-hover-info">
                  <p class="card-hover-title">${fn:escapeXml(s.titulo)}</p>
                  <span class="card-hover-nota"><i class="bi bi-star-fill"></i> ${s.nota}</span>
                </div>
              </article>
            </c:if>
          </c:forEach>
          <c:if test="${not hasAclamadas}">
            <div class="netflix-empty-state">
              <i class="bi bi-star-fill empty-icon" style="color: #ffbe0b;" aria-hidden="true"></i>
              <p class="empty-text">As produções com as maiores notas do banco de dados aparecerão aqui.</p>
              <button class="btn-netflix-add open-add-modal-btn">
                <i class="bi bi-plus-lg"></i> Cadastrar Série
              </button>
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
            <c:if test="${fn:containsIgnoreCase(s.genero, 'anime')}">
              <c:set var="hasAnime" value="true" />
              <article class="netflix-card" data-id="${s.id}" onclick="openDetailModal(${s.id})">
                <div class="card-thumb">
                  <c:choose>
                    <c:when test="${not empty s.srcImagem}">
                      <img src="${fn:escapeXml(s.srcImagem)}" alt="${fn:escapeXml(s.titulo)}" loading="lazy">
                    </c:when>
                    <c:otherwise>
                      <div class="card-thumb-placeholder"><i class="bi bi-film"></i></div>
                    </c:otherwise>
                  </c:choose>
                </div>
                <div class="card-hover-info">
                  <p class="card-hover-title">${fn:escapeXml(s.titulo)}</p>
                  <span class="card-hover-nota"><i class="bi bi-star-fill"></i> ${s.nota}</span>
                </div>
              </article>
            </c:if>
          </c:forEach>
          <c:if test="${not hasAnime}">
            <div class="netflix-empty-state">
              <i class="bi bi-lightning-charge-fill empty-icon" style="color: #00f2fe;" aria-hidden="true"></i>
              <p class="empty-text">Nenhum anime registrado no banco no momento.</p>
              <button class="btn-netflix-add open-add-modal-btn">
                <i class="bi bi-plus-lg"></i> Cadastrar Série
              </button>
            </div>
          </c:if>
        </div>
      </section>

      <!-- Fileira 4: Novas temporadas e em alta (mais recentes, por anoLancamento) -->
      <section id="row-alta" class="netflix-row" aria-labelledby="heading-alta">
        <h2 id="heading-alta" class="row-title">Novas temporadas e em alta</h2>
        <div class="row-cards-container">
          <c:set var="hasAlta" value="false" />
          <c:forEach var="s" items="${series}">
            <c:if test="${s.anoLancamento >= 2023}">
              <c:set var="hasAlta" value="true" />
              <article class="netflix-card" data-id="${s.id}" onclick="openDetailModal(${s.id})">
                <div class="card-thumb">
                  <c:choose>
                    <c:when test="${not empty s.srcImagem}">
                      <img src="${fn:escapeXml(s.srcImagem)}" alt="${fn:escapeXml(s.titulo)}" loading="lazy">
                    </c:when>
                    <c:otherwise>
                      <div class="card-thumb-placeholder"><i class="bi bi-film"></i></div>
                    </c:otherwise>
                  </c:choose>
                </div>
                <div class="card-hover-info">
                  <p class="card-hover-title">${fn:escapeXml(s.titulo)}</p>
                  <span class="card-hover-nota"><i class="bi bi-star-fill"></i> ${s.nota}</span>
                </div>
              </article>
            </c:if>
          </c:forEach>
          <c:if test="${not hasAlta}">
            <div class="netflix-empty-state">
              <i class="bi bi-fire empty-icon" style="color: #E50914;" aria-hidden="true"></i>
              <p class="empty-text">Nenhuma produção recente cadastrada ainda.</p>
              <button class="btn-netflix-add open-add-modal-btn">
                <i class="bi bi-plus-lg"></i> Cadastrar Série
              </button>
            </div>
          </c:if>
        </div>
      </section>

    </div>
  </main>

  <!-- =========================================================================
       5. Modal Estilo Netflix: "Mais Informações"
       Populado via JavaScript com os dados JSON das séries
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
       6. Modal de Formulário: Envia para POST /controller?acao=cadastrar
       ========================================================================= -->
  <div id="netflix-add-modal" class="netflix-modal-overlay" role="dialog" aria-modal="true" aria-labelledby="add-form-heading">
    <div class="netflix-form-modal">
      <div class="netflix-form-header">
        <h3 id="add-form-heading">Cadastrar Nova Série no Banco de Dados</h3>
        <button id="close-add-modal-btn" class="modal-close-btn" style="position: static;" aria-label="Fechar formulário">
          <i class="bi bi-x-lg"></i>
        </button>
      </div>

      <!-- Formulário com método POST e campos mapeados para Serie.java -->
      <form id="netflix-add-form" method="POST" action="${pageContext.request.contextPath}/controller">
        <input type="hidden" name="acao" value="cadastrar">

        <div class="netflix-form-grid">
          <div class="netflix-form-group full">
            <label for="form-titulo" class="netflix-label">Título da Série *</label>
            <input type="text" id="form-titulo" name="titulo" class="netflix-input" placeholder="Ex: Cyberpunk: Mercenários" required>
          </div>

          <div class="netflix-form-group">
            <label for="form-genero" class="netflix-label">Gênero Principal *</label>
            <input type="text" id="form-genero" name="genero" class="netflix-input" placeholder="Ex: Anime / Sci-Fi" required>
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
            <input type="text" id="form-autor" name="autor" class="netflix-input" placeholder="Ex: Seu Nome" required>
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
          <button type="button" class="btn-netflix-cancel" onclick="document.getElementById('netflix-add-modal').classList.remove('active'); document.body.style.overflow='';">Cancelar</button>
          <button type="submit" class="btn-netflix-submit">Salvar no Banco</button>
        </div>
      </form>
    </div>
  </div>

  <!-- =========================================================================
       7. Rodapé Estilo Netflix
       ========================================================================= -->
  <footer class="netflix-footer" role="contentinfo">
    <div class="footer-inner">
      <p class="footer-contact">Reviewly — Sistema de Avaliação e Catálogo de Séries com Java e PostgreSQL.</p>

      <div class="footer-links-grid">
        <a href="#">Perguntas frequentes</a>
        <a href="#">Central de Ajuda</a>
        <a href="#">Termos de Uso</a>
        <a href="#">Privacidade</a>
      </div>

      <div class="footer-service-code">Código de Serviço: 2026-RVW-001</div>

      <p class="footer-copy">&copy; 2026 Reviewly Inc. — Todos os direitos reservados. Não associado ao Metflix.</p>
    </div>
  </footer>

  <%-- JSON embarcado no HTML para uso do modal de detalhes pelo JavaScript.
       Cada série retornada pelo banco é serializada aqui de forma segura. --%>
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

  <!-- Script Responsável Estritamente por Animações e Interações de UI -->
  <script src="js/script.js" defer></script>
</body>
</html>

