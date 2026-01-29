.PHONY: help install clean build html pdf latex serve convert-images resize-images test

# Variáveis
VENV := venv
VENV_BIN := $(VENV)/bin
PYTHON := $(VENV_BIN)/python3
PIP := $(PYTHON) -m pip
SPHINX_BUILD := $(VENV_BIN)/sphinx-build
SPHINX_OPTS :=
SOURCE_DIR := .
BUILD_DIR := _build
HTML_DIR := $(BUILD_DIR)/html
LATEX_DIR := $(BUILD_DIR)/latex
SCRIPTS_DIR := scripts
IMAGES_DIR := content/00_images
OUTPUT_DIR := output

# Cores para output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help:
	@echo "$(BLUE)════════════════════════════════════════════════════════$(NC)"
	@echo "$(GREEN)Makefile - Dissertação de Mestrado$(NC)"
	@echo "$(BLUE)════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(YELLOW)Comandos disponíveis:$(NC)"
	@echo "  $(GREEN)make install$(NC)         - Instalar dependências"
	@echo "  $(GREEN)make clean$(NC)           - Limpar arquivos de build"
	@echo "  $(GREEN)make build$(NC)           - Build completo (HTML + PDF)"
	@echo "  $(GREEN)make html$(NC)            - Gerar documentação HTML"
	@echo "  $(GREEN)make pdf$(NC)             - Gerar PDF via LaTeX"
	@echo "  $(GREEN)make latex$(NC)           - Gerar arquivos LaTeX"
	@echo "  $(GREEN)make serve$(NC)           - Servir documentação HTML localmente"
	@echo "  $(GREEN)make convert-images$(NC)  - Converter imagens (PNG→WebP)"
	@echo "  $(GREEN)make resize-images$(NC)   - Redimensionar imagens para web"
	@echo "  $(GREEN)make test$(NC)            - Testar build da documentação"
	@echo ""

# Verificar se venv existe
check-venv:
	@if [ ! -d "$(VENV)" ]; then \
		echo "$(YELLOW)⚠ Virtual environment não encontrado. Criando...$(NC)"; \
		python3 -m venv $(VENV); \
		echo "$(GREEN)✓ Virtual environment criado$(NC)"; \
	fi

install: check-venv
	@echo "$(BLUE)Instalando dependências...$(NC)"
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	@echo "$(GREEN)✓ Dependências instaladas com sucesso!$(NC)"

clean:
	@echo "$(BLUE)Limpando arquivos de build...$(NC)"
	rm -rf $(BUILD_DIR)
	rm -rf $(OUTPUT_DIR)
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find Modelo_Dissertacao_UFCG -type f \( -name "*.aux" -o -name "*.idx" -o -name "*.lof" -o -name "*.lot" -o -name "*.toc" -o -name "*.log" -o -name "*.out" \) -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Arquivos limpos!$(NC)"

html: check-venv
	@echo "$(BLUE)Gerando documentação HTML...$(NC)"
	$(SPHINX_BUILD) -b html $(SPHINX_OPTS) $(SOURCE_DIR) $(HTML_DIR)
	@echo "$(GREEN)✓ HTML gerado em: $(HTML_DIR)/index.html$(NC)"

latex: check-venv
	@echo "$(BLUE)Gerando arquivos LaTeX...$(NC)"
	$(SPHINX_BUILD) -b latex $(SPHINX_OPTS) $(SOURCE_DIR) $(LATEX_DIR)
	@echo "$(YELLOW)Aplicando template UFCG (abntex2)...$(NC)"
	@sed -i 's/sphinxmanual/abntex2/g' $(LATEX_DIR)/dissertacao.tex
	@cp config_capa.sty $(LATEX_DIR)/
	@cp content/00_images/ufcg.png $(LATEX_DIR)/
	@echo "$(GREEN)✓ LaTeX gerado em: $(LATEX_DIR)$(NC)"

pdf: latex
	@echo "$(BLUE)Compilando PDF...$(NC)"
	@cd $(LATEX_DIR) && make
	@echo "$(GREEN)✓ PDF gerado em: $(LATEX_DIR)/dissertacao.pdf$(NC)"

build: html pdf
	@echo "$(GREEN)✓ Build completo finalizado!$(NC)"

serve:
	@echo "$(BLUE)Servindo documentação em http://localhost:8000$(NC)"
	@cd $(HTML_DIR) && $(PYTHON) -m http.server 8000

convert-images:
	@echo "$(BLUE)Convertendo imagens para WebP...$(NC)"
	@$(PYTHON) $(SCRIPTS_DIR)/convert_images.py $(IMAGES_DIR) $(OUTPUT_DIR)/images --format webp
	@echo "$(GREEN)✓ Imagens convertidas!$(NC)"

resize-images:
	@echo "$(BLUE)Redimensionando imagens para web...$(NC)"
	@$(PYTHON) $(SCRIPTS_DIR)/resize_images.py $(IMAGES_DIR) $(OUTPUT_DIR)/resized --purpose web-full
	@$(PYTHON) $(SCRIPTS_DIR)/resize_images.py $(IMAGES_DIR) $(OUTPUT_DIR)/resized --purpose web-half
	@echo "$(GREEN)✓ Imagens redimensionadas!$(NC)"

resize-print:
	@echo "$(BLUE)Preparando imagens para impressão...$(NC)"
	@$(PYTHON) $(SCRIPTS_DIR)/resize_images.py $(IMAGES_DIR) $(OUTPUT_DIR)/print --purpose print
	@echo "$(GREEN)✓ Imagens prontas para impressão!$(NC)"

test:
	@echo "$(BLUE)Testando build da documentação...$(NC)"
	$(SPHINX_BUILD) -b html -W --keep-going $(SOURCE_DIR) $(BUILD_DIR)/test
	@echo "$(GREEN)✓ Teste concluído!$(NC)"

# Atalhos úteis
.PHONY: quick watch all-images

quick: clean html
	@echo "$(GREEN)✓ Build rápido concluído!$(NC)"

all-images: convert-images resize-images resize-print
	@echo "$(GREEN)✓ Todos os processamentos de imagem concluídos!$(NC)"

watch:
	@echo "$(BLUE)Monitorando mudanças...$(NC)"
	@while true; do \
		$(SPHINX_BUILD) -b html $(SOURCE_DIR) $(HTML_DIR) 2>&1 | grep -v "reading sources"; \
		sleep 2; \
	done
