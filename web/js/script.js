/**
 * ============================================================================
 * REVIEWLY - NETFLIX STREAMING UI ENGINE (JS)
 * Responsabilidade única: Animações e Interações de Interface (UI/UX)
 * Todo o gerenciamento de dados e cadastro é delegado ao Java e PostgreSQL.
 * ============================================================================
 */

document.addEventListener('DOMContentLoaded', () => {

  /* --------------------------------------------------------------------------
     0. Carrega o JSON de séries embutido no JSP pelo Java (somente leitura)
     O elemento <script id="series-data-json"> é escrito pelo index.jsp
     com os dados reais do banco de dados PostgreSQL.
     -------------------------------------------------------------------------- */
  let seriesList = [];
  try {
    const jsonEl = document.getElementById('series-data-json');
    if (jsonEl) {
      seriesList = JSON.parse(jsonEl.textContent.trim()) || [];
    }
  } catch (_) {
    seriesList = [];
  }

  /* --------------------------------------------------------------------------
     1. Alerta de Segurança Oficial: Metflix (Aparece Apenas Uma Vez)
     -------------------------------------------------------------------------- */
  const initMetflixSecurityAlert = () => {
    const alertBar = document.getElementById('metflix-security-alert');
    const ackBtn = document.getElementById('ack-alert-btn');
    const closeBtn = document.getElementById('close-alert-btn');
    const bellBtn = document.getElementById('notification-bell-btn');

    const STORAGE_KEY = 'reviewly_metflix_warning_dismissed_v1';
    const isDismissed = localStorage.getItem(STORAGE_KEY);

    // Se já foi fechado pelo usuário anteriormente, oculta
    if (isDismissed === 'true') {
      if (alertBar) alertBar.classList.add('hidden');
    } else {
      if (alertBar) alertBar.classList.remove('hidden');
    }

    const dismissAlert = () => {
      if (alertBar) {
        alertBar.style.transition = 'transform 0.35s ease, opacity 0.35s ease';
        alertBar.style.transform = 'translateY(-100%)';
        alertBar.style.opacity = '0';
        setTimeout(() => {
          alertBar.classList.add('hidden');
          localStorage.setItem(STORAGE_KEY, 'true');
        }, 350);
      }
    };

    if (ackBtn) ackBtn.addEventListener('click', dismissAlert);
    if (closeBtn) closeBtn.addEventListener('click', dismissAlert);

    // Reabre o alerta caso o usuário clique no sino de notificações
    if (bellBtn) {
      bellBtn.addEventListener('click', () => {
        if (alertBar) {
          alertBar.classList.remove('hidden');
          alertBar.style.transform = 'translateY(0)';
          alertBar.style.opacity = '1';
        }
      });
    }
  };
  initMetflixSecurityAlert();

  /* --------------------------------------------------------------------------
     2. Animação de Scroll do Header Netflix
     Transição suave de gradiente transparente para preto sólido (#141414)
     -------------------------------------------------------------------------- */
  const header = document.querySelector('.netflix-header');
  window.addEventListener('scroll', () => {
    if (window.scrollY > 30) {
      header?.classList.add('scrolled');
    } else {
      header?.classList.remove('scrolled');
    }
  }, { passive: true });

  /* --------------------------------------------------------------------------
     3. Animação da Barra de Busca Expansível
     -------------------------------------------------------------------------- */
  const searchBox = document.querySelector('.netflix-search-box');
  const searchToggle = document.querySelector('.search-toggle-btn');
  const searchInput = document.querySelector('.netflix-search-input');

  if (searchToggle && searchBox && searchInput) {
    searchToggle.addEventListener('click', (e) => {
      e.stopPropagation();
      searchBox.classList.toggle('open');
      if (searchBox.classList.contains('open')) {
        searchInput.focus();
      }
    });

    document.addEventListener('click', (e) => {
      if (!searchBox.contains(e.target) && searchInput.value.trim() === '') {
        searchBox.classList.remove('open');
      }
    });
  }

  /* --------------------------------------------------------------------------
     4. Controle de Modais (Abertura, Fechamento e Teclado ESC)
     -------------------------------------------------------------------------- */
  const addModal = document.getElementById('netflix-add-modal');
  const openAddBtns = document.querySelectorAll('.open-add-modal-btn');
  const closeAddBtn = document.getElementById('close-add-modal-btn');
  const detailModal = document.getElementById('netflix-detail-modal');

  const openAddModal = () => {
    if (addModal) {
      addModal.classList.add('active');
      document.body.style.overflow = 'hidden';
      // Foco inicial no primeiro campo
      setTimeout(() => {
        document.getElementById('form-titulo')?.focus();
      }, 100);
    }
  };

  const closeAddModal = () => {
    if (addModal) {
      addModal.classList.remove('active');
      document.body.style.overflow = '';
    }
  };

  openAddBtns.forEach(btn => btn.addEventListener('click', openAddModal));
  if (closeAddBtn) closeAddBtn.addEventListener('click', closeAddModal);

  // Fecha modais ao clicar no backdrop escuro
  if (addModal) {
    addModal.addEventListener('click', (e) => {
      if (e.target === addModal) closeAddModal();
    });
  }

  if (detailModal) {
    detailModal.addEventListener('click', (e) => {
      if (e.target === detailModal) window.closeDetailModal();
    });
  }

  // Tecla ESC para acessibilidade
  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      closeAddModal();
      window.closeDetailModal();
    }
  });

  /* --------------------------------------------------------------------------
     5. Modal de Detalhes: populado com dados reais vindos do banco (via JSON)
     A função openDetailModal(id) é chamada pelos onclick dos cards JSP.
     -------------------------------------------------------------------------- */
  window.openDetailModal = (id) => {
    if (!detailModal) return;

    const serie = seriesList.find(s => s.id === id);

    const imgEl      = document.getElementById('modal-cover-img');
    const titleEl    = document.getElementById('modal-title-text');
    const synopsisEl = document.getElementById('modal-synopsis-text');
    const anoEl      = document.getElementById('modal-ano');
    const notaEl     = document.getElementById('modal-nota');
    const generoEl   = document.getElementById('modal-genero');
    const autorEl    = document.getElementById('modal-autor');

    if (serie) {
      if (imgEl) {
        imgEl.src = serie.srcImagem || 'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=1200&q=80';
        imgEl.alt = 'Capa: ' + serie.titulo;
      }
      if (titleEl)    titleEl.textContent    = serie.titulo        || '—';
      if (synopsisEl) synopsisEl.textContent = serie.descricao     || '—';
      if (anoEl)      anoEl.textContent      = serie.anoLancamento || '—';
      if (notaEl)     notaEl.textContent     = serie.nota          || '—';
      if (generoEl)   generoEl.textContent   = serie.genero        || '—';
      if (autorEl)    autorEl.textContent    = serie.autor         || '—';
    } else {
      // id=0 ou não encontrado: exibe apresentação do sistema
      if (imgEl) {
        imgEl.src = 'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=1200&q=80';
        imgEl.alt = 'Capa da série';
      }
      if (titleEl)    titleEl.textContent    = 'REVIEWLY';
      if (synopsisEl) synopsisEl.textContent = 'As séries cadastradas no banco de dados serão exibidas aqui com sinopse, capa, nota e o nome do autor da crítica.';
      if (anoEl)      anoEl.textContent      = '2026';
      if (notaEl)     notaEl.textContent     = '—';
      if (generoEl)   generoEl.textContent   = 'Catálogo & Reviews';
      if (autorEl)    autorEl.textContent    = 'Sistema Reviewly';
    }

    detailModal.classList.add('active');
    document.body.style.overflow = 'hidden';
  };

  window.closeDetailModal = () => {
    if (detailModal) {
      detailModal.classList.remove('active');
      document.body.style.overflow = '';
    }
  };

  /* --------------------------------------------------------------------------
     6. Auto-dismiss do toast de sucesso/erro após 4 segundos
     -------------------------------------------------------------------------- */
  const toasts = document.querySelectorAll('.reviewly-toast');
  toasts.forEach(toast => {
    setTimeout(() => {
      toast.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(-20px)';
      setTimeout(() => toast.remove(), 500);
    }, 4000);
  });

});
