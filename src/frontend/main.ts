import './style.css';
import './editor-element';
import { getSession } from './api';

const app = document.querySelector<HTMLDivElement>('#app');

if (!app) {
  throw new Error('App root missing');
}

app.innerHTML = `
  <main class="min-h-screen bg-slate-50 p-4 text-slate-900">
    <section class="mx-auto max-w-5xl space-y-4">
      <header class="rounded bg-slate-900 p-4 text-white">
        <p class="text-sm uppercase tracking-wide text-slate-300">cloud-comment</p>
        <h1 class="text-2xl font-semibold">Markdown Notizen</h1>
      </header>
      <div class="grid gap-4 md:grid-cols-[16rem_1fr]">
        <aside class="rounded border border-slate-200 bg-white p-4">
          <h2 class="font-medium">Notizen</h2>
          <p class="mt-2 text-sm text-slate-500">Noch keine pCloud-Anbindung.</p>
          <p id="session-state" class="mt-4 text-xs text-slate-400">Session wird geladen...</p>
        </aside>
        <section class="rounded border border-slate-200 bg-white p-4">
          <markdown-editor></markdown-editor>
          <div class="mt-4 rounded border border-dashed border-slate-300 p-3 text-sm text-slate-500">Vorschau folgt.</div>
        </section>
      </div>
    </section>
  </main>
`;

getSession()
  .then((session) => {
    const state = document.querySelector('#session-state');
    if (state) state.textContent = session.authenticated ? 'Angemeldet' : 'Nicht angemeldet';
  })
  .catch(() => {
    const state = document.querySelector('#session-state');
    if (state) state.textContent = 'Backend nicht erreichbar';
  });
