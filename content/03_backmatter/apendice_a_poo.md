# Apêndice A: Princípios de Programação Orientada a Objetos

## A.1 Introdução

Este apêndice apresenta os conceitos fundamentais de Programação Orientada a Objetos (POO) e sua aplicação no desenvolvimento da pipeline de simulação.

## A.2 Conceitos Fundamentais

### A.2.1 Classes e Objetos

**Classe**: Modelo ou blueprint que define propriedades e comportamentos

```python
class Telescope:
    """Representa um radiotelescópio"""
    
    def __init__(self, name, diameter):
        self.name = name
        self.diameter = diameter
    
    def calculate_beam_size(self, frequency):
        """Calcula FWHM do beam"""
        wavelength = 3e8 / frequency
        return 1.22 * wavelength / self.diameter
```

**Objeto**: Instância específica de uma classe

```python
bingo = Telescope(name="BINGO", diameter=40.0)
fwhm = bingo.calculate_beam_size(frequency=1.1e9)
```

### A.2.2 Encapsulamento

Ocultação de detalhes internos e exposição de interface pública:

```python
class DataBuffer:
    def __init__(self, size):
        self._data = np.zeros(size)  # Atributo "privado"
        self._index = 0
    
    def add(self, value):
        """Interface pública para adicionar dados"""
        self._data[self._index] = value
        self._index = (self._index + 1) % len(self._data)
    
    def get_mean(self):
        """Interface pública para obter média"""
        return np.mean(self._data)
```

### A.2.3 Herança

Reutilização e extensão de código através de hierarquia:

```python
class Instrument:
    """Classe base para instrumentos"""
    
    def calibrate(self):
        raise NotImplementedError
    
    def measure(self, source):
        raise NotImplementedError

class Spectrometer(Instrument):
    """Espectrômetro - herda de Instrument"""
    
    def __init__(self, n_channels, bandwidth):
        self.n_channels = n_channels
        self.bandwidth = bandwidth
    
    def calibrate(self):
        # Implementação específica
        pass
    
    def measure(self, source):
        # Implementação específica
        pass
```

### A.2.4 Polimorfismo

Diferentes implementações de mesma interface:

```python
class Mapper:
    def make_map(self, tod):
        raise NotImplementedError

class NaiveMapper(Mapper):
    def make_map(self, tod):
        # Implementação naive
        return naive_binning(tod)

class DestriperMapper(Mapper):
    def make_map(self, tod):
        # Implementação destriper
        return destriper_algorithm(tod)

# Uso polimórfico
mappers = [NaiveMapper(), DestriperMapper()]
for mapper in mappers:
    result = mapper.make_map(tod)  # Mesma interface, diferentes algoritmos
```

## A.3 Princípios SOLID

### A.3.1 Single Responsibility Principle

Cada classe deve ter uma única responsabilidade:

```python
# [FALHA] Classe com múltiplas responsabilidades
class DataProcessor:
    def load_data(self): ...
    def process(self): ...
    def save_results(self): ...
    def plot(self): ...

# [OK] Responsabilidades separadas
class DataLoader:
    def load(self, filename): ...

class DataProcessor:
    def process(self, data): ...

class DataWriter:
    def save(self, data, filename): ...

class DataVisualizer:
    def plot(self, data): ...
```

### A.3.2 Open/Closed Principle

Aberto para extensão, fechado para modificação:

```python
# [OK] Extensível sem modificação
class NoiseModel:
    def generate(self, size):
        raise NotImplementedError

class WhiteNoise(NoiseModel):
    def generate(self, size):
        return np.random.randn(size)

class PinkNoise(NoiseModel):
    def generate(self, size):
        # Implementação 1/f noise
        pass

# Adicionar novo tipo sem modificar existentes
class BrownianNoise(NoiseModel):
    def generate(self, size):
        # Implementação noise browniano
        pass
```

### A.3.3 Liskov Substitution Principle

Subclasses devem ser substituíveis por suas classes base:

```python
def process_tod(tod, mapper: Mapper):
    """Aceita qualquer Mapper"""
    return mapper.make_map(tod)

# Todas as implementações funcionam
process_tod(tod, NaiveMapper())
process_tod(tod, DestriperMapper())
process_tod(tod, MLMapper())
```

### A.3.4 Interface Segregation Principle

Muitas interfaces específicas são melhores que uma geral:

```python
# Interface específica para observadores
class Observable:
    def observe(self, sky): ...

# Interface específica para calibráveis
class Calibratable:
    def calibrate(self, calibrator): ...

# Classe implementa apenas o necessário
class SimpleDetector(Observable):
    def observe(self, sky):
        # Implementação
        pass

class PrecisionDetector(Observable, Calibratable):
    def observe(self, sky):
        pass
    
    def calibrate(self, calibrator):
        pass
```

### A.3.5 Dependency Inversion Principle

Depender de abstrações, não de concretizações:

