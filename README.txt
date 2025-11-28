================================================================================
                        LABERINTO 3D - PROYECTO FINAL
================================================================================

INFORMACIÓN DEL EQUIPO
================================================================================
Estudiantes:
  - Carlos Fabian Leyva Gómez
  - Santiago Lizarraga Hopkins  
  - Daniel Pichardo Sanchez

Sección: D02
Materia: Programación de Gráficos 3D
Fecha: Noviembre 2025

Motor: Godot 4.5


CONTROLES DEL JUEGO
================================================================================

MENU PRINCIPAL:
  Click en botones para navegar
  - Iniciar Juego: Comienza una nueva partida
  - Salir: Cierra el juego

MOVIMIENTO:
  W - Mover hacia adelante
  A - Mover hacia la izquierda
  S - Mover hacia atrás
  D - Mover hacia la derecha
  
  Shift - Correr (sprint)
  Espacio - Saltar
  
  Mouse - Rotar cámara
    Movimiento horizontal del mouse: rotar al jugador
    Movimiento vertical del mouse: inclinar cámara arriba/abajo

INTERFAZ:
  P - Pausar/Despausar el juego
  ESC - Liberar/capturar el cursor del mouse

MENUS EN JUEGO:
  Menú de Pausa (Presionar P):
    - Resume: Continuar jugando
    - Restart: Reiniciar nivel
    - Main Menu: Volver al menú principal
    - Quit: Salir del juego
  
  Pantallas de Game Over/Victoria:
    - Restart / Play Again: Reiniciar el nivel
    - Main Menu: Volver al menú principal
    - Quit: Salir del juego


CARACTERÍSTICAS IMPLEMENTADAS
================================================================================

REQUISITOS MINIMOS

1. Jugador (CharacterBody3D):
   - Movimiento fluido en todas direcciones (WASD)
   - Rotación de cámara con mouse (primera persona)
   - Detección de colisiones con paredes
   - Sistema de vidas (3 vidas iniciales)
   - Períodos de invulnerabilidad temporal tras recibir daño

2. Laberinto:
   - Tamaño 25x25 celdas (laberinto grande y expansivo)
   - Celdas de 6x6 unidades para mayor espacio
   - Generación procedural con algoritmo de Recursive Backtracking
   - Múltiples rutas hacia la meta (15% de paredes adicionales removidas)
   - Paredes con colisiones físicas funcionales
   - Texturas mejoradas con materiales procedurales
   - Paredes de piedra con textura rugosa (10 unidades de altura)
   - Suelo con textura de baldosas oscuras
   - Zona de meta visible con marcador verde brillante

3. Sistema de Recolección:
   - 10 objetos recolectables distribuidos aleatoriamente
   - Efectos visuales al recolectar (partículas amarillas)
   - Rotación y animación flotante de objetos
   - Contador en UI mostrando progreso (Items: X / 10)

4. Enemigos:
   - 5 enemigos con sistema de patrullaje por waypoints
   - Patrullaje en patrones octogonales alrededor de su spawn
   - Detección de colisión con el jugador
   - Pérdida de 1 vida por contacto
   - IA con estados: PATROL, CHASE, WAIT
   - Persecución al jugador cuando entra en rango de detección

5. Interfaz de Usuario 
   - Contador de objetos recolectados en tiempo real
   - Indicador de vidas (Health: X)
   - Pantalla de Game Over con opciones de reinicio/salida
   - Pantalla de Victoria al completar el objetivo
   - Sistema de mensajes temporales
   - MINIMAPA en esquina inferior derecha que muestra:
     * Posición del jugador (triángulo azul con dirección)
     * Ubicación de objetos recolectables (círculos amarillos)
     * Ubicación de la meta (círculo verde pulsante)
     * Posición de enemigos (círculos rojos)
     * Leyenda explicativa de símbolos

CARACTERÍSTICAS AVANZADAS

1. Sistema de Power-ups (3 tipos):
   - Speed Boost: Aumenta velocidad temporalmente (5 segundos)
   - Invencibilidad: Inmunidad temporal a daño (5 segundos)
   - Vida Extra: Recupera 1 punto de vida (Salud maxima: 3 vidas)

2. Efectos Visuales:
   - Partículas CPUParticles3D al recolectar objetos
   - Materiales con emisión para objetos especiales
   - Power-ups con colores distintivos y brillo
   - Animaciones de rotación y flotación para coleccionables
   - Modelos 3D profesionales del pack "Ultimate Platformer" by Quaternius:
     * Personaje jugador con modelo animado
     * Enemigos con modelos detallados
     * Monedas y objetos coleccionables realistas
     * Power-ups con estrellas y gemas

