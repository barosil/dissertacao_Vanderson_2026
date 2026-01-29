# Apêndice D: API Reference

## D.1 Core Modules

### D.1.1 pipeline.core.sky

#### SkyModel

```python
class SkyModel:
    """
    Representa modelo do céu astrofísico.
    
    Parameters
    ----------
    nside : int
        HEALPix resolution parameter
    frequency_range : tuple
        (f_min, f_max) em Hz
    
    Attributes
    ----------
    components : list
        Lista de componentes do céu
    """
    
    def __init__(self, nside=256, frequency_range=None):
        pass
    
    def add_component(self, component):
        """Adiciona componente ao modelo"""
        pass
    
    def get_temperature(self, pointing, frequency):
        """
        Retorna temperatura em direção específica.
        
        Parameters
        ----------
        pointing : tuple
            (theta, phi) em radianos
        frequency : float
            Frequência em Hz
        
        Returns
        -------
        temperature : float
            Temperatura de brilho em K
        """
        pass
```

#### HILine

```python
class HILine(SkyComponent):
    """Componente de linha HI do céu"""
    
    def __init__(self, z_range, cosmology='Planck18'):
        pass
    
    def get_temperature(self, coords, frequency):
        pass
```

### D.1.2 pipeline.core.telescope

#### Telescope

```python
class Telescope:
    """Modelo de radiotelescópio Single Dish"""
    
    def __init__(self, config):
        """
        Parameters
        ----------
        config : dict
            Configuração do telescópio
            - name : str
            - location : tuple (lat, lon, alt)
            - beam : dict
            - system_temperature : float
        """
        pass
    
    def observe(self, sky, pointing_strategy, duration):
        """
        Executa observação.
        
        Parameters
        ----------
        sky : SkyModel
        pointing_strategy : PointingStrategy
        duration : float
            Tempo em segundos
        
        Returns
        -------
        tod : TimeOrderedData
        """
        pass
```

### D.1.3 pipeline.core.tod

#### TimeOrderedData

```python
class TimeOrderedData:
    """Armazena e manipula TOD"""
    
    def __init__(self, timestamps, data, pointing, metadata=None):
        """
        Parameters
        ----------
        timestamps : np.ndarray
            Array 1D de timestamps (MJD)
        data : np.ndarray
            Array 2D (n_times, n_detectors)
        pointing : np.ndarray
            Array 2D (n_times, 2) com (az, el)
        metadata : dict, optional
        """
        pass
    
    def apply_calibration(self, calibration):
        """Aplica calibração"""
        pass
    
    def flag_data(self, flags):
        """Marca dados ruins"""
        pass
    
    def save(self, filename):
        """Salva em HDF5"""
        pass
    
    @classmethod
    def load(cls, filename):
        """Carrega de HDF5"""
        pass
```

## D.2 Mapmaking Module

### D.2.1 pipeline.mapmaking.naive

```python
def naive_mapmaker(tod, nside=256, coordinate_system='galactic'):
    """
    Mapmaking ingênuo (binning simples).
    
    Parameters
    ----------
    tod : TimeOrderedData
    nside : int
        Resolução HEALPix
    coordinate_system : str
        'galactic' ou 'equatorial'
    
    Returns
    -------
    map : np.ndarray
        Mapa HEALPix
    hits : np.ndarray
        Mapa de hits
    """
    pass
```

### D.2.2 pipeline.mapmaking.destriper

```python
class Destriper:
    """
    Algoritmo destriper para mapmaking.
    
    Remove baselines de 1/f noise.
    """
    
    def __init__(self, baseline_length=100):
        """
        Parameters
        ----------
        baseline_length : int
            Comprimento de baseline em samples
        """
        pass
    
    def make_map(self, tod, nside=256):
        """
        Cria mapa com destriping.
        
        Returns
        -------
        map : np.ndarray
        baselines : np.ndarray
        chi2 : float
        """
        pass
```

## D.3 Instruments Module

### D.3.1 pipeline.instruments.bingo

```python
class BINGOTelescope(Telescope):
    """Configuração específica do BINGO"""
    
    @classmethod
    def default_config(cls):
        """Retorna configuração padrão do BINGO"""
        return {
            'name': 'BINGO',
            'location': (-7.0, -38.5, 400),
            'n_feeds': 28,
            'frequency_range': (960e6, 1260e6),
            'system_temperature': 50,
            'beam': {
                'fwhm': 0.6,
                'type': 'gaussian'
            }
        }
```

