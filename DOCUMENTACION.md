# Documentación técnica - BrickBreaker

---

## Estructura general del proyecto

El juego está dividido en escenas independientes que se instancian dinámicamente. La escena principal es `level.tscn`, que carga y organiza todo lo demás al iniciar. Hay un autoload llamado `GameManager` que persiste entre recargas de escena y guarda el estado global del juego.

---

## Escenas y nodos

### level.tscn — escena principal

Es la raíz del juego. Contiene todos los elementos del nivel.

Nodos hijos:
- `Camera2D` — cámara fija centrada en el área de juego (posición 572, 324)
- `Walls` (StaticBody2D) — cuerpo estático que agrupa las paredes
  - `Ceiling` (CollisionShape2D) — pared superior, rectángulo de 1164x20 px
  - `Right Wall` (CollisionShape2D) — pared derecha, rectángulo de 20x669 px
  - `LeftWall` (CollisionShape2D) — pared izquierda, rectángulo de 20x672 px
- `Paddle` — instancia de `paddle.tscn`, posición inicial (575, 581)
- `Ball` — instancia de `ball.tscn`, posición inicial (641, 440)
- `Sprite2D` — fondo espacial con tinte morado semitransparente (alpha 0.16)
- `CPUParticles2D` — partículas ambientales flotantes, 200 partículas, lifetime 5s, sin gravedad
- `Deathzone` (Area2D) — zona de muerte en la parte inferior
  - `CollisionShape2D` — rectángulo de 1139x20 px en posición (573.5, 663)
  - Conecta la señal `body_entered` al método `_on_deathzone_body_entered` de Ball

Script: `level.gd`

---

### ball.tscn — la pelota

Tipo base: `CharacterBody2D`
Collision layer: 2
Motion mode: floating (modo 1, no aplica gravedad)

Nodos hijos:
- `Sprite2D` — textura `ball.png`, escala 0.1x (la imagen es grande, se reduce)
- `CollisionShape2D` — forma circular, radio 13 px
- `VisibleOnScreenNotifier2D` — detector de visibilidad en pantalla
- `CPUParticles2D` — partículas al moverse, 1000 partículas, lifetime 0.4s, emisión esférica radio 12.41, sin gravedad, escala de 0 a 0.02 con curva de degradado

Script: `ball.gd`

---

### brick.tscn — los ladrillos

Tipo base: `RigidBody2D`
Gravity scale: 0 (no cae)
Contact monitor: activado, máximo 1 contacto
Grupo: `Brick`

Nodos hijos:
- `Sprite2D` — textura `brick.png`, escala 0.5x
- `CollisionShape2D` — rectángulo de 32x32 px, invisible en el editor
- `CPUParticles2D` — partículas de destrucción, 50 partículas, one-shot, lifetime 0.5s, gravedad hacia arriba (-500 en Y), escala de 0 a 2, colores de morado a blanco

Script: `brick.gd`

---

### paddle.tscn — la paleta

Tipo base: `CharacterBody2D`
Grupo: `Paddle`

Nodos hijos:
- `Sprite2D` — textura `paddle.png`, escala 0.3x
- `CollisionShape2D` — forma cápsula, radio 15.98, altura 186 px, rotada -90° para quedar horizontal

Script: `paddle.gd`

---

### game_manager.tscn — gestor global

Tipo base: `Node`
Registrado como autoload en `project.godot`, lo que significa que persiste durante toda la sesión y es accesible desde cualquier script como `GameManager`.

Nodos hijos:
- `CanvasLayer` — capa de UI que se dibuja encima de todo
  - `ScoreLabel` (Label) — muestra el puntaje actual, tamaño 30, centrado, posición inferior centro
  - `LevelLabel` (Label) — muestra el nivel actual, tamaño 30, alineado a la derecha

Script: `game_manager.gd`

---

## Scripts

### game_manager.gd

Controla el estado global del juego.

Variables:
- `score` (int) — puntaje acumulado del jugador, inicia en 0
- `level` (int) — nivel actual, inicia en 1

Funciones:
- `addPoints(points)` — suma puntos al score, la llaman los ladrillos al ser destruidos
- `_process(_delta)` — actualiza cada frame los labels de score y nivel en pantalla

---

### level.gd

Controla la generación del nivel.

