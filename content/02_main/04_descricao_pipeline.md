# Capítulo 4: Descrição da Pipeline

## 4.1 Introdução

Este capítulo descreve detalhadamente a pipeline de simulação desenvolvida, incluindo decisões de design, arquitetura do software, casos de uso e exemplos de utilização.

## 4.2 Decisões de Design

### 4.2.1 Princípios Orientadores

1. **Modularidade**: Componentes independentes e reutilizáveis
2. **Extensibilidade**: Fácil adição de novos modelos e funcionalidades
3. **Testabilidade**: Componentes facilmente testáveis
4. **Performance**: Otimização para grandes volumes de dados
5. **Documentação**: Código autodocumentado e bem comentado

### 4.2.2 Escolhas Tecnológicas

**Linguagem**: Python 3.10+
- Ecossistema científico rico (NumPy, SciPy, Astropy)
- Facilidade de prototipagem
- Ampla adoção na comunidade astronômica

**Bibliotecas Principais**:
- `numpy`: Operações numéricas
- `astropy`: Funcionalidades astronômicas
- `healpy`: Manipulação de mapas HEALPix
- `scipy`: Algoritmos científicos

### 4.2.3 Paradigmas de Programação

- **Programação Orientada a Objetos** (POO)
- **Domain Driven Design** (DDD)
- **Design Patterns**: Strategy, Factory, Observer

## 4.3 Modelagem

### 4.3.1 Diagrama de Classes Geral

```{mermaid}
classDiagram
    class Telescope {
        +observe()
        +point_to()
    }
    
    class Sky {
        +get_temperature()
        +add_component()
    }
    
    class Instrument {
        +measure()
        +calibrate()
    }
    
    class TODGenerator {
        +generate()
        +add_noise()
    }
    
    class Mapper {
        +make_map()
        +deproject()
    }
    
    Telescope --> Sky
    Telescope --> Instrument
    Instrument --> TODGenerator
    TODGenerator --> Mapper
```

### 4.3.2 Domínios Principais

#### Domínio do Céu

```python
class SkyModel:
    """Representa o céu astrofísico"""
    
    def __init__(self, nside, frequency_range):
        self.nside = nside
        self.frequency_range = frequency_range
        self.components = []
    
    def add_component(self, component):
        """Adiciona componente ao modelo de céu"""
        
    def get_temperature(self, pointing, frequency):
        """Retorna temperatura em uma direção"""
```

#### Domínio do Instrumento

```python
class RadioTelescope:
    """Modelo de radiotelescópio Single Dish"""
    
    def __init__(self, config):
        self.beam = BeamModel(config['beam'])
        self.frontend = Frontend(config['frontend'])
        self.backend = Backend(config['backend'])
    
    def observe(self, sky, pointing_strategy):
        """Executa observação do céu"""
```

#### Domínio de Dados

```python
class TimeOrderedData:
    """Armazena e manipula TOD"""
    
    def __init__(self, timestamps, data, pointing):
        self.timestamps = timestamps
        self.data = data
        self.pointing = pointing
        self.flags = np.zeros_like(data, dtype=bool)
    
    def apply_calibration(self, calibration):
        """Aplica calibração aos dados"""
```

### 4.3.3 Fluxo de Dados

```{mermaid}
flowchart TD
    A[Configuração] --> B[Sky Model]
    A --> C[Telescope Model]
    B --> D[TOD Generator]
    C --> D
    D --> E[Add Noise]
    E --> F[TOD]
    F --> G[Mapmaker]
    G --> H[Sky Map]
    
    I[Pointing Strategy] --> D
```

## 4.4 Casos de Uso

### 4.4.1 Caso de Uso 1: Simulação Básica

**Objetivo**: Gerar TOD sintético de uma observação simples

```python
# Configurar céu
sky = SkyModel(nside=256)
sky.add_component(HI_line(z_range=[0.1, 0.5]))

# Configurar telescópio
telescope = BINGO_Telescope()

# Definir estratégia de observação
pointing = RasterScan(ra_range=[0, 10], dec_range=[-10, 10])

# Gerar TOD
tod = telescope.observe(sky, pointing, duration=3600)

# Salvar
tod.save('simulation_001.h5')
```

### 4.4.2 Caso de Uso 2: Teste de Algoritmo de Mapmaking

**Objetivo**: Validar algoritmo com dados conhecidos

```python
# Criar céu de teste (fonte pontual)
sky_truth = create_point_source_sky(ra=45.0, dec=0.0, flux=1.0)

# Simular observação
tod = simulate_observation(sky_truth, scan_strategy='cross')

# Adicionar ruído controlado
tod.add_noise(sigma=0.1)

# Aplicar mapmaking
recovered_map = naive_mapmaker(tod)

# Comparar com verdade
metrics = compare_maps(sky_truth, recovered_map)
print(f"RMS error: {metrics['rms']:.4f}")
```

### 4.4.3 Caso de Uso 3: Estudo de Sistemáticas