```python
# [FALHA] Dependência concreta
class Simulation:
    def __init__(self):
        self.telescope = BINGOTelescope()  # Acoplado
    
# [OK] Dependência abstrata
class Simulation:
    def __init__(self, telescope: Telescope):
        self.telescope = telescope  # Aceita qualquer Telescope
    
# Uso flexível
sim1 = Simulation(BINGOTelescope())
sim2 = Simulation(GBTelescope())
```

## A.4 Design Patterns Aplicados

### A.4.1 Factory Pattern

Criação de objetos sem especificar classe exata:

```python
class TelescopeFactory:
    @staticmethod
    def create(telescope_type, config):
        if telescope_type == "BINGO":
            return BINGOTelescope(config)
        elif telescope_type == "GBT":
            return GBTelescope(config)
        else:
            raise ValueError(f"Unknown telescope: {telescope_type}")

# Uso
telescope = TelescopeFactory.create("BINGO", config)
```

### A.4.2 Strategy Pattern

Algoritmos intercambiáveis:

```python
class MapmakingContext:
    def __init__(self, strategy: Mapper):
        self.strategy = strategy
    
    def execute(self, tod):
        return self.strategy.make_map(tod)

# Trocar estratégia em runtime
context = MapmakingContext(NaiveMapper())
map1 = context.execute(tod)

context.strategy = DestriperMapper()
map2 = context.execute(tod)
```

### A.4.3 Observer Pattern

Notificação de mudanças de estado:

```python
class Observable:
    def __init__(self):
        self._observers = []
    
    def attach(self, observer):
        self._observers.append(observer)
    
    def notify(self, event):
        for observer in self._observers:
            observer.update(event)

class Simulation(Observable):
    def run(self):
        self.notify("simulation_started")
        # ... processamento ...
        self.notify("simulation_completed")

class ProgressLogger:
    def update(self, event):
        print(f"Event: {event}")

# Uso
sim = Simulation()
sim.attach(ProgressLogger())
sim.run()
```

### A.4.4 Singleton Pattern

Garantir única instância:

```python
class ConfigurationManager:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._config = {}
        return cls._instance
    
    def set(self, key, value):
        self._config[key] = value
    
    def get(self, key):
        return self._config.get(key)

# Sempre mesma instância
config1 = ConfigurationManager()
config2 = ConfigurationManager()
assert config1 is config2
```

## A.5 Composição vs. Herança

### A.5.1 Quando Usar Herança

Relação "é um" (is-a):

```python
class Mapper:  # Base
    pass

class NaiveMapper(Mapper):  # NaiveMapper É UM Mapper
    pass
```

### A.5.2 Quando Usar Composição

Relação "tem um" (has-a):

```python
class Telescope:
    def __init__(self):
        self.beam = BeamModel()      # Telescope TEM UM beam
        self.receiver = Receiver()   # Telescope TEM UM receiver
        self.backend = Backend()     # Telescope TEM UM backend
```

**Vantagem da composição**: Maior flexibilidade

```python
# Trocar componentes facilmente
telescope.beam = GaussianBeam()
telescope.beam = AiryBeam()
```

## A.6 Aplicação na Pipeline

### A.6.1 Hierarquia de Classes

```
Observable (ABC)
|-- SkyModel
|-- Instrument
|   |-- Telescope
|   |   |-- BINGOTelescope
|   |   |-- GBTelescope
|   |-- Spectrometer
|-- DataProcessor
    |-- TODProcessor
    |-- Mapper
        |-- NaiveMapper
        |-- DestriperMapper
        |-- MLMapper
```

### A.6.2 Exemplo Completo

```python
from abc import ABC, abstractmethod

class SkyComponent(ABC):
    """Interface para componentes do céu"""
    
    @abstractmethod
    def get_temperature(self, coords, frequency):
        pass

class HILine(SkyComponent):
    def __init__(self, redshift_range):
        self.redshift_range = redshift_range
    
    def get_temperature(self, coords, frequency):
        # Implementação
        return temperature

class SkyModel:
    def __init__(self):
        self.components = []
    
    def add_component(self, component: SkyComponent):
        self.components.append(component)
    
    def get_total_temperature(self, coords, frequency):
        return sum(c.get_temperature(coords, frequency) 
                   for c in self.components)

# Uso
sky = SkyModel()
sky.add_component(HILine([0.1, 0.5]))
sky.add_component(Continuum())
temp = sky.get_total_temperature((0, 0), 1.1e9)
```

## A.7 Benefícios para Código Científico

1. **Modularidade**: Componentes reutilizáveis
2. **Manutenibilidade**: Mudanças localizadas
3. **Testabilidade**: Testes unitários facilitados
4. **Colaboração**: Interface clara entre módulos
5. **Extensibilidade**: Novos features sem quebrar existentes

```{seealso}
Para aplicação específica em contexto científico, ver Apêndice B sobre Domain Driven Design.
```
