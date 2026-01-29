# Capítulo 2: Radioastronomia Single Dish

## 2.1 Introdução à Radioastronomia Single Dish

Radiotelescópios Single Dish são instrumentos que utilizam uma única antena para coletar radiação eletromagnética de fontes celestes. Diferentemente de interferômetros, que combinam sinais de múltiplas antenas, telescópios Single Dish operam de forma independente, oferecendo vantagens específicas em determinados tipos de observações.

### Vantagens e Limitações

**Vantagens:**
- Sensibilidade a estruturas em larga escala
- Medidas absolutas de intensidade
- Operação mais simples e direta
- Menor custo comparado a interferômetros

**Limitações:**
- Resolução angular limitada pelo tamanho da antena
- Menor capacidade de imagem detalhada

## 2.2 O Radiotelescópio BINGO

### Características Técnicas

- **Localização**: Aguiar, Paraíba, Brasil
- **Frequência**: 960-1260 MHz (linha HI de z~0.13 a z~0.45)
- **Design**: Array de cornetas
- **Objetivo científico**: Mapeamento de BAO via Intensity Mapping

### Arquitetura do Sistema

```{mermaid}
graph TD
    A[Céu] --> B[Cornetas]
    B --> C[Frontend]
    C --> D[Backend Digital]
    D --> E[Sistema de Aquisição]
    E --> F[Armazenamento]
```

## 2.3 Tipos de Observação

### On-The-Fly Mapping
Observação contínua enquanto o telescópio se move, gerando TOD contínuo.

### Position Switching
Alternância entre posição da fonte e referência para remoção de background.

### Frequency Switching
Chaveamento rápido entre frequências para calibração.

### Raster Scan
Varredura sistemática em grade rectangular.

## 2.4 Padrões de Radiação

### Padrão de Antena (Beam Pattern)

A resposta angular de uma antena é caracterizada pelo seu padrão de radiação:

$$
P(\theta, \phi) = P_0 \cdot B(\theta, \phi)
$$

onde:
- $P_0$ é a potência no máximo do feixe
- $B(\theta, \phi)$ é o padrão normalizado
- $\theta, \phi$ são coordenadas angulares

### FWHM (Full Width at Half Maximum)

Para uma antena circular de diâmetro $D$ observando em comprimento de onda $\lambda$:

$$
\text{FWHM} \approx 1.22 \frac{\lambda}{D}
$$

## 2.5 Backends Digitais

### Espectrômetros
Instrumentos que medem a distribuição espectral do sinal recebido.

### Correlacionadores
Para sistemas com múltiplas cornetas, correlacionam sinais entre feeds.

### Processamento de Sinal
- Filtragem
- Detecção
- Integração temporal

## 2.6 Objetos do Céu

### Linha de 21 cm do Hidrogênio Neutro

A transição hiperfina do hidrogênio neutro:

$$
\nu_{\text{HI}} = 1420.405751 \text{ MHz}
$$

Redshiftada para:

$$
\nu_{\text{obs}} = \frac{\nu_{\text{HI}}}{1+z}
$$

### Contínuo de Rádio

- **Emissão synchrotron**: Elétrons relativísticos em campos magnéticos
- **Free-free**: Espalhamento elétron-íon
- **CMB**: Radiação cósmica de fundo

### Fontes Pontuais e Extensas

Modelagem adequada para diferentes tipos morfológicos.

## 2.7 Modelagem do Radiotelescópio

### Equação de Transferência Radiativa

$$
T_{\text{ant}} = \int_{\Omega} T_b(\theta, \phi) \cdot B(\theta, \phi) d\Omega
$$

onde:
- $T_{\text{ant}}$ é a temperatura de antena medida
- $T_b$ é a temperatura de brilho do céu
- $B$ é o padrão de antena normalizado
- $\Omega$ é o ângulo sólido

### Modelo de Sistema

Incluindo:
- Resposta instrumental
- Ruídos
- Ganhos
- Efeitos sistemáticos

```{seealso}
Para detalhes sobre modelagem matemática, ver Apêndice A.
```
