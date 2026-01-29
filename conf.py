# Standard library imports
from datetime import date

# -- Project configuration -----------------------------------------------------

author = "Vanderson"
year = date.today().year

copyright = f"©{year} {author}."

project = "Pipeline de Simulação de Céu em Radioastronomia Single Dish"
project_short = "Dissertação UFCG - Radioastronomia"

release = "1.0.0"

# -- Sphinx configuration -----------------------------------------------------

add_module_names = False

# Padrões de exclusão - apenas content será publicado
exclude_patterns = [
    # Diretórios
    "Modelo_Dissertacao_UFCG",
    "notebooks",
    "review_literature",
    "scripts",
    "src",
    "_build",
    "_static",
    ".vscode",
    ".github",
    ".git",
    "venv",
    "env",
    "__pycache__",
    "*.egg-info",
    "build",
    "dist",
    # Arquivos
    "README.md",
    "QUICKSTART.md",
    "LICENSE",
    "TODO.md",
    "OPTIMIZATION_SUMMARY.md",
    "Makefile",
    "setup.py",
    "pyproject.toml",
    "requirements.txt",
    ".gitignore",
    ".nojekyll",
    "conf.py",
    "myst.yml",
    "config_capa.sty",
    "build.sh",
    # Subdiretórios de content
    "content/00_images/*",
]

# Extensões essenciais para dissertação em MyST
extensions = [
    # Core
    "myst_parser",
    "sphinx.ext.intersphinx",
    "sphinx.ext.mathjax",
    # Design e apresentação
    "sphinx_book_theme",
    "sphinx_design",
    "sphinx_copybutton",
    # Numeração e estrutura
    "sphinx_multitoc_numbering",
    # Conteúdo especializado
    "sphinx_proof",
    "sphinxext.opengraph",
]

# Nota: Removidas extensões com dependências problemáticas:
# - sphinx_prolog.* (não mantida)
# - sphinx-autodoc2 (requer instalação especial)
# - sphinx.ext.imgconverter (problemas com imagemagick)
# - sphinx.ext.viewcode (não necessário para dissertação)
# - sphinx.ext.ifconfig (deprecated)
# - sphinx_exercise (substituída por sphinx_proof)

# needs_sphinx = "4.3.2"

# -- Extensions configuration --------------------------------------------------

# MyST Parser
myst_enable_extensions = [
    "amsmath",
    "attrs_inline",
    "colon_fence",
    "deflist",
    "dollarmath",
    "fieldlist",
    "html_admonition",
    "html_image",
    # "linkify",  # Removido: requer python-markdown-linkify
    "replacements",
    "smartquotes",
    "strikethrough",
    "substitution",
    "tasklist",
]

# Configurações de código e features
myst_number_code_blocks = ["python", "bash", "javascript"]  # Apenas para estes idiomas
myst_enable_checkboxes = True

# Intersphinx mapping (referências cruzadas)
intersphinx_mapping = {
    "python": ("https://docs.python.org/3/", None),
    "numpy": ("https://numpy.org/doc/stable/", None),
    "scipy": ("https://docs.scipy.org/doc/scipy/", None),
}

# Copy button configuration
copybutton_prompt_text = ">>> "
copybutton_only_copy_prompt_lines = True

# -- Options for HTML output ---------------------------------------------------

html_theme = "sphinx_book_theme"
html_title = project_short

# Caminhos
import os

templates_path = ["_templates"] if os.path.exists("_templates") else []
html_static_path = ["_static"] if os.path.exists("_static") else []

# Opções do tema
html_theme_options = {
    "search_bar_text": "Pesquisar...",
    "use_fullscreen_button": True,
    "use_repository_button": False,
    "use_issues_button": False,
    "extra_footer": f"© {year} {author}. Dissertação de Mestrado - UFCG.",
}

# Contexto HTML
html_context = {
    "default_mode": "auto",
    "display_version": True,
    "version": release,
}

# Configuração de mathjax para melhor renderização
mathjax3_config = {
    "tex": {
        "inlineMath": [["$", "$"], ["\\(", "\\)"]],
        "displayMath": [["$$", "$$"], ["\\[", "\\]"]],
    }
}

# -- Options for LaTeX output --------------------------------------------------

latex_engine = "pdflatex"

# Configurar idioma do documento
language = "pt_BR"

# Usar abntex2 ao invés de sphinxmanual (compatível com UFCG)
latex_docclass = {"manual": "abntex2"}

# Forçar uso completo do abntex2
latex_toplevel_sectioning = "chapter"

latex_elements = {
    "papersize": "a4paper",
    "pointsize": "12pt",
    "classoptions": ",openright,twoside,a4paper,english,brazil",
    "babel": "",  # abntex2 já carrega babel
    "fncychap": "",
    "preamble": r"""
        % Fontes
        \usepackage{times}
        \usepackage{lmodern}
        \usepackage{mathptmx}
        
        % Pacotes básicos
        \usepackage[utf8]{inputenc}
        \usepackage[T1]{fontenc}
        \usepackage{indentfirst}
        \usepackage{color}
        \usepackage{graphicx}
        \graphicspath{{./}{content/00_images/}}
        \usepackage{microtype}
        
        % Configuração da capa UFCG
        \usepackage{config_capa}
        
        % Metadados da dissertação
        \titulo{Pipeline de Simulação de Céu em Radioastronomia Single Dish}
        \autor{Vanderson}
        \local{Campina Grande, Paraíba, Brasil}
        \data{2026}
        \orientador{Prof. Dr. [Nome do Orientador]}
        \coorientador{Prof. Dr. [Nome do Coorientador]}
        \instituicao{%
          Universidade Federal de Campina Grande -- UFCG
          \par
          Unidade Acadêmica de Física -- UAF
          \par
          Programa de Pós-Graduação em Física}
        \tipotrabalho{Dissertação de Mestrado}
        \preambulo{Dissertação apresentada ao Programa de Pós-Graduação em Física da Universidade Federal de Campina Grande como requisito para obtenção do título de Mestre em Física.}
        
        % Configurações ABNT
        \setlength{\parindent}{1.3cm}
        \setlength{\parskip}{0.2cm}
        
        % Citações
        \usepackage[brazilian,hyperpageref]{backref}
        \usepackage[num]{abntex2cite}
        \citebrackets[]
        \renewcommand{\backrefpagesname}{Citado na(s) página(s):~}
        \renewcommand{\backref}{}
        \renewcommand*{\backrefalt}[4]{
            \ifcase #1
                Nenhuma citação no texto.
            \or
                Citado na página #2.
            \else
                Citado #1 vezes nas páginas #2.
            \fi}
    """,
    "maketitle": r"""
        \imprimircapa
        \imprimirfolhaderosto
    """,
    "tableofcontents": r"""
        \pdfbookmark[0]{\contentsname}{toc}
        \tableofcontents*
        \cleardoublepage
    """,
}

# Documentos LaTeX para gerar
latex_documents = [
    (
        "index",
        "dissertacao.tex",
        "Desenvolvimento de uma pipeline de simulação de céu em Radioastronomia Single Dish",
        "Vanderson",
        "manual",
    ),
]

# -- Options for manual page output --------------------------------------------

man_pages = [("index", "dissertacao", "Dissertação de Mestrado", [author], 1)]

# -- Options for Texinfo output ------------------------------------------------

texinfo_documents = [
    (
        "index",
        "dissertacao",
        "Dissertação de Mestrado",
        author,
        "dissertacao",
        "Pipeline de simulação de céu em Radioastronomia Single Dish",
        "Miscellaneous",
    ),
]
