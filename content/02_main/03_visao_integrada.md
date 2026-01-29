# Capítulo 3: Uma Visão Integrada de Observações e Simulações

## 3.1 Introdução

Este capítulo apresenta uma visão sistêmica do processo de observação radioastronômica e sua representação em simulações. Estabelecemos um framework conceitual que conecta elementos físicos, instrumentais e computacionais.

## 3.2 O Radiotelescópio como Sistema

### 3.2.1 Componentes Físicos

```{mermaid}
graph LR
    A[Céu Astrofísico] --> B[Antena/Corneta]
    B --> C[Frontend]
    C --> D[Backend]
    D --> E[DAQ]
    E --> F[Storage]
    
    G[Controlador] --> B
    G --> C
    G --> D
    
    H[Sensores] --> G
```

### 3.2.2 Cadeia de Sinal

1. **Radiação incidente**: Fótons do céu
2. **Coleta**: Antena/corneta
3. **Amplificação**: Frontend (LNA)
4. **Conversão**: Downconverter
5. **Digitalização**: ADC
6. **Processamento**: Backend digital
7. **Armazenamento**: Dados brutos

## 3.3 Céu Astrofísico

### 3.3.1 Componentes do Céu em Rádio

**Emissão Difusa:**
- Galáxias
- Meio intergaláctico
- CMB

**Fontes Discretas:**
- Galáxias individuais
- Quasares
- Pulsares

**Foregrounds:**
- Emissão Galáctica
- Fontes extragalácticas brilhantes

### 3.3.2 Modelagem do Céu

$$
T_{\text{sky}}(\nu, \hat{n}, t) = T_{\text{signal}}(\nu, \hat{n}, t) + T_{\text{foreground}}(\nu, \hat{n}) + T_{\text{CMB}}
$$

onde:
- $\nu$ é a frequência
- $\hat{n}$ é a direção
- $t$ é o tempo

## 3.4 Frontend e Amplificação

### 3.4.1 Low Noise Amplifier (LNA)

Caracterizado por:
- Ganho: $G$ (dB)
- Temperatura de ruído: $T_{\text{sys}}$ (K)
- Largura de banda: $\Delta\nu$ (MHz)

### 3.4.2 Temperatura de Sistema

$$
T_{\text{sys}} = T_{\text{rec}} + T_{\text{sky}} + T_{\text{spillover}} + T_{\text{atmosphere}}
$$

## 3.5 Backend Digital

### 3.5.1 Espectrômetro

Divide o sinal em canais de frequência:

$$
S_i(t) = \int_{\nu_i}^{\nu_i + \Delta\nu} S(\nu, t) d\nu
$$

### 3.5.2 Integração Temporal

Redução de ruído através de integração:

$$
\sigma \propto \frac{1}{\sqrt{\Delta\nu \cdot \Delta t}}
$$

## 3.6 Dados Brutos e TOD

### 3.6.1 Time Ordered Data (TOD)

Sequência temporal de medidas:

$$
d(t_i) = [d_1(t_i), d_2(t_i), \ldots, d_N(t_i)]
$$

onde $N$ é o número de detectores/canais.

### 3.6.2 Estrutura dos Dados

```python
TOD = {
    'time': array([t_0, t_1, ..., t_n]),
    'data': array([[d_1(t_0), ..., d_N(t_0)],
                   [...],
                   [d_1(t_n), ..., d_N(t_n)]]),
    'pointing': array([[az(t_0), el(t_0)],
                       [...],
                       [az(t_n), el(t_n)]]),
    'flags': array([...])
}
```

## 3.7 Mapas do Céu

### 3.7.1 Do TOD ao Mapa

Processo de mapmaking inverte a operação de observação:

$$
\mathbf{m} = (\mathbf{A}^T \mathbf{N}^{-1} \mathbf{A})^{-1} \mathbf{A}^T \mathbf{N}^{-1} \mathbf{d}
$$

onde:
- $\mathbf{m}$ é o mapa
- $\mathbf{d}$ é o TOD
- $\mathbf{A}$ é a matriz de apontamento
- $\mathbf{N}$ é a matriz de ruído

### 3.7.2 Projeções Cartográficas

- **HEALPix**: Hierarchical Equal Area isoLatitude Pixelization
- **CAR**: Cylindrical projection
- **Gnomonic**: Para campos pequenos

## 3.8 Sistema de Controle

### 3.8.1 Controlador de Observação

Responsável por:
- Sequenciamento de comandos
- Apontamento do telescópio
- Configuração de instrumentos
- Sincronização temporal

### 3.8.2 Modos de Operação

```python
class ObservationMode:
    - on_the_fly_mapping()
    - position_switching()
    - raster_scan()
    - drift_scan()
```

## 3.9 Sensores e Dados Auxiliares

### 3.9.1 Sensores Ambientais

- Temperatura
- Pressão
- Umidade
- Vento

### 3.9.2 Dados de Housekeeping

- Estado dos sistemas
- Telemetria
- Logs de operação

### 3.9.3 Efemérides

- Posição solar
- Posição lunar
- Objetos do sistema solar

## 3.10 Modelagem de Ruídos

### 3.10.1 Ruído Térmico

$$
T_{\text{rms}} = \frac{T_{\text{sys}}}{\sqrt{\Delta\nu \cdot \Delta t}}
$$

### 3.10.2 Ruído 1/f

Presente em componentes eletrônicos:

$$
P(f) \propto \frac{1}{f^\alpha}
$$

### 3.10.3 RFI (Radio Frequency Interference)

Modelagem de interferências:
- Sinais de satélites
- Transmissores terrestres
- Eletrônica local

## 3.11 Céu Local e Efeitos Atmosféricos

### 3.11.1 Absorção Atmosférica

$$
T_{\text{atm}}(\theta_z) = T_{\text{atm}}^0 \cdot \sec(\theta_z)
$$

onde $\theta_z$ é o ângulo zenital.

### 3.11.2 Emissão Atmosférica

Principalmente devido a:
- Vapor d'água
- Oxigênio molecular
- Ozônio

### 3.11.3 Refração

Correção de apontamento devido à refração atmosférica.

## 3.12 Pipeline de Simulação vs. Observação Real

### 3.12.1 Fluxo em Observação Real

```
Céu → Telescópio → Frontend → Backend → TOD → Processamento → Mapas
```

### 3.12.2 Fluxo em Simulação

```
Modelo de Céu → Modelo de Instrumento → TOD Sintético → Processamento → Mapas Simulados
```

### 3.12.3 Validação

Comparação entre simulações e observações para:
- Validar modelos
- Testar algoritmos
- Prever desempenho

```{important}
A fidelidade da simulação depende da precisão dos modelos de cada componente do sistema.
```
