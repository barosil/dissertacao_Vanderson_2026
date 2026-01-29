# Apêndice B: Domain Driven Design e Aplicação ao Caso Científico

## B.1 Introdução ao DDD

Domain Driven Design (DDD) é uma abordagem de desenvolvimento de software que coloca o domínio do problema no centro do processo de design. Para software científico, isso significa modelar diretamente os conceitos físicos e matemáticos do problema.

## B.2 Conceitos Fundamentais

### B.2.1 Ubiquitous Language

Linguagem compartilhada entre especialistas do domínio e desenvolvedores:

**Termos do Domínio de Radioastronomia:**
- Sky Temperature (Temperatura de Brilho)
- Beam Pattern (Padrão de Antena)
- Time Ordered Data (TOD)
- Mapmaking
- Pointing (Apontamento)

```python
# Código usa mesma terminologia que papers
class BeamPattern:
    def fwhm(self): ...  # Full Width at Half Maximum
    def main_lobe(self): ...
    def side_lobes(self): ...
```

### B.2.2 Bounded Contexts

Limites claros entre diferentes subdominios:

```
+-----------------+     +------------------+
|  Sky Domain     |     | Instrument Domain|
|                 |     |                  |
|  - HI emission  |     |  - Telescope     |
|  - Continuum    |---->|  - Detector      |
|  - Foregrounds  |     |  - Calibration   |
|-----------------+     |------------------+
         |                       |
         |-----------+-----------+
                     |
          +-------------------+
          |   Data Domain     |
          |                   |
          |   - TOD           |
          |   - Maps          |
          |   - Metadata      |
          |-------------------+
```

### B.2.3 Entities

Objetos com identidade única:

```python
class Observation:
    """Entity - tem identidade única"""
    
    def __init__(self, observation_id):
        self.id = observation_id  # Identidade única
        self.timestamp = datetime.now()
        self.tod = None
        self.metadata = {}
    
    def __eq__(self, other):
        return isinstance(other, Observation) and self.id == other.id
```

### B.2.4 Value Objects

Objetos sem identidade, definidos por valores:

```python
@dataclass(frozen=True)
class Coordinate:
    """Value Object - sem identidade, imutável"""
    ra: float  # Right Ascension
    dec: float  # Declination
    
    def distance_to(self, other):
        # Cálculo de distância angular
        pass

# Dois objetos com mesmos valores são iguais
coord1 = Coordinate(ra=45.0, dec=0.0)
coord2 = Coordinate(ra=45.0, dec=0.0)
assert coord1 == coord2
```

### B.2.5 Aggregates

Cluster de objetos tratados como unidade:

```python
class ObservingSession:
    """Aggregate Root"""
    
    def __init__(self, session_id):
        self.id = session_id
        self._observations = []  # Componentes do aggregate
        self._calibrations = []
    
    def add_observation(self, observation):
        """Controla acesso aos componentes"""
        if self._is_valid(observation):
            self._observations.append(observation)
    
    def get_observations(self):
        """Acesso controlado"""
        return list(self._observations)  # Cópia
```

### B.2.6 Repositories

Abstração para persistência:

```python
class ObservationRepository(ABC):
    """Interface para persistência de observações"""
    
    @abstractmethod
    def save(self, observation: Observation):
        pass
    
    @abstractmethod
    def find_by_id(self, obs_id: str) -> Observation:
        pass
    
    @abstractmethod
    def find_by_date(self, date: datetime) -> List[Observation]:
        pass

class HDF5ObservationRepository(ObservationRepository):
    """Implementação concreta em HDF5"""
    
    def save(self, observation):
        with h5py.File(self.filename, 'a') as f:
            # Salvar dados
            pass
```

### B.2.7 Services

Operações que não pertencem naturalmente a entidades:

```python
class CalibrationService:
    """Serviço de domínio para calibração"""
    
    def __init__(self, calibrator, validator):
        self.calibrator = calibrator
        self.validator = validator
    
    def calibrate_observation(self, observation, reference):
        """Operação que envolve múltiplas entidades"""
        calibration_data = self.calibrator.compute(observation, reference)
        
        if self.validator.is_valid(calibration_data):
            observation.apply_calibration(calibration_data)
            return True
        return False
```