## D.4 Sky Models Module

### D.4.1 pipeline.sky_models.hi_line

```python
def create_hi_sky(nside=256, z_range=(0.1, 0.5), model='lognormal'):
    """
    Cria modelo de céu com emissão HI.
    
    Parameters
    ----------
    nside : int
    z_range : tuple
    model : str
        'lognormal', 'nbody', ou 'simple'
    
    Returns
    -------
    sky : SkyModel
    """
    pass
```

### D.4.2 pipeline.sky_models.foregrounds

```python
def add_galactic_foregrounds(sky, components=('synchrotron', 'free-free', 'dust')):
    """
    Adiciona foregrounds galácticos.
    
    Parameters
    ----------
    sky : SkyModel
    components : tuple
        Componentes a incluir
    """
    pass
```

## D.5 Utils Module

### D.5.1 pipeline.utils.coordinates

```python
def galactic_to_equatorial(l, b):
    """
    Converte coordenadas galácticas para equatoriais.
    
    Parameters
    ----------
    l : float or np.ndarray
        Longitude galáctica (graus)
    b : float or np.ndarray
        Latitude galáctica (graus)
    
    Returns
    -------
    ra : float or np.ndarray
    dec : float or np.ndarray
    """
    pass

def healpix_to_sky_coords(ipix, nside, coord_system='galactic'):
    """Converte índice HEALPix para coordenadas"""
    pass
```

### D.5.2 pipeline.utils.noise

```python
def generate_white_noise(n_samples, sigma=1.0):
    """Gera ruído branco"""
    pass

def generate_one_over_f_noise(n_samples, fknee=0.1, alpha=1.0, fsample=1.0):
    """
    Gera ruído 1/f.
    
    Parameters
    ----------
    n_samples : int
    fknee : float
        Knee frequency em Hz
    alpha : float
        Espectro slope
    fsample : float
        Sample rate em Hz
    """
    pass
```

### D.5.3 pipeline.utils.visualization

```python
def plot_map(map_data, nside, title=None, projection='mollweide', **kwargs):
    """
    Plota mapa HEALPix.
    
    Parameters
    ----------
    map_data : np.ndarray
    nside : int
    title : str
    projection : str
        'mollweide', 'cartesian', 'orthographic'
    **kwargs : dict
        Argumentos para healpy.mollview
    """
    pass

def plot_tod(tod, detector=0, show_flags=True):
    """Plota TOD de um detector"""
    pass
```

## D.6 Configuration

### D.6.1 Exemplo de Arquivo de Configuração

```yaml
# config.yaml
simulation:
  name: "my_simulation"
  duration: 3600
  output_dir: "./output"

sky:
  model: "hi_line"
  nside: 256
  z_range: [0.1, 0.5]
  foregrounds:
    - synchrotron
    - free-free

telescope:
  type: "BINGO"
  custom_params:
    system_temperature: 55

observation:
  strategy: "raster"
  scan_speed: 1.0  # deg/s
  
noise:
  thermal: true
  one_over_f:
    enabled: true
    fknee: 0.1
    alpha: 1.0

mapmaking:
  algorithm: "destriper"
  nside: 256
  baseline_length: 100
```

### D.6.2 Carregando Configuração

```python
from pipeline.config import load_config

config = load_config('config.yaml')
sim = Simulation.from_config(config)
results = sim.run()
```

## D.7 CLI Reference

```bash
# Ver versão
pipeline --version

# Ajuda
pipeline --help

# Executar simulação
pipeline simulate --config config.yaml --output results/

# Fazer mapa
pipeline map --input tod.h5 --algorithm destriper --output map.fits

# Visualizar
pipeline view --map map.fits --projection mollweide

# Validar configuração
pipeline validate-config config.yaml
```

## D.8 Exceções

```
# Hierarquia de exceções
PipelineError
|-- ConfigurationError
|-- DataError
|   |-- InvalidDataError
|   |-- CorruptedDataError
|-- ComputationError
|   |-- ConvergenceError
|   |-- NumericalError
|-- IOError
    |-- FileNotFoundError
    |-- InvalidFormatError
```

```{note}
Esta é uma API de referência. Para exemplos práticos, ver notebooks em `examples/`.
```
