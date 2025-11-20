#  PROYECTO LABERINTO 3D - RESUMEN EJECUTIVO

##  Información General

| Campo | Detalle |
|-------|---------|
| **Nombre del Proyecto** | Laberinto 3D |
| **Motor de Desarrollo** | Godot 4.5 |
| **Lenguaje** | GDScript |
| **Género** | Puzzle / Acción 3D |
| **Plataforma** | Windows |
| **Fecha de Desarrollo** | Noviembre 2025 |

---

##  Equipo de Desarrollo

- **Carlos Fabian Leyva Gómez**
- **Santiago Lizarraga Hopkins**
- **Daniel Pichardo Sanchez**

**Grupo**: D02  
**Materia**: Programación de Gráficos 3D  
**Institución**: CUCEI - Universidad de Guadalajara

---

## Cumplimiento de Requisitos

### Requisitos Mínimos 

| # | Requisito | Estado | Implementación |
|---|-----------|--------|----------------|
| 1 | Jugador CharacterBody3D |  | `player.gd` + `player.tscn` |
| 2 | Movimiento WASD fluido |  | Sistema de aceleración/fricción |
| 3 | Rotación cámara con mouse |  | Primera persona con límites |
| 4 | Colisiones con paredes |  | StaticBody3D + CollisionShape3D |
| 5 | Sistema de vidas (3+) |  | 3 vidas con invulnerabilidad post-daño |
| 6 | Laberinto 15x15 |  | Generación procedural |
| 7 | Múltiples rutas |  | Algoritmo Recursive Backtracking |
| 8 | Texturas aplicadas |  | StandardMaterial3D |
| 9 | 10 objetos recolectables |  | `collectible.gd` con efectos |
| 10 | Efectos al recolectar |  | Partículas CPUParticles3D |
| 11 | Contador UI |  | HUD con Labels actualizadas |
| 12 | 2 enemigos con patrullaje |  | Sistema de waypoints |
| 13 | Colisión jugador-enemigo |  | Detección física |
| 14 | Pérdida de vida |  | Daño por contacto |
| 15 | UI completa |  | Vidas, objetos, game over, victoria |

### Características Avanzadas

| # | Característica | Estado | Descripción |
|---|----------------|--------|-------------|
| 1 | Power-ups |  | 3 tipos: Velocidad, Invencibilidad, Vida |
| 2 | Efectos de partículas |  | Al recolectar objetos |
| 3 | Menú de pausa |  | Tecla P con opciones completas |
| 4 | Iluminación avanzada |  | DirectionalLight con sombras |
| 5 | Game Manager |  | Coordinación centralizada |
| 6 | Generación procedural |  | Laberinto diferente cada vez |

---

##  Arquitectura Técnica

### Estructura de Archivos

```
proyecto-final/
├── scripts/          
│   ├── player.gd
│   ├── maze_generator.gd
│   ├── enemy.gd
│   ├── collectible.gd
│   ├── powerup.gd
│   ├── game_manager.gd
│   ├── hud.gd
│   ├── main.gd
│   ├── minimap.gd
│   ├── environment_controller.gd
│   └── audio_manager.gd
├── scenes/           
│   ├── main.tscn
│   ├── player.tscn
│   ├── enemy.tscn
│   ├── collectible.tscn
│   ├── powerup.tscn
│   └── hud.tscn
├── assets/
│   ├── models/
│   ├── textures/
│   ├── audio/
│   └── materials/
└── build/
    ├── LittleMazeRunner.exe
    ├── LittleMazeRunner.console.exe
    └── LittleMazeRunner.pck
```

### Sistemas Implementados

1. **Sistema de Movimiento**
   - Física realista con CharacterBody3D
   - Aceleración y fricción
   - Sprint y salto
   - Cámara en primera persona

2. **Generación Procedural**
   - Algoritmo: Recursive Backtracking
   - Garantía de solución
   - Rutas múltiples
   - Spawn aleatorio de entidades

