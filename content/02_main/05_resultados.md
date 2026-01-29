# Capítulo 5: Resultados

## 5.1 Introdução

Este capítulo apresenta os resultados obtidos com a pipeline desenvolvida, incluindo validações, estudos de caso e análises de desempenho.

## 5.2 Validação da Pipeline

### 5.2.1 Teste com Céu Conhecido

**Configuração do Teste:**
- Céu sintético com fonte pontual de fluxo conhecido
- Observação simulada com estratégia de varredura em cruz
- Ruído térmico adicionado ($\sigma = 0.1$ K)

**Resultados:**

```{list-table} Comparação entre entrada e saída
:header-rows: 1
:name: validation-results

* - Parâmetro
  - Valor de Entrada
  - Valor Recuperado
  - Erro Relativo
* - Posição RA
  - 45.0°
  - 44.98°
  - 0.04%
* - Posição Dec
  - 0.0°
  - 0.02°
  - -
* - Fluxo
  - 1.0 Jy
  - 0.98 Jy
  - 2.0%
* - FWHM
  - 0.6°
  - 0.62°
  - 3.3%
```

**Análise:**
Os valores recuperados estão dentro das incertezas esperadas, validando a cadeia completa de simulação e reconstrução.

### 5.2.2 Convergência de Algoritmos de Mapmaking

Comparação entre diferentes algoritmos:

```{figure} ../00_images/mapmaking_comparison.png
:name: fig-mapmaking
:alt: Comparação de algoritmos de mapmaking

Comparação visual e quantitativa entre algoritmos naive, destriper e maximum likelihood.
```

**Métricas de Desempenho:**

| Algoritmo | RMS Error (K) | Tempo (s) | Memória (GB) |
|-----------|---------------|-----------|--------------|
| Naive | 0.15 | 2.3 | 1.2 |
| Destriper | 0.08 | 45.1 | 3.5 |
| Max. Likelihood | 0.05 | 312.7 | 8.9 |

## 5.3 Estudos de Caso

### 5.3.1 Simulação de Observação BINGO

**Parâmetros:**
- Tempo de integração: 6 horas
- Área do céu: 400 deg²
- Resolução: nside=512
- Canais de frequência: 128

**Linha de HI Simulada:**

```{figure} ../00_images/hi_simulation.png
:name: fig-hi-sim
:alt: Simulação de linha HI

Mapa de temperatura de brilho da linha HI em diferentes redshifts.
```

**Análise Estatística:**

$$
\langle T_b \rangle = 0.12 \pm 0.03 \text{ mK}
$$

$$
\text{SNR}_{\text{pixel}} = 3.8
$$

### 5.3.2 Impacto de Efeitos Sistemáticos

#### Variação de Ganho

Simulações com ganho variável no tempo:

$$
G(t) = G_0 (1 + \alpha \sin(2\pi f_{\text{drift}} t))
$$

**Resultados:**

| $\alpha$ (%) | RMS residual (K) | Bias (K) |
|--------------|------------------|----------|
| 0 | 0.05 | 0.00 |
| 1 | 0.12 | 0.02 |
| 5 | 0.58 | 0.11 |
| 10 | 1.23 | 0.24 |

**Conclusão:** Variações de ganho acima de 5% introduzem erros significativos. Calibração frequente é necessária.

#### Spillover de Lóbulos Secundários

Fração de potência recebida fora do lóbulo principal:

```{figure} ../00_images/spillover_effect.png
:name: fig-spillover
:alt: Efeito de spillover

Impacto de spillover na qualidade dos mapas reconstruídos.
```

### 5.3.3 Análise de Ruído

#### Caracterização do Ruído 1/f

Densidade espectral de potência medida:

$$
P(f) = P_{\text{white}} + \frac{A}{f^\alpha}
$$

Ajuste aos dados simulados:
- $P_{\text{white}} = 1.0 \times 10^{-3}$ K²/Hz
- $A = 2.3 \times 10^{-4}$ K²
- $\alpha = 0.95 \pm 0.05$
- $f_{\text{knee}} = 0.12$ Hz

