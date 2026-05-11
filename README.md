🧱 BrickBreaker

BrickBreaker es un juego clásico de romper ladrillos desarrollado en Godot 4.3. Está inspirado en los videojuegos arcade tradicionales, pero con una presentación espacial y un diseño sencillo que permite jugarlo en distintas plataformas.


🎮 Descripción

En BrickBreaker, el jugador controla una paleta que se mueve de lado a lado para hacer rebotar una pelota. El objetivo es golpear todos los ladrillos de la pantalla sin dejar caer la pelota. Conforme avanza el juego, la dificultad aumenta porque aparecen más filas de ladrillos y la velocidad de la pelota se incrementa.


🕹️ Controles

En Windows y Linux, el juego se controla con las flechas izquierda y derecha del teclado (<- y ->) para mover la paleta.

En Android, el movimiento se realiza deslizando el dedo horizontalmente sobre la pantalla.


📋 Características

- Niveles progresivos — más filas de ladrillos y mayor velocidad por nivel
- Ladrillos de colores según la fila
- Partículas al destruir ladrillos
- Fondo espacial animado
- Paleta con shader personalizado
- Compatible con teclado y pantalla táctil


Desarrollado con

- Godot Engine 4.3
- GDScript — Lenguaje de programación
- GLSL (gdshader) — Shader de la paleta


📁 Estructura del proyecto


BrickBreaker/
├── Brick/
│   ├── assets/          # Imágenes (pelota, ladrillo, paleta, fondo)
│   ├── scenes/          # Escenas de Godot (.tscn)
│   ├── scripts/         # Lógica del juego (.gd)
│   └── shaders/         # Shaders visuales (.gdshader)
├── icon.svg
└── project.godot

