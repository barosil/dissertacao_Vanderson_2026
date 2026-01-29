#!/usr/bin/env bash
# Script de build da dissertação com validação

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Cores
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configurações
BUILD_DIR="_build"
HTML_DIR="${BUILD_DIR}/html"
LATEX_DIR="${BUILD_DIR}/latex"

# Funções
log_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

log_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Verificar Sphinx
if ! command -v sphinx-build &> /dev/null; then
    log_error "sphinx-build não encontrado. Execute: pip install -r requirements.txt"
    exit 1
fi

log_success "Sphinx encontrado"

# Limpar builds anteriores
echo "Limpando builds anteriores..."
rm -rf "${BUILD_DIR}" 2>/dev/null || true
log_success "Diretório _build limpo"

# Validar estrutura de conteúdo
echo "Validando estrutura de conteúdo..."
if [ -d "content" ]; then
    if [ -f "content/01_frontmatter/resumo.md" ] && [ -f "content/02_main/01_introducao.md" ]; then
        log_success "Estrutura de conteúdo validada"
    else
        log_warning "Alguns arquivos de conteúdo podem estar faltando"
    fi
else
    log_error "Diretório content/ não encontrado"
    exit 1
fi

# Build HTML
echo ""
echo "Construindo documentação HTML..."
if sphinx-build -b html -W --keep-going . "${HTML_DIR}"; then
    log_success "HTML construído com sucesso"
    log_success "Abra em: file://${PWD}/${HTML_DIR}/index.html"
else
    log_error "Erro ao construir HTML"
    exit 1
fi

# Build PDF (opcional)
if [ "$1" = "pdf" ] || [ "$1" = "all" ]; then
    echo ""
    echo "Construindo PDF via LaTeX..."
    if sphinx-build -b latex . "${LATEX_DIR}"; then
        log_success "LaTeX gerado"
        cd "${LATEX_DIR}"
        if make; then
            log_success "PDF gerado com sucesso: ${PWD}/dissertacao.pdf"
        else
            log_error "Erro ao compilar PDF com make"
        fi
        cd - > /dev/null
    else
        log_error "Erro ao gerar LaTeX"
        exit 1
    fi
fi

echo ""
log_success "Build concluído!"
