"""
Extensão Sphinx personalizada para usar minted no LaTeX.

Como o sphinx.ext.minted foi removido do Sphinx 9.x, esta extensão
implementa a integração manual: substitui os blocos Verbatim gerados
pelo Sphinx por comandos minted na saída LaTeX.

Requer:
  - Pygments (instalado junto com Sphinx)
  - Pacote LaTeX minted (minted.sty)
  - --shell-escape na compilação pdflatex
"""

from sphinx.highlighting import PygmentsBridge
from docutils import nodes
from sphinx.util.docutils import SphinxTranslator
from sphinx.writers.latex import LaTeXTranslator


def _patch_latex_translator(app):
    """Substitui o método visit_literal_block do tradutor LaTeX
    para usar minted em vez do Verbatim do fancyvrb.
    """
    orig_visit = LaTeXTranslator.visit_literal_block

    def patched_visit(self, node):
        # Chama o método original primeiro
        orig_visit(self, node)
        # Se a saída contém um ambiente Verbatim, substitui por minted
        # Isso é feito no final da compilação, não aqui
        pass

    LaTeXTranslator.visit_literal_block = patched_visit


def _patch_highlighting(app):
    """Faz o highlight retornar código minted em vez de Verbatim."""
    orig_bridge = PygmentsBridge.get_highlight_options

    def patched_format(self, tokensource, formatter, **kwargs):
        """Converte a saída padrão do Pygments para minted."""
        import re
        from sphinx.highlighting import PygmentsBridge

        # Gera o HTML/Pygments normal primeiro
        # Depois converte para minted na geração LaTeX
        result = tokensource  # Isso é um iterator
        return result

    PygmentsBridge.get_highlight_options = patched_bridge


def _patch_visit_literal_block(app):
    """Substitui o tradutor de blocos de código literais."""
    from sphinx.writers.latex import LaTeXTranslator

    original = LaTeXTranslator.visit_literal_block

    def patched(self, node):
        # Obtém o código e a linguagem
        code = node.astext()
        lang = node.get("language", "text")
        if lang == "default":
            lang = app.config.highlight_language or "text"

        # Extrai opções de destaque de linhas
        highlight_args = node.get("highlight_args", {})
        hl_lines = highlight_args.get("hl_lines", [])

        # Constrói o ambiente minted
        minted_opts = []
        if hl_lines:
            lines_str = ",".join(str(h) for h in hl_lines)
            minted_opts.append(f"highlightlines={{{lines_str}}}")

        # Obtém opções configuradas pelo usuário
        extra_opts = getattr(app.config, "minted_options", "")
        if extra_opts:
            minted_opts_str = extra_opts
            if minted_opts:
                minted_opts_str = ",".join(
                    [extra_opts] + minted_opts
                )
        else:
            minted_opts_str = ",".join(minted_opts) if minted_opts else ""

        # Escapa caracteres especiais no código
        # O minted processa o conteúdo raw, então passamos o código direto
        # Mas precisamos escapar caracteres LaTeX especiais para evitar erros

        # Abre o ambiente minted
        if minted_opts_str:
            self.body.append(
                "\\begin{{minted}}[{}]{{{}}}\n".format(
                    minted_opts_str, lang
                )
            )
        else:
            self.body.append("\\begin{{minted}}{{{}}}\n".format(lang))

        # Escreve o código linha por linha, escapando caracteres especiais
        # Minted espera o código raw, então não escapamos LaTeX aqui
        # Mas o Pygments já gerou código formatado... Vamos usar o Pygments
        # para fazer o highlighting manualmente

        # Usa Pygments para gerar o código LaTeX colorido
        from pygments import highlight as pyg_highlight
        from pygments.lexers import get_lexer_by_name, guess_lexer
        from pygments.formatters import LatexFormatter

        try:
            lexer = get_lexer_by_name(lang, stripall=True)
        except Exception:
            try:
                lexer = guess_lexer(code)
            except Exception:
                from pygments.lexers import TextLexer
                lexer = TextLexer()

        formatter = LatexFormatter(
            style=app.config.minted_style,
            commandprefix="MintedPyg",
            linenos=False,
        )

        highlighted = pyg_highlight(code, lexer, formatter)

        # Remove o \\begin{Verbatim}...\\end{Verbatim} que o LatexFormatter
        # gera e extrai apenas o conteúdo
        highlighted = highlighted.strip()
        highlighted = highlighted.replace(r"\begin{Verbatim}", "")
        highlighted = highlighted.replace(r"\end{Verbatim}", "")

        self.body.append(highlighted)
        self.body.append("\\end{minted}\n")

    LaTeXTranslator.visit_literal_block = patched


def setup(app):
    app.add_config_value("minted_style", "default", "env")
    app.add_config_value(
        "minted_options",
        "fontsize=\\small,linenos,frame=lines,framesep=2mm",
        "env",
    )
    app.connect("builder-inited", _patch_visit_literal_block)
    return {
        "version": "1.0",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