3. **Inteligencia Artificial**
   - Estados: PATROL, CHASE, WAIT
   - Detección de jugador por radio
   - Patrullaje por waypoints
   - Persecución activa

4. **Sistema de UI**
   - HUD con información en tiempo real
   - Pantallas de game over y victoria
   - Menú de pausa con opciones
   - Sistema de mensajes temporales

5. **Sistema de Game State**
   - Game Manager centralizado
   - Manejo de puntuación
   - Gestión de vidas
   - Condiciones de victoria/derrota

---


##  Objetivos de Aprendizaje Alcanzados

 Programación 3D en Godot  
 Física y colisiones  
 Generación procedural de contenido  
 Inteligencia artificial básica  
 Diseño de UI/UX  
 Gestión de estados de juego  
 Arquitectura modular  
 Documentación técnica

---

##  Características Visuales

- Materiales con emisión para objetos especiales
- Sombras dinámicas
- Sistema de iluminación ambiental
- Efectos de partículas
- Animaciones procedurales (rotación, flotación)
- Niebla atmosférica
- Tone mapping cinematográfico

---

##  Mecánicas de Juego

### Core Loop
1. Explorar laberinto
2. Recolectar objetos
3. Evitar/Escapar de enemigos
4. Usar power-ups estratégicamente
5. Llegar a la meta

### Desafíos
- Navegación en laberinto complejo
- Gestión de recursos (vidas)
- Timing con enemigos
- Optimización de ruta

---


##  Características Destacadas

### Lo Mejor del Proyecto

1. **Generación Procedural Robusta**
   - Cada partida es única
   - Algoritmo eficiente y confiable
   - Múltiples caminos garantizados


3. **IA de Enemigos**
   - Comportamiento creíble
   - Estados bien definidos
   - Desafío equilibrado

4. **Arquitectura Limpia**
   - Código modular
   - Bien comentado
   - Fácil de extender

5. **UI Completa**
   - Feedback claro al jugador
   - Menús funcionales
   - Información en tiempo real

---

##  Tecnologías y Técnicas Utilizadas

- **Motor**: Godot 4.5
- **Lenguaje**: GDScript
- **Física**: CharacterBody3D, StaticBody3D, Area3D
- **Algoritmos**: Recursive Backtracking para maze generation
- **Patrones**: Observer (via grupos), State Machine (IA)
- **Rendering**: Forward+ renderer de Godot 4
- **Iluminación**: DirectionalLight con shadow mapping

---


##  Lecciones Aprendidas

1. La generación procedural requiere validación cuidadosa
2. La modularidad facilita el debugging
3. El feedback visual mejora la experiencia
4. La documentación es tan importante como el código
5. Las pruebas tempranas previenen errores tarde

---

##  Aplicación de Conceptos del Curso

| Concepto | Aplicación en el Proyecto |
|----------|---------------------------|
| Transformaciones 3D | Movimiento y rotación del jugador |
| Sistemas de coordenadas | Conversión grid 2D → mundo 3D |
| Colisiones | Detección de paredes y enemigos |
| Cámaras 3D | Primera persona con controles |
| Iluminación | Sombras y ambiente |
| Materiales | Texturas y propiedades visuales |
| Física | Gravedad y movimiento realista |
| Eventos | Sistema de input y UI |

---


##  Conclusión

Este proyecto representa una implementación completa y profesional de un juego 3D, cumpliendo los requisitos académicos y superándolos con características avanzadas. El código está bien estructurado, documentado, y listo para ser extendido con mejoras futuras.


##  Información 

**Equipo**:
- Carlos Fabian Leyva Gómez
- Santiago Lizarraga Hopkins
- Daniel Pichardo Sanchez

**Curso**: Programación de Gráficos 3D  
**Grupo**: D02  
**Institución**: CUCEI - Universidad de Guadalajara  

---

