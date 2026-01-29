# Apêndice E: Mapmaking em Astrofísica e Cosmologia

## E.1 Introdução

Mapmaking é o processo de reconstruir mapas bidimensionais (ou tridimensionais) do céu a partir de dados temporais (Time Ordered Data). Este apêndice apresenta os fundamentos teóricos e práticos de algoritmos de mapmaking.

## E.2 Formulação do Problema

### E.2.1 Modelo de Observação

A relação entre dados observados e mapa do céu:

$$
\mathbf{d} = \mathbf{A} \mathbf{m} + \mathbf{n}
$$

onde:
- $\mathbf{d}$ é o vetor de dados (TOD), dimensão $N_{\text{tod}}$
- $\mathbf{m}$ é o mapa do céu, dimensão $N_{\text{pix}}$
- $\mathbf{A}$ é a matriz de apontamento, dimensão $N_{\text{tod}} \times N_{\text{pix}}$
- $\mathbf{n}$ é o ruído, dimensão $N_{\text{tod}}$

### E.2.2 Matriz de Apontamento

$$
A_{ij} = \begin{cases}
B(\theta_i - \theta_j) & \text{se pixel } j \text{ está no beam no tempo } i \\
0 & \text{caso contrário}
\end{cases}
$$

onde $B$ é o padrão de beam.

## E.3 Algoritmos de Mapmaking

### E.3.1 Naive Binning

O método mais simples: média ponderada dos dados em cada pixel.

**Algoritmo:**

$$
m_j = \frac{\sum_i A_{ij} d_i}{\sum_i A_{ij}}
$$

**Vantagens:**
- Extremamente rápido: $O(N_{\text{tod}})$
- Simples de implementar
- Baixo uso de memória

**Desvantagens:**
- Não remove correlações
- Sensível a ruído 1/f
- Não usa informação de covariância

**Implementação:**

```python
def naive_mapmaker(tod, pointing, nside):
    npix = 12 * nside**2
    map_sum = np.zeros(npix)
    hits = np.zeros(npix)
    
    for i, (data, pixel) in enumerate(zip(tod, pointing)):
        map_sum[pixel] += data
        hits[pixel] += 1
    
    map_result = map_sum / np.maximum(hits, 1)
    return map_result, hits
```

### E.3.2 Maximum Likelihood (Optimal)

Solução de máxima verossimilhança considerando ruído completo.

**Formulação:**

Minimizar $\chi^2$:

$$
\chi^2 = (\mathbf{d} - \mathbf{A}\mathbf{m})^T \mathbf{N}^{-1} (\mathbf{d} - \mathbf{A}\mathbf{m})
$$

onde $\mathbf{N}$ é a matriz de covariância do ruído.

**Solução:**

$$
\mathbf{m} = (\mathbf{A}^T \mathbf{N}^{-1} \mathbf{A})^{-1} \mathbf{A}^T \mathbf{N}^{-1} \mathbf{d}
$$

**Propriedades:**
- Estatisticamente ótimo
- Variância mínima
- Unbiased

**Desvantagens:**
- Computacionalmente caro: $O(N_{\text{pix}}^3)$
- Requer inversão de matrizes grandes
- Precisa conhecer $\mathbf{N}$

### E.3.3 Destriper

Algoritmo intermediário que remove baselines de 1/f noise.

**Modelo Estendido:**

$$
\mathbf{d} = \mathbf{A} \mathbf{m} + \mathbf{F} \mathbf{a} + \mathbf{n}_w
$$

onde:
- $\mathbf{F}$ é matriz de baselines
- $\mathbf{a}$ são os offsets de baseline
- $\mathbf{n}_w$ é ruído branco

**Solução Conjunta:**

Minimizar simultaneamente:

$$
\chi^2 = |\mathbf{d} - \mathbf{A}\mathbf{m} - \mathbf{F}\mathbf{a}|^2
$$

**Equações Normais:**

$$
\begin{pmatrix}
\mathbf{A}^T\mathbf{A} & \mathbf{A}^T\mathbf{F} \\
\mathbf{F}^T\mathbf{A} & \mathbf{F}^T\mathbf{F}
\end{pmatrix}
\begin{pmatrix}
\mathbf{m} \\
\mathbf{a}
\end{pmatrix}
=
\begin{pmatrix}
\mathbf{A}^T\mathbf{d} \\
\mathbf{F}^T\mathbf{d}
\end{pmatrix}
$$

**Algoritmo Iterativo:**

```python
def destriper(tod, pointing, baseline_length):
    # Inicializar
    map_est = naive_mapmaker(tod, pointing)
    n_baselines = len(tod) // baseline_length
    offsets = np.zeros(n_baselines)
    
    # Iterar
    for iteration in range(max_iter):
        # Calcular resíduos
        residuals = tod - project_map(map_est, pointing) - expand_offsets(offsets)
        
        # Atualizar offsets
        offsets = solve_offsets(residuals, baseline_length)
        
        # Atualizar mapa
        cleaned_tod = tod - expand_offsets(offsets)
        map_est = naive_mapmaker(cleaned_tod, pointing)
        
        # Check convergência
        if converged(residuals):
            break
    
    return map_est, offsets
```