**Objetivo**: Avaliar impacto de efeitos sistemáticos

```python
# Baseline sem sistemáticas
tod_clean = simulate(sky, telescope, systematics=None)

# Com ganho variável
tod_gain = simulate(sky, telescope, systematics={'gain_drift': 0.01})

# Com spillover
tod_spill = simulate(sky, telescope, systematics={'spillover': True})

# Comparar mapas
maps = {
    'clean': make_map(tod_clean),
    'gain': make_map(tod_gain),
    'spillover': make_map(tod_spill)
}

plot_comparison(maps)
```

## 4.5 Estrutura do Código

### 4.5.1 Organização de Diretórios

```
src/
|-- core/
|   |-- telescope.py
|   |-- sky.py
|   |-- tod.py
|-- instruments/
|   |-- bingo.py
|   |-- generic.py
|-- sky_models/
|   |-- hi_line.py
|   |-- continuum.py
|   |-- foregrounds.py
|-- mapmaking/
|   |-- naive.py
|   |-- destriper.py
|   |-- maximum_likelihood.py
|-- utils/
|   |-- coordinates.py
|   |-- noise.py
|   |-- visualization.py
|-- config/
    |-- bingo_config.yaml
```

### 4.5.2 Módulos Principais

#### core/telescope.py
Define classes base para modelagem de telescópios

#### core/sky.py
Implementa modelos de céu astrofísico

#### core/tod.py
Gerencia Time Ordered Data

#### mapmaking/
Algoritmos de reconstrução de mapas

## 4.6 Usabilidade do Código

### 4.6.1 Interface de Linha de Comando

```bash
# Executar simulação com configuração padrão
python -m pipeline simulate --config configs/bingo.yaml

# Especificar parâmetros
python -m pipeline simulate \
    --sky hi_line \
    --duration 7200 \
    --output sim_001.h5

# Fazer mapa a partir de TOD
python -m pipeline map \
    --input sim_001.h5 \
    --algorithm naive \
    --output map_001.fits
```

### 4.6.2 API Python

```python
from pipeline import Simulation, SkyModel, BINGOTelescope

# Criar simulação
sim = Simulation(
    sky=SkyModel.from_template('hi_line'),
    telescope=BINGOTelescope(),
    duration=3600
)

# Executar
tod = sim.run()

# Fazer mapa
from pipeline.mapmaking import NaiveMapmaker

mapper = NaiveMapmaker(nside=256)
sky_map = mapper.make_map(tod)

# Visualizar
sky_map.plot(projection='mollweide')
```

### 4.6.3 Notebooks Jupyter

Exemplos interativos em `notebooks/`:
- `01_basic_simulation.ipynb`
- `02_mapmaking_comparison.ipynb`
- `03_systematic_effects.ipynb`
- `04_parameter_study.ipynb`

### 4.6.4 Configuração via YAML

```yaml
# config/simulation.yaml
simulation:
  name: "test_run_001"
  duration: 3600  # seconds
  
sky:
  model: "hi_line"
  nside: 256
  frequency_range: [960, 1260]  # MHz
  
telescope:
  name: "BINGO"
  location: [-7.0, -38.5, 400]  # lat, lon, alt
  beam:
    fwhm: 0.6  # degrees
    type: "gaussian"
  
  system_temperature: 50  # Kelvin
  
noise:
  thermal: true
  one_over_f:
    enabled: true
    knee: 0.1  # Hz
    alpha: 1.0
```

### 4.6.5 Testes Automatizados

```python
# tests/test_tod_generation.py
import pytest
from pipeline import SkyModel, Telescope

def test_tod_generation():
    """Testa geração básica de TOD"""
    sky = SkyModel(nside=64)
    tel = Telescope()
    
    tod = tel.observe(sky, duration=100)
    
    assert tod.shape[0] == 100
    assert not np.any(np.isnan(tod.data))

def test_noise_properties():
    """Verifica propriedades estatísticas do ruído"""
    tod = generate_noise_tod(sigma=1.0, n_samples=10000)
    
    assert np.abs(np.mean(tod)) < 0.1
    assert np.abs(np.std(tod) - 1.0) < 0.1
```

## 4.7 Documentação

### 4.7.1 Docstrings

Seguindo padrão NumPy:

```python
def make_map(tod, nside=256, method='naive'):
    """
    Cria mapa a partir de TOD.
    
    Parameters
    ----------
    tod : TimeOrderedData
        Dados de entrada
    nside : int, optional
        Resolução HEALPix (default: 256)
    method : {'naive', 'destriper', 'ml'}, optional
        Algoritmo de mapmaking (default: 'naive')
    
    Returns
    -------
    map : np.ndarray
        Mapa HEALPix do céu
    
    Examples
    --------
    >>> tod = load_tod('observation.h5')
    >>> sky_map = make_map(tod, nside=512)
    """
```

### 4.7.2 Exemplos e Tutoriais

Disponíveis em formato MyST e Jupyter Notebook.

```{seealso}
Ver Apêndice D para documentação completa da API.
```
