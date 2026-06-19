export class MarkdownEditorElement extends HTMLElement {
  private readonly textarea = document.createElement('textarea');

  connectedCallback(): void {
    this.textarea.className = 'min-h-72 w-full rounded border border-slate-300 p-3 font-mono text-sm';
    this.textarea.placeholder = 'Notiz in Markdown schreiben...';
    this.replaceChildren(this.textarea);
  }
}

customElements.define('markdown-editor', MarkdownEditorElement);