**Complexidade:** $O(N_{\text{tod}} \times N_{\text{iter}})$

### E.3.4 Conjugate Gradient

Método iterativo para resolver sistema linear grande.

**Para sistema:** $\mathbf{A}^T\mathbf{A}\mathbf{m} = \mathbf{A}^T\mathbf{d}$

**Algoritmo:**

```python
def conjugate_gradient_mapmaker(A, d, tol=1e-6):
    # Inicializar
    m = np.zeros(npix)
    r = A.T @ d - A.T @ A @ m
    p = r.copy()
    
    for iteration in range(max_iter):
        # CG step
        Ap = A.T @ (A @ p)
        alpha = (r @ r) / (p @ Ap)
        m = m + alpha * p
        r_new = r - alpha * Ap
        
        # Check convergência
        if np.linalg.norm(r_new) < tol:
            break
        
        beta = (r_new @ r_new) / (r @ r)
        p = r_new + beta * p
        r = r_new
    
    return m
```

## E.4 Tratamento de Ruído

### E.4.1 Ruído Branco

Assumindo $\mathbf{N} = \sigma^2 \mathbf{I}$:

$$
\mathbf{m} = (\mathbf{A}^T\mathbf{A})^{-1} \mathbf{A}^T \mathbf{d}
$$

### E.4.2 Ruído Colorido

Para ruído 1/f, matriz de covariância:

$$
N_{ij} = \sigma^2 \left[\delta_{ij} + \frac{A_{\text{1/f}}}{|i-j|^\alpha}\right]
$$

**Filtros no Domínio de Fourier:**

```python
def apply_noise_filter(tod, fknee, alpha):
    # FFT
    fft_tod = np.fft.rfft(tod)
    freqs = np.fft.rfftfreq(len(tod))
    
    # Filtro
    filter = 1.0 / np.sqrt(1 + (fknee / freqs)**alpha)
    fft_filtered = fft_tod * filter
    
    # IFFT
    return np.fft.irfft(fft_filtered)
```

## E.5 Erros e Incertezas

### E.5.1 Mapa de Variância

$$
\text{Var}(m_i) = [(\mathbf{A}^T \mathbf{N}^{-1} \mathbf{A})^{-1}]_{ii}
$$

Para ruído branco:

$$
\sigma_{m,i}^2 = \frac{\sigma_d^2}{N_{\text{hits},i}}
$$

### E.5.2 Propagação de Erros

```python
def compute_map_variance(hits, noise_level):
    """Calcula variância do mapa"""
    variance = noise_level**2 / np.maximum(hits, 1)
    variance[hits == 0] = np.inf
    return variance
```

## E.6 Casos Especiais

### E.6.1 Polarização

Modelo estendido para Stokes I, Q, U:

$$
\begin{pmatrix} d \end{pmatrix} = 
\begin{pmatrix} A_I & A_Q & A_U \end{pmatrix}
\begin{pmatrix} I \\ Q \\ U \end{pmatrix}
$$

### E.6.2 Multi-frequência

Mapmaking simultâneo em múltiplas frequências:

$$
\mathbf{d}(\nu) = \mathbf{A} [\mathbf{m}_{\text{signal}}(\nu) + \mathbf{m}_{\text{fg}}(\nu)]
$$

com separação de componentes.

## E.7 Validação

### E.7.1 Testes com Dados Simulados

```python
def validate_mapmaker(mapmaker, true_map):
    # Simular observação
    pointing = generate_pointing(scan_strategy)
    tod = simulate_observation(true_map, pointing)
    tod += generate_noise(sigma)
    
    # Recuperar mapa
    recovered_map = mapmaker(tod, pointing)
    
    # Métricas
    bias = np.mean(recovered_map - true_map)
    rms = np.sqrt(np.mean((recovered_map - true_map)**2))
    correlation = np.corrcoef(recovered_map, true_map)[0, 1]
    
    return {'bias': bias, 'rms': rms, 'correlation': correlation}
```

### E.7.2 Análise de Resíduos

$$
\mathbf{r} = \mathbf{d} - \mathbf{A}\hat{\mathbf{m}}
$$

Verificar:
- Média: $\langle \mathbf{r} \rangle \approx 0$
- Variância: $\text{Var}(\mathbf{r}) \approx \sigma_n^2$
- Autocorrelação: $\langle r_i r_{i+k} \rangle \approx 0$ para $k > 0$

## E.8 Comparação de Métodos

| Método | Velocidade | Qualidade | Memória | Ruído 1/f |
|--------|-----------|-----------|---------|-----------|
| Naive | Muito Alta | Baixa | Muito Alta | FALHA |
| Destriper | Alta | Alta | Alta | OK |
| ML | Baixa | Muito Alta | Baixa | OK |
| CG | Média | Alta | Média | OK |

## E.9 Ferramentas Disponíveis

- **healpy**: Mapmaking básico
- **TOAST**: Pipeline completo CMB
- **MapCUMBA**: GPU-accelerated
- **SMAP**: Para dados Planck

```{note}
Este apêndice fornece base teórica. Implementações práticas estão em `pipeline.mapmaking`.
```