## B.3 Aplicação ao Domínio de Radioastronomia

### B.3.1 Sky Domain

```python
# Value Objects
@dataclass(frozen=True)
class Frequency:
    value: float  # Hz
    
    def to_wavelength(self):
        return 3e8 / self.value
    
    def to_redshift(self, rest_frequency):
        return (rest_frequency / self.value) - 1

# Entity
class SkyPixel:
    def __init__(self, pixel_id, coordinate):
        self.id = pixel_id
        self.coordinate = coordinate
        self.spectrum = {}  # freq -> temperature
    
    def add_measurement(self, frequency, temperature):
        self.spectrum[frequency] = temperature

# Aggregate
class SkyMap:
    def __init__(self, nside, coordinate_system='galactic'):
        self.nside = nside
        self._pixels = {}
        self.coordinate_system = coordinate_system
    
    def set_pixel_value(self, pixel_id, value):
        if pixel_id not in self._pixels:
            self._pixels[pixel_id] = SkyPixel(pixel_id, ...)
        self._pixels[pixel_id].add_measurement(...)
```

### B.3.2 Instrument Domain

```python
# Value Objects
@dataclass(frozen=True)
class BeamParameters:
    fwhm: float  # degrees
    efficiency: float  # 0-1
    sidelobe_level: float  # dB

# Entity
class Telescope:
    def __init__(self, telescope_id, name):
        self.id = telescope_id
        self.name = name
        self.location = None
        self.beam = None
        self._status = TelescopeStatus.IDLE
    
    def configure_beam(self, beam_params: BeamParameters):
        self.beam = BeamModel(beam_params)
    
    def can_observe(self):
        return self._status == TelescopeStatus.READY

# Service
class PointingService:
    """Serviço para cálculo de apontamento"""
    
    def compute_pointing(self, target, telescope, time):
        """Calcula coordenadas de apontamento"""
        # Correções de refração, precessão, etc.
        pass
    
    def is_observable(self, target, telescope, time):
        """Verifica se alvo é observável"""
        pass
```

### B.3.3 Data Domain

```python
# Value Object
@dataclass(frozen=True)
class TimeStamp:
    mjd: float  # Modified Julian Date
    
    def to_datetime(self):
        return astropy.time.Time(self.mjd, format='mjd').datetime

# Entity
class TODSegment:
    def __init__(self, segment_id):
        self.id = segment_id
        self.timestamps = []
        self.data = None
        self.pointing = None
        self.flags = None
    
    def is_valid(self):
        return not np.any(self.flags)

# Aggregate
class TimeOrderedData:
    """Aggregate root para TOD"""
    
    def __init__(self, tod_id, observation_id):
        self.id = tod_id
        self.observation_id = observation_id
        self._segments = []
        self._metadata = {}
    
    def add_segment(self, segment: TODSegment):
        if self._is_continuous(segment):
            self._segments.append(segment)
        else:
            raise ValueError("Non-continuous segment")
    
    def get_full_tod(self):
        """Concatena todos os segmentos"""
        return np.concatenate([s.data for s in self._segments])
```

## B.4 Domain Events

Eventos significativos no domínio:

```python
@dataclass
class ObservationStarted:
    """Evento de domínio"""
    observation_id: str
    timestamp: datetime
    telescope_id: str
    target: Coordinate

@dataclass
class CalibrationCompleted:
    observation_id: str
    calibration_quality: float
    timestamp: datetime

class EventDispatcher:
    """Publica eventos de domínio"""
    
    def __init__(self):
        self._handlers = defaultdict(list)
    
    def subscribe(self, event_type, handler):
        self._handlers[event_type].append(handler)
    
    def publish(self, event):
        for handler in self._handlers[type(event)]:
            handler(event)

# Uso
dispatcher = EventDispatcher()

def log_observation(event: ObservationStarted):
    logger.info(f"Observation {event.observation_id} started")

dispatcher.subscribe(ObservationStarted, log_observation)
dispatcher.publish(ObservationStarted(...))
```

## B.5 Specifications

Encapsulamento de regras de negócio:

```python
class Specification(ABC):
    @abstractmethod
    def is_satisfied_by(self, candidate):
        pass
    
    def and_(self, other):
        return AndSpecification(self, other)
    
    def or_(self, other):
        return OrSpecification(self, other)

class ObservableNow(Specification):
    """Especificação: alvo é observável agora?"""
    
    def __init__(self, telescope, time):
        self.telescope = telescope
        self.time = time
    
    def is_satisfied_by(self, target):
        pointing = compute_pointing(target, self.telescope, self.time)
        return pointing.elevation > 10  # degrees

class HighQualityData(Specification):
    """Especificação: dados têm qualidade suficiente?"""
    
    def is_satisfied_by(self, tod):
        return tod.signal_to_noise > 5 and tod.rfi_fraction < 0.1

# Uso
spec = ObservableNow(telescope, datetime.now()).and_(
       HighQualityData())

if spec.is_satisfied_by(observation):
    process(observation)
```

## B.6 Factories

Criação complexa de objetos de domínio:

```python
class ObservationFactory:
    """Factory para criar observações completas"""
    
    @staticmethod
    def create_scheduled_observation(
        target, 
        telescope, 
        duration, 
        strategy='raster'
    ):
        # Computar parâmetros
        pointing = PointingService.compute_path(target, strategy)
        config = InstrumentConfigurator.for_target(target, telescope)
        
        # Criar observação
        obs = Observation(
            id=generate_id(),
            target=target,
            telescope=telescope,
            duration=duration
        )
        obs.set_pointing_strategy(pointing)
        obs.set_instrument_config(config)
        
        return obs
```

## B.7 Benefícios para Software Científico

### B.7.1 Modelagem Próxima da Realidade

Código reflete diretamente conceitos físicos:

```python
# Fórmula física
# T_ant = integral[ T_sky(Omega) * B(Omega) dOmega ]

# Código correspondente
def antenna_temperature(sky, beam):
    return integrate(
        lambda omega: sky.temperature(omega) * beam.response(omega),
        omega_range
    )
```

### B.7.2 Comunicação Clara

Cientistas podem ler e entender o código:

```python
# [FALHA] Código obscuro
def f(x, y, z):
    return np.sum(x * y) / z

# [OK] Código auto-explicativo
def calculate_weighted_mean_temperature(
    temperatures: np.ndarray,
    weights: np.ndarray,
    normalization: float
) -> float:
    """
    Calcula temperatura média ponderada.
    
    T_mean = sum(T_i * w_i) / W_total
    """
    return np.sum(temperatures * weights) / normalization
```

### B.7.3 Validação de Domínio

Regras físicas garantidas por design:

```python
class Frequency:
    def __init__(self, value_hz):
        if value_hz <= 0:
            raise ValueError("Frequency must be positive")
        self.value = value_hz
    
    def doppler_shift(self, velocity):
        """Aplica efeito Doppler"""
        if abs(velocity) >= 3e8:
            raise ValueError("Velocity cannot exceed c")
        
        beta = velocity / 3e8
        return Frequency(self.value * sqrt((1 - beta) / (1 + beta)))
```

### B.7.4 Evolução Controlada

Mudanças científicas localizadas no domínio:

```python
# Atualizar modelo físico sem impactar resto do código
class HILineModel:
    def temperature(self, z, coords):
        # V1: modelo simples
        # return simple_model(z, coords)
        
        # V2: modelo refinado
        return refined_model_with_corrections(z, coords)
```

## B.8 Anti-patterns a Evitar

### B.8.1 Anemic Domain Model

[FALHA] Entidades sem comportamento:

```python
class Observation:
    def __init__(self):
        self.data = None
        self.flags = None

# Lógica fora da entidade
def process_observation(obs):
    if any(obs.flags):
        clean_data(obs.data)
```

[OK] Rich domain model:

```python
class Observation:
    def is_flagged(self):
        return np.any(self.flags)
    
    def clean(self):
        if self.is_flagged():
            self._apply_cleaning_algorithm()
```

### B.8.2 Domain Logic em Camadas Erradas

[FALHA] Lógica de domínio na UI ou persistência

[OK] Lógica concentrada em domain objects

```{seealso}
Para detalhes de implementação, ver Apêndice C sobre Decisões de Arquitetura.
```
