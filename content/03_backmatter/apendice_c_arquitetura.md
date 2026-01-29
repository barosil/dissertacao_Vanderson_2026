# Apêndice C: Detalhamento das Decisões de Arquitetura de Software

## C.1 Visão Geral da Arquitetura

### C.1.1 Arquitetura em Camadas

```
+--------------------------------------+
|     Application Layer                |
|  (CLI, Scripts, Notebooks)           |
|--------------------------------------+
                 |
+--------------------------------------+
|     Domain Layer                     |
|  (Sky, Telescope, TOD, Mapmaking)    |
|--------------------------------------+
                 |
+--------------------------------------+
|     Infrastructure Layer             |
|  (I/O, Persistence, Computation)     |
|--------------------------------------+
```

## C.2 Decisões Arquiteturais

### C.2.1 ADR-001: Linguagem Python

**Status:** Aceito

**Contexto:** Necessidade de escolher linguagem de implementação

**Decisão:** Python 3.10+

**Consequências:**
- [OK] Ecossistema científico rico
- [OK] Rápido desenvolvimento
- [OK] Boa integração com NumPy/SciPy
- [X] Performance inferior a linguagens compiladas
- Mitigação: Usar Numba para código crítico

### C.2.2 ADR-002: Formato de Dados HDF5

**Status:** Aceito

**Contexto:** Armazenamento de TOD e mapas

**Decisão:** HDF5 como formato principal

**Consequências:**
- [OK] Eficiente para grandes volumes
- [OK] Suporte a metadados
- [OK] Amplamente usado na astronomia
- [OK] Compressão integrada

### C.2.3 ADR-003: HEALPix para Mapas

**Status:** Aceito

**Contexto:** Representação de mapas do céu

**Decisão:** HEALPix (healpy)

**Consequências:**
- [OK] Equal-area pixels
- [OK] Ferramentas maduras
- [OK] Padrão na CMB community
- [X] Menos intuitivo que projeções cartesianas
- Mitigação: Fornecer ferramentas de visualização

### C.2.4 ADR-004: Configuration via YAML

**Status:** Aceito

**Decisão:** YAML para arquivos de configuração

**Consequências:**
- [OK] Legível por humanos
- [OK] Hierárquico
- [OK] Comentários suportados

### C.2.5 ADR-005: Testes com pytest

**Status:** Aceito

**Decisão:** pytest como framework de testes

**Consequências:**
- [OK] Sintaxe simples
- [OK] Fixtures poderosos
- [OK] Plugins disponíveis

## C.3 Padrões de Código

### C.3.1 Naming Conventions

```python
# Classes: PascalCase
class SkyModel:
    pass

# Funções/métodos: snake_case
def calculate_beam_size():
    pass

# Constantes: UPPER_SNAKE_CASE
SPEED_OF_LIGHT = 3e8

# Variáveis privadas: _leading_underscore
class Telescope:
    def __init__(self):
        self._internal_state = {}
```

### C.3.2 Type Hints

```python
from typing import List, Optional, Tuple

def make_map(
    tod: np.ndarray,
    pointing: np.ndarray,
    nside: int = 256
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Returns
    -------
    map : np.ndarray
    hits : np.ndarray
    """
    pass
```

### C.3.3 Error Handling

```python
# Custom exceptions
class PipelineError(Exception):
    """Base exception"""
    pass

class InvalidDataError(PipelineError):
    """Dados inválidos"""
    pass

# Uso
def process(data):
    if not validate(data):
        raise InvalidDataError(f"Invalid data shape: {data.shape}")
```

## C.4 Testing Strategy

### C.4.1 Níveis de Teste

```python
# Unit tests
def test_beam_calculation():
    beam = GaussianBeam(fwhm=0.6)
    assert beam.fwhm() == 0.6

# Integration tests
def test_tod_to_map_pipeline():
    tod = generate_test_tod()
    map = make_map(tod)
    assert map.shape == (12 * 256**2,)

# End-to-end tests
def test_full_simulation():
    config = load_config('test_config.yaml')
    sim = Simulation(config)
    results = sim.run()
    validate_results(results)
```

## C.5 Documentation Strategy

### C.5.1 Docstring Format

Seguimos NumPy style:

```python
def calculate_noise_rms(data, bandwidth, integration_time):
    """
    Calculate theoretical noise RMS.
    
    Uses radiometer equation: sigma = T_sys / sqrt(Delta_nu * Delta_t)
    
    Parameters
    ----------
    data : np.ndarray
        Input time series
    bandwidth : float
        Bandwidth in Hz
    integration_time : float
        Integration time in seconds
    
    Returns
    -------
    rms : float
        Expected RMS noise in Kelvin
    
    Examples
    --------
    >>> rms = calculate_noise_rms(data, 1e9, 1.0)
    >>> print(f"Noise: {rms:.3f} K")
    """
    pass
```

## C.6 Performance Optimization

### C.6.1 Profiling

```python
import cProfile
import pstats

# Profile code
pr = cProfile.Profile()
pr.enable()
result = expensive_function()
pr.disable()

# Analyze
stats = pstats.Stats(pr)
stats.sort_stats('cumulative')
stats.print_stats(10)
```

### C.6.2 Numba Acceleration

```python
from numba import jit

@jit(nopython=True)
def fast_binning(data, indices, n_bins):
    """Numba-accelerated binning"""
    result = np.zeros(n_bins)
    hits = np.zeros(n_bins)
    
    for i in range(len(data)):
        idx = indices[i]
        result[idx] += data[i]
        hits[idx] += 1
    
    return result / np.maximum(hits, 1)
```

## C.7 Deployment

### C.7.1 Package Structure

```
pipeline/
|-- setup.py
|-- pyproject.toml
|-- README.md
|-- LICENSE
|-- src/
|   |-- pipeline/
|       |-- __init__.py
|       |-- core/
|       |-- instruments/
|       |-- utils/
|-- tests/
|-- docs/
|-- examples/
```

### C.7.2 Installation Methods

```bash
# Development install
pip install -e .

# Production install
pip install pipeline-radioastro

# From source
git clone https://github.com/user/pipeline
cd pipeline
pip install .
```

```{seealso}
Para API completa, ver Apêndice D.
```