Variables:
- `brickObject` — referencia precargada a `brick.tscn`
- `columns` (int) — número de columnas de ladrillos, fijo en 32
- `rows` (int) — número de filas, varía según el nivel
- `margin` (int) — margen desde el borde de pantalla, 50 px

Funciones:
- `_ready()` — llama a `setupLevel()` al iniciar la escena
- `setupLevel()` — calcula el número de filas según `GameManager.level` (base 2 + nivel, máximo 9), baraja colores, instancia los ladrillos en una cuadrícula de 34x34 px con probabilidad 2/3 de aparecer por celda, y asigna color según la fila
- `getColors()` — regresa un arreglo de 4 colores: cian, morado, verde-amarillo y blanco
- `_process(_delta)` — vacío, reservado

---

### ball.gd

Controla el movimiento y colisiones de la pelota.

Variables:
- `speed` (int) — velocidad inicial 200, aumenta 20 por nivel
- `dir` (Vector2) — dirección, referencia inicial hacia abajo
- `is_active` (bool) — si es false, la pelota deja de moverse (se usa al terminar nivel)

Funciones:
- `_ready()` — ajusta la velocidad según el nivel y establece dirección inicial diagonal
- `_physics_process(_delta)` — mueve la pelota con `move_and_collide`, rebota usando la normal de colisión, corrige velocidades extremas para evitar que se quede yendo solo en horizontal o vertical, y llama `hit()` en el objeto colisionado si lo tiene
- `_process(_delta)` — vacío, reservado
- `gameOver()` — reinicia score y nivel a 0 y 1, recarga la escena
- `_on_deathzone_body_entered(body)` — señal del Deathzone, llama a `gameOver()` cuando la pelota cae

---

### brick.gd

Controla el comportamiento de cada ladrillo.

Funciones:
- `_ready()` — vacío
- `hit()` — se llama cuando la pelota colisiona con el ladrillo: suma 1 punto, activa partículas, oculta el sprite y desactiva la colisión. Revisa cuántos ladrillos quedan en el grupo `Brick`; si es el último, desactiva la pelota, espera 1 segundo, sube el nivel y recarga la escena. Si no es el último, espera 1 segundo y se elimina con `queue_free()`

---

### paddle.gd

Controla el movimiento de la paleta.

Constantes:
- `SPEED` — 1000 px/s

Variables:
- `touch_direction` (float) — dirección recibida por toque en pantalla, 0 por defecto

Funciones:
- `_input(event)` — detecta `InputEventScreenTouch` (levanta el dedo = detener) e `InputEventScreenDrag` (calcula dirección según diferencia entre posición del toque y la paleta, limitada entre -1 y 1)
- `_physics_process(_delta)` — lee el eje de teclado `ui_left`/`ui_right`, prioriza teclado sobre touch si ambos están activos, aplica velocidad o frena suavemente con `move_toward`, mueve con `move_and_slide()`

---

## Colisiones

| Objeto | Tipo | Capa | Máscara |
|---|---|---|---|
| Ball | CharacterBody2D | 2 | por defecto |
| Paddle | CharacterBody2D | por defecto | por defecto |
| Brick | RigidBody2D | por defecto | por defecto |
| Walls | StaticBody2D | por defecto | por defecto |
| Deathzone | Area2D | por defecto | 3 (capas 1 y 2) |

La pelota detecta colisiones con `move_and_collide` y llama `hit()` en el objeto si lo implementa. El Deathzone usa señales para detectar cuando la pelota entra.

---

## Flujo del juego

1. Godot carga `game_manager.tscn` como autoload al iniciar
2. Se carga `level.tscn` como escena principal
3. `level.gd` genera los ladrillos en cuadrícula
4. El jugador mueve la paleta con teclado o touch
5. La pelota rebota en paredes, techo y paleta
6. Al golpear un ladrillo, se llama `hit()` → suma puntos → destruye ladrillo
7. Si era el último ladrillo → sube nivel → recarga escena
8. Si la pelota cae al Deathzone → game over → reinicia todo

---

## Assets

| Archivo | Uso |
|---|---|
| `ball.png` | Textura de la pelota y partículas ambientales |
| `brick.png` | Textura de los ladrillos |
| `paddle.png` | Textura de la paleta (tubo morado) |
| `0f0f0378...png` | Fondo espacial del nivel |
| `paddle.gdshader` | Shader de canvas_item asignado a la paleta, con variable de color expuesta |
