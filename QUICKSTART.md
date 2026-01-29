# Guia de Uso Rápido - Infraestrutura do Projeto

## ✅ Tarefas Completadas

### 1. Estrutura Básica
- ✓ Arquivos auxiliares LaTeX removidos
- ✓ `.gitignore` configurado
- ✓ `requirements.txt` criado
- ✓ `README.md` completo

### 2. Configuração Sphinx + MyST
- ✓ `conf.py` configurado para Sphinx + MyST
- ✓ Extensões MyST habilitadas
- ✓ Configuração LaTeX para modelo UFCG
- ✓ `myst.yml` criado
- ✓ `index.md` como ponto de entrada

### 3. Scripts de Processamento
- ✓ `scripts/convert_images.py` - Conversão entre formatos
- ✓ `scripts/resize_images.py` - Redimensionamento com DPI correto

### 4. Automação
- ✓ `Makefile` com todos os comandos principais
- ✓ GitHub Actions para GitHub Pages
- ✓ GitHub Actions para Curvenote

## 🚀 Começando

### Instalação

```bash
# Criar ambiente virtual
python -m venv venv
source venv/bin/activate

# Instalar dependências
make install
# ou
pip install -r requirements.txt
```

### Comandos Principais

```bash
# Ver todos os comandos disponíveis
make help

# Build HTML local
make html

# Servir documentação localmente
make serve

# Build PDF
make pdf

# Build completo (HTML + PDF)
make build

# Limpar arquivos de build
make clean

# Processar imagens
make convert-images      # Converter para WebP
make resize-images       # Redimensionar para web
make resize-print        # Preparar para impressão
make all-images          # Processar tudo
```

## 📁 Estrutura Criada

```
.
├── .github/
│   └── workflows/
│       ├── deploy-gh-pages.yml
│       └── deploy-curvenote.yml
├── scripts/
│   ├── convert_images.py
│   └── resize_images.py
├── .gitignore
├── requirements.txt
├── README.md
├── Makefile
├── conf.py (atualizado)
├── myst.yml
└── index.md
```

## 📝 Próximos Passos

### Conteúdo da Dissertação
1. Criar arquivos markdown dos capítulos em `content/02_main/`
2. Criar elementos pré-textuais em `content/01_frontmatter/`
3. Criar apêndices em `content/03_backmatter/`

### Configuração Git/GitHub
1. Inicializar repositório git (se ainda não foi feito)
2. Habilitar GitHub Pages nas configurações do repositório
3. Adicionar secret `CURVENOTE_TOKEN` para deploy no Curvenote

### Personalização
1. Adicionar logo e favicon em `content/00_images/`
2. Ajustar configurações do tema no `conf.py`
3. Personalizar templates LaTeX conforme modelo UFCG

## 🔧 Processamento de Imagens

### Converter formatos
```bash
# Converter para WebP
python scripts/convert_images.py content/00_images output/images --format webp

# Converter para PNG
python scripts/convert_images.py content/00_images output/images --format png

# Converter para EPS
python scripts/convert_images.py content/00_images output/images --format eps
```

### Redimensionar imagens
```bash
# Para impressão (600 DPI, 180mm, EPS)
python scripts/resize_images.py content/00_images output/processed --purpose print

# Para web largura completa (150 DPI, 1200px, WebP)
python scripts/resize_images.py content/00_images output/processed --purpose web-full

# Para web meia largura (150 DPI, 600px, WebP)
python scripts/resize_images.py content/00_images output/processed --purpose web-half
```

## 🌐 Deploy

### GitHub Pages
- Push para branch `main` ou `master`
- GitHub Actions fará deploy automaticamente
- Documentação estará disponível em: `https://[usuario].github.io/[repo]`

### Curvenote
- Adicionar secret `CURVENOTE_TOKEN` no repositório
- Push para branch `main` ou `master`
- Deploy automático via GitHub Actions

## 📚 Documentação de Referências

- [Sphinx Documentation](https://www.sphinx-doc.org/)
- [MyST Parser](https://myst-parser.readthedocs.io/)
- [Sphinx Book Theme](https://sphinx-book-theme.readthedocs.io/)
- [Curvenote](https://curvenote.com/docs/)