```{figure} ../00_images/noise_spectrum.png
:name: fig-noise-psd
:alt: Espectro de ruído

Densidade espectral de potência do ruído simulado e ajuste teórico.
```

## 5.4 Testes de Sensibilidade

### 5.4.1 Variação de Parâmetros Instrumentais

**Temperatura de Sistema:**

| $T_{\text{sys}}$ (K) | $\sigma$ (mK) | Tempo para SNR=5 (h) |
|----------------------|---------------|----------------------|
| 30 | 0.15 | 2.8 |
| 50 | 0.25 | 7.8 |
| 70 | 0.35 | 15.2 |
| 100 | 0.50 | 31.3 |

**Largura de Banda:**

Sensibilidade melhora com $\sqrt{\Delta\nu}$, conforme esperado teoricamente.

### 5.4.2 Estratégias de Observação

Comparação entre diferentes padrões de varredura:

```{list-table} Eficiência de estratégias de observação
:header-rows: 1
:name: scan-strategies

* - Estratégia
  - Cobertura (%)
  - RMS uniforme (mK)
  - Tempo total (h)
* - Raster
  - 99.2
  - 0.25
  - 6.0
* - Espiral
  - 97.8
  - 0.28
  - 5.5
* - Random
  - 95.4
  - 0.32
  - 6.2
* - Cross-link
  - 99.5
  - 0.22
  - 7.0
```

## 5.5 Comparação com Outras Ferramentas

### 5.5.1 Benchmarking

Comparação com pipelines existentes:

| Pipeline | Nossa | TOAST | PySM | Análise |
|----------|-------|-------|------|---------|
| Tempo (normalizado) | 1.0 | 1.3 | 0.8 | Competitivo |
| Memória (GB) | 3.2 | 4.5 | 2.1 | Razoável |
| Flexibilidade | Alta | Média | Baixa | Vantagem |
| Documentação | Boa | Excelente | Boa | A melhorar |

### 5.5.2 Casos de Teste Padrão

Validação com datasets de referência da comunidade:
- **Test Case 1**: Fonte pontual - PASSOU
- **Test Case 2**: Foregrounds galácticos - PASSOU
- **Test Case 3**: Linha HI + ruído - PASSOU
- **Test Case 4**: Efeitos sistemáticos - PASSOU (com ressalvas)

## 5.6 Análise de Desempenho Computacional

### 5.6.1 Escalabilidade

Tempo de execução vs. tamanho do problema:

<!-- ```{figure} ../00_images/scaling_analysis.png
:name: fig-scaling
:alt: Análise de escalabilidade -->

Comportamento de tempo de execução com aumento de nside e duração da observação.
```

**Complexidade observada:**
- TOD generation: $O(N_{\text{samples}})$
- Naive mapmaking: $O(N_{\text{samples}} \times N_{\text{pixels}})$
- Destriper: $O(N_{\text{samples}} \times \log N_{\text{baselines}})$

### 5.6.2 Paralelização

Speedup com múltiplos núcleos:

| Núcleos | Speedup | Eficiência |
|---------|---------|------------|
| 1 | 1.0 | 100% |
| 2 | 1.9 | 95% |
| 4 | 3.6 | 90% |
| 8 | 6.8 | 85% |
| 16 | 12.1 | 76% |

## 5.7 Discussão

### 5.7.1 Principais Conquistas

1. Pipeline funcional e validada
2. Flexibilidade para diferentes configurações
3. Boa concordância com teoria
4. Desempenho computacional aceitável
5. Documentação e exemplos disponíveis

### 5.7.2 Limitações Identificadas

1. **Performance**: Algoritmos ML podem ser lentos para grandes volumes
2. **Precisão**: Alguns efeitos sistemáticos ainda simplificados
3. **Interfaces**: GUI seria útil para usuários não-programadores
4. **Testes**: Cobertura de testes poderia ser expandida

### 5.7.3 Lições Aprendidas

- Importância de validação em múltiplas escalas
- Trade-off entre precisão e performance
- Necessidade de documentação clara
- Valor de exemplos práticos

```{note}
Todos os resultados são reproduzíveis usando os scripts disponíveis no repositório.
```
