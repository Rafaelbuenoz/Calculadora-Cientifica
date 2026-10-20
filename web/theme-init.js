(() => {
  'use strict';
  const key = 'noxbo-theme';
  const root = document.documentElement;
  const personal = /^\/portfolio(?:\/|$)/.test(window.location.pathname) || /^\/apps\/(calculadora|estoque)(?:\/|$)/.test(window.location.pathname);
  const system = window.matchMedia('(prefers-color-scheme: dark)');
  let preference = null;
  try {
    const saved = window.localStorage.getItem(key);
    if (saved === 'light' || saved === 'dark') preference = saved;
  } catch { /* The theme still works when storage is blocked. */ }
  function apply(theme) {
    root.dataset.theme = theme;
    root.style.colorScheme = theme;
    const meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute('content', personal ? (theme === 'light' ? '#F4F1EA' : '#151B24') : (theme === 'light' ? '#FAF5ED' : '#231F1B'));
    document.querySelectorAll('[data-theme-toggle]').forEach(button => {
      const next = theme === 'dark' ? 'claro' : 'escuro';
      button.setAttribute('aria-label', `Mudar para tema ${next}`);
      button.setAttribute('title', `Mudar para tema ${next}`);
    });
    document.querySelectorAll('iframe[data-noxbo-embed]').forEach(frame => {
      frame.contentWindow?.postMessage({ type: 'noxbo-theme', theme }, window.location.origin);
    });
  }
  const embedded = window.parent !== window;
  function parentTheme() {
    if (!embedded) return null;
    try {
      const theme = window.parent.document.documentElement.dataset.theme;
      return theme === 'light' || theme === 'dark' ? theme : null;
    } catch { return null; }
  }
  const effective = () => parentTheme() || preference || (personal ? 'dark' : 'light');
  // The personal subsite has its own initial mood; an explicit choice is kept.
  apply(effective());
  function wireButtons() {
    document.querySelectorAll('[data-theme-toggle]').forEach(button => {
      button.disabled = false;
      button.addEventListener('click', () => {
        preference = root.dataset.theme === 'dark' ? 'light' : 'dark';
        apply(preference);
        try { window.localStorage.setItem(key, preference); } catch { /* No storage requirement. */ }
      });
    });
    apply(effective());
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', wireButtons, { once: true });
  else wireButtons();
  system.addEventListener('change', () => { if (!preference) apply(effective()); });
  window.addEventListener('storage', event => {
    if (event.key !== key && event.key !== null) return;
    preference = event.newValue === 'dark' || event.newValue === 'light' ? event.newValue : null;
    apply(effective());
  });
  window.addEventListener('message', event => {
    if (!embedded || event.source !== window.parent || event.origin !== window.location.origin) return;
    if (event.data?.type !== 'noxbo-theme' || !['light', 'dark'].includes(event.data.theme)) return;
    apply(event.data.theme);
  });
})();
