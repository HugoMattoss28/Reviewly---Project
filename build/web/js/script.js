/**
 * ============================================================================
 * REVIEWLY - NETFLIX STREAMING UI ENGINE (JS)
 * Responsabilidade única: Animações, Modais (Detalhes / Criar / Editar) e Filtro UI
 * Todo o gerenciamento de dados e CRUD é executado pelo Java + PostgreSQL.
 * ============================================================================
 */

document.addEventListener('DOMContentLoaded', () => {

  /* --------------------------------------------------------------------------
     0. Carrega o JSON de séries embutido no JSP pelo Java (somente leitura)
     -------------------------------------------------------------------------- */
  let seriesList = [];
  try {
    const jsonEl = document.getElementById('series-data-json');
    if (jsonEl && jsonEl.textContent.trim()) {
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
     3. Barra de Busca Expansível + Filtro Instantâneo (Cards e Tabela CRUD)
     -------------------------------------------------------------------------- */
  const searchBox = document.querySelector('.netflix-search-box');
  const searchToggle = document.querySelector('.search-toggle-btn');
  const searchInput = document.getElementById('catalog-search-input') || document.querySelector('.netflix-search-input');

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

    searchInput.addEventListener('input', () => {
      const term = searchInput.value.trim().toLowerCase();

      // Filtra cards nas fileiras
      document.querySelectorAll('.netflix-card').forEach(card => {
        const title = (card.getAttribute('data-title') || '').toLowerCase();
        const genre = (card.getAttribute('data-genre') || '').toLowerCase();
        card.style.display = (!term || title.includes(term) || genre.includes(term)) ? '' : 'none';
      });

      // Filtra linhas na tabela CRUD do Admin
      document.querySelectorAll('.crud-row-item').forEach(row => {
        const title = (row.getAttribute('data-title') || '').toLowerCase();
        const genre = (row.getAttribute('data-genre') || '').toLowerCase();
        row.style.display = (!term || title.includes(term) || genre.includes(term)) ? '' : 'none';
      });
    });
  }

  /* --------------------------------------------------------------------------
     4. Controle de Modais (Criar, Editar e Detalhes)
     -------------------------------------------------------------------------- */
  const addModal = document.getElementById('netflix-add-modal');
  const openAddBtns = document.querySelectorAll('.open-add-modal-btn');
  const closeAddBtn = document.getElementById('close-add-modal-btn');
  const detailModal = document.getElementById('netflix-detail-modal');

  window.openCreateModal = () => {
    if (!addModal) return;
    const form = document.getElementById('netflix-add-form');
    if (form) form.reset();

    const acaoEl = document.getElementById('form-acao');
    const idEl = document.getElementById('form-id');
    const headingEl = document.getElementById('add-form-heading');
    const submitEl = document.getElementById('form-submit-btn');

    if (acaoEl) acaoEl.value = 'cadastrar';
    if (idEl) idEl.value = '';
    if (headingEl) headingEl.textContent = 'Cadastrar Nova Série no Banco de Dados';
    if (submitEl) submitEl.textContent = 'Salvar no Banco';

    addModal.classList.add('active');
    document.body.style.overflow = 'hidden';
    setTimeout(() => document.getElementById('form-titulo')?.focus(), 100);
  };

  window.openEditModal = (id) => {
    if (!addModal) return;
    const serie = seriesList.find(s => s.id === id);
    if (!serie) return;

    const acaoEl = document.getElementById('form-acao');
    const idEl = document.getElementById('form-id');
    const headingEl = document.getElementById('add-form-heading');
    const submitEl = document.getElementById('form-submit-btn');

    if (acaoEl) acaoEl.value = 'atualizar';
    if (idEl) idEl.value = serie.id;
    if (headingEl) headingEl.textContent = 'Editar Série #' + serie.id + ' — ' + serie.titulo;
    if (submitEl) submitEl.textContent = 'Atualizar no Banco';

    const tituloInput = document.getElementById('form-titulo');
    const generoInput = document.getElementById('form-genero');
    const anoInput = document.getElementById('form-ano');
    const notaInput = document.getElementById('form-nota');
    const autorInput = document.getElementById('form-autor');
    const imgInput = document.getElementById('form-imagem');
    const descInput = document.getElementById('form-descricao');

    if (tituloInput) tituloInput.value = serie.titulo || '';
    if (generoInput) generoInput.value = serie.genero || '';
    if (anoInput) anoInput.value = serie.anoLancamento || '';
    if (notaInput) notaInput.value = serie.nota || '';
    if (autorInput) autorInput.value = serie.autor || '';
    if (imgInput) imgInput.value = serie.srcImagem || '';
    if (descInput) descInput.value = serie.descricao || '';

    addModal.classList.add('active');
    document.body.style.overflow = 'hidden';
    setTimeout(() => tituloInput?.focus(), 100);
  };

  window.closeFormModal = () => {
    if (addModal) {
      addModal.classList.remove('active');
      document.body.style.overflow = '';
    }
  };

  openAddBtns.forEach(btn => btn.addEventListener('click', window.openCreateModal));
  if (closeAddBtn) closeAddBtn.addEventListener('click', window.closeFormModal);

  if (addModal) {
    addModal.addEventListener('click', (e) => {
      if (e.target === addModal) window.closeFormModal();
    });
  }

  if (detailModal) {
    detailModal.addEventListener('click', (e) => {
      if (e.target === detailModal) window.closeDetailModal();
    });
  }

  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      window.closeFormModal();
      window.closeDetailModal();
    }
  });

  /* --------------------------------------------------------------------------
     5. Modal de Detalhes ("Mais Informações")
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
     6. Carrossel Automático do Billboard Hero (Troca entre as séries do banco)
     -------------------------------------------------------------------------- */
  const initHeroBillboardCarousel = () => {
    const heroCard = document.getElementById('hero-billboard-card');
    const heroImg = document.getElementById('hero-backdrop-img');
    const heroTitle = document.getElementById('hero-title');
    const heroNota = document.getElementById('hero-nota');
    const heroGenero = document.getElementById('hero-genero');
    const heroAno = document.getElementById('hero-ano');
    const heroSynopsis = document.getElementById('hero-synopsis');
    const heroBtnPlay = document.getElementById('hero-btn-play');
    const heroBtnInfo = document.getElementById('hero-btn-info');
    const prevBtn = document.getElementById('hero-prev-btn');
    const nextBtn = document.getElementById('hero-next-btn');
    const counterEl = document.getElementById('hero-slide-counter');
    const infoSide = document.getElementById('hero-info-side');

    if (!heroCard || !heroImg || seriesList.length <= 1) return;

    let currentIndex = 0;
    let timer = null;
    const INTERVAL_MS = 5500;

    const showHeroSlide = (index) => {
      currentIndex = (index + seriesList.length) % seriesList.length;
      const s = seriesList[currentIndex];
      if (!s) return;

      // Efeito suave de fade out antes de atualizar os dados
      heroImg.classList.add('hero-fade-out');
      if (infoSide) infoSide.classList.add('hero-info-fade-out');

      setTimeout(() => {
        heroImg.src = s.srcImagem || 'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=1920&q=85';
        heroImg.alt = 'Capa em destaque: ' + (s.titulo || '');

        if (heroTitle) heroTitle.textContent = s.titulo || '—';
        if (heroNota) heroNota.textContent = s.nota ?? '—';
        if (heroGenero) heroGenero.textContent = s.genero || '—';
        if (heroAno) heroAno.textContent = s.anoLancamento || '—';
        if (heroSynopsis) heroSynopsis.textContent = s.descricao || '';
        if (counterEl) counterEl.textContent = (currentIndex + 1) + ' / ' + seriesList.length;

        if (heroBtnPlay) {
          heroBtnPlay.onclick = () => window.openDetailModal(s.id);
        }
        if (heroBtnInfo) {
          heroBtnInfo.onclick = () => window.openDetailModal(s.id);
        }

        heroImg.classList.remove('hero-fade-out');
        if (infoSide) infoSide.classList.remove('hero-info-fade-out');
      }, 260);
    };

    const startAutoPlay = () => {
      stopAutoPlay();
      timer = setInterval(() => {
        showHeroSlide(currentIndex + 1);
      }, INTERVAL_MS);
    };

    const stopAutoPlay = () => {
      if (timer) {
        clearInterval(timer);
        timer = null;
      }
    };

    if (prevBtn) {
      prevBtn.addEventListener('click', () => {
        showHeroSlide(currentIndex - 1);
        startAutoPlay();
      });
    }

    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        showHeroSlide(currentIndex + 1);
        startAutoPlay();
      });
    }

    // Pausa quando o usuário passa o mouse em cima do Hero e retoma ao sair
    heroCard.addEventListener('mouseenter', stopAutoPlay);
    heroCard.addEventListener('mouseleave', startAutoPlay);

    startAutoPlay();
  };
  initHeroBillboardCarousel();

  /* --------------------------------------------------------------------------
     7. Auto-dismiss do toast de sucesso/erro após 4 segundos
     -------------------------------------------------------------------------- */
  const toasts = document.querySelectorAll('.reviewly-toast');
  toasts.forEach(toast => {
    setTimeout(() => {
      toast.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(-20px)';
      setTimeout(() => toast.remove(), 500);
    }, 4500);
  });

});