3. Sistema de Minimapa:
   - Mapa en tiempo real en esquina inferior derecha
   - Actualización constante de posiciones
   - Representación clara de todos los elementos del juego
   - Indicador de dirección del jugador
   - Leyenda explicativa integrada
   - Efecto de pulso en la meta para destacarla

4. Sistema de Menús:
   - Menú Principal al iniciar el juego
   - Opciones: Iniciar Juego, Salir
   - Título animado con efecto de pulso
   - Información del equipo y proyecto
   
5. Menú de Pausa:
   - Activación con tecla P
   - Pausa completa del juego
   - Opciones: Reanudar, Reiniciar, Menú Principal, Salir
   - Liberación automática del cursor
   - Navegación fluida entre escenas

6. Generación Procedural Avanzada:
   - Laberinto diferente en cada partida
   - Algoritmo garantiza solución desde inicio a meta
   - Creación de rutas alternativas para estrategia

7. Sistema de Iluminación:
   - DirectionalLight3D con sombras activadas
   - Materiales con propiedades de emisión para meta y power-ups

8. Sistema de Gestión:
   - Game Manager centralizado para coordinación
   - Sistema de señales para comunicación entre componentes
   - Gestión de estados del juego (jugando, pausado, game over, victoria)


ARQUITECTURA DEL PROYECTO
================================================================================

ESTRUCTURA DE CARPETAS:
  /scripts/
    - main_menu.gd: Menú principal del juego
    - player.gd: Control del jugador y mecánicas
    - maze_generator.gd: Generación procedural del laberinto
    - collectible.gd: Lógica de objetos recolectables
    - enemy.gd: IA de enemigos y patrullaje
    - powerup.gd: Sistema de power-ups
    - game_manager.gd: Coordinador central del juego
    - hud.gd: Interfaz de usuario
    - main.gd: Escena principal y spawning
    - minimap.gd: Sistema de minimapa en tiempo real

  /scenes/
    - main_menu.tscn: Menú principal (escena inicial)
    - main.tscn: Escena principal del juego
    - player.tscn: Prefab del jugador
    - enemy.tscn: Prefab de enemigo
    - collectible.tscn: Prefab de objeto recolectable
    - powerup.tscn: Prefab de power-up
    - hud.tscn: Interfaz gráfica

  /assets/
    - /models/: Modelos 3D del pack Ultimate Platformer
    - /textures/: Texturas del proyecto
    - /materials/: Materiales reutilizables

  /build/
    - LittleMazeRunner.exe: Ejecutable del juego (Windows)
    - LittleMazeRunner.console.exe: Versión con consola para debugging
    - LittleMazeRunner.pck: Archivo de recursos empaquetados


SISTEMAS PRINCIPALES:

1. SISTEMA DE MOVIMIENTO:
   - Física basada en CharacterBody3D
   - Aceleración y fricción para movimiento natural
   - Gravedad aplicada automáticamente
   - Control de cámara en tercera persona con límites verticales

2. GENERACIÓN DE LABERINTO:
   - Algoritmo: Recursive Backtracking
   - Grid 2D con información de paredes por celda
   - Construcción 3D con BoxMesh para paredes
   - StaticBody3D con CollisionShape3D para cada pared y celda de suelo
   - Sistema de spawning para ubicaciones aleatorias válidas

3. SISTEMA DE COMBATE/DAÑO:
   - Detección por colisión física
   - Invulnerabilidad temporal post-daño (2 segundos)
   - Actualización automática de UI
   - Game Over al agotar vidas

4. SISTEMA DE VICTORIA:
   - Requiere: todos los coleccionables + llegar a la meta
   - Validación en tiempo real
   - Mensajes informativos si faltan condiciones


CRÉDITOS
================================================================================

DESARROLLO:
  Carlos Fabian Leyva Gómez
  Santiago Lizarraga Hopkins
  Daniel Pichardo Sanchez

HERRAMIENTAS:
  Godot Engine 4.5 - Motor de juego
  GDScript - Lenguaje de programación

ASSETS:
  Ultimate Platformer Pack by Quaternius - Modelos 3D


================================================================================
Este proyecto fue desarrollado con fines educativos para la materia de
Programación de Gráficos 3D en CUCEI, Universidad de Guadalajara.

Todos los derechos reservados 2025
================================================================================
