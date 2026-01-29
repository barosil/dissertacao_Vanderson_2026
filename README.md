# Dissertação de Mestrado - Vanderson

## Desenvolvimento de uma pipeline de simulação de céu em Radioastronomia *Single Dish*: Time Ordered Data e Mapmaking

### Descrição

Este repositório contém a dissertação de mestrado sobre o desenvolvimento de uma pipeline de simulação de céu em Radioastronomia Single Dish, com foco em Time Ordered Data (TOD) e técnicas de mapmaking.

### Estrutura do Projeto

```
.
├── content/                    # Conteúdo da dissertação
│   ├── 00_images/             # Imagens e figuras
│   ├── 01_frontmatter/        # Elementos pré-textuais
│   ├── 02_main/               # Capítulos principais
│   └── 03_backmatter/         # Elementos pós-textuais
├── notebooks/                  # Jupyter notebooks
│   ├── publish/               # Notebooks prontos para publicação
│   └── work/                  # Notebooks de trabalho
├── src/                       # Código fonte da pipeline
├── review_literature/         # Revisão de literatura
├── Modelo_Dissertacao_UFCG/   # Modelo LaTeX da UFCG
└── conf.py                    # Configuração Sphinx/MyST
```

### Requisitos

- Python 3.10+
- Sphinx 6.0+
- MyST Parser 2.0+

### Instalação

```bash
# Criar ambiente virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate  # Windows

# Instalar dependências
pip install -r requirements.txt
```

### Uso

#### Construir documentação HTML

```bash
sphinx-build -b html . _build/html
```

#### Construir PDF via LaTeX

```bash
sphinx-build -b latex . _build/latex
cd _build/latex
make
```

#### Limpar arquivos de build

```bash
make clean  # ou
sphinx-build -M clean . _build
```

### Estrutura da Dissertação

1. **Introdução**
2. **Radioastronomia "Single Dish"**
   - Radiotelescópio BINGO
   - Tipos de Observação
   - Padrões de Radiação
   - Backends Digitais
   - Objetos do céu
   - Modelagem do objeto radiotelescópio
3. **Uma visão integrada de observações e simulações**
4. **Descrição da Pipeline**
5. **Resultados**
6. **Perspectivas Futuras**
7. **Conclusão**

### Scripts Úteis

- `scripts/convert_images.py` - Conversão de formatos de imagem
- `scripts/resize_images.py` - Redimensionamento para diferentes propósitos

### Contribuindo

Este é um projeto acadêmico individual. Para sugestões ou correções, abra uma issue.

### Licença

Ver arquivo `license` para detalhes.

### Autor

Vanderson

### Instituição

Universidade Federal de Campina Grande (UFCG)

---

**Status**: Em desenvolvimento
