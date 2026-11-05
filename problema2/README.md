# Problema 2 — Regiones en un mapa de colores y SVG (Elixir, scripts .exs)

## Ejecución (desde esta carpeta, Elixir >= 1.14)
```bash
elixir problema2.exs                                  # datos -> salida
elixir problema2.exs datos_invalidos salida_invalidos # caso inválido (no genera SVG)
elixir pruebas.exs                                    # 11 pruebas
```

## Estilo del código
Sigue la estructura de los ejemplos de clase: cada módulo tiene `main/0` al inicio escrito como pipeline
(`... |> generar_mensaje() |> Consola.mostrar()`), las funciones devuelven tuplas `{:ok, ...}` / `{:error, ...}`
que se resuelven con funciones de varias cláusulas, las funciones puras (que arman el texto) están separadas de los
efectos (escribir archivos, mostrar en pantalla) y las constantes son atributos de módulo (`@archivo_tramos`, `@lado`...).
El código no lleva comentarios.

## Archivos
| Archivo | Rol |
|---|---|
| `problema2.exs` | Punto de entrada |
| `lib/mapas.exs` | **QUÉ**: `Mapas` (orquesta los pasos) |
| `lib/color.exs` | `Color` + `parse/1` y contraste |
| `lib/region.exs` | `Region` (struct) |
| `lib/mapa.exs` | `Mapa` (cuadrícula validada) |
| `lib/validacion.exs` | `Validacion`: validación recursiva propia |
| `lib/buscador.exs` | `Buscador`: dos funciones recursivas (recorrer / explorar) |
| `lib/svg.exs` | `Svg`: documento generado por fragmentos |
| `lib/reporte.exs` | `Reporte`: CSV y resumen |
| `lib/lector.exs`, `lib/escritor.exs`, `lib/consola.exs` | Lectura perezosa, escritura por flujo y salida por pantalla |
| `pruebas.exs` | 11 pruebas (ExUnit) |
| `datos/`, `datos_invalidos/` | Entradas `mapa.txt` y `paleta.csv` |

Cada archivo de `lib/` carga sus dependencias con `Code.require_file`, por lo que puede cargarse de forma independiente.

Salidas: `regiones.csv`, `mapa_regiones.svg`, `resumen_regiones.txt`, `validacion_mapa.txt`.

## Decisiones documentadas
* Símbolos = tokens separados por espacios; `.` es fondo (se dibuja, no forma regiones).
* Las líneas en blanco se descartan por la regla general; "fila vacía" se detecta como mapa sin filas o fila sin símbolos.
* Con cualquier problema se escribe `validacion_mapa.txt` y NO se calculan regiones ni SVG.

## Casos de prueba incluidos
| Carpeta de entrada | Tipo | Qué prueba |
|---|---|---|
| `datos/` | válido | Ejemplo del enunciado (4 regiones) |
| `datos_invalidos/` | inválido | 7 problemas de mapa y paleta; no se genera CSV ni SVG |
| `datos_limite_fondo/` | límite | Mapa solo de fondo: 0 regiones |
| `datos_limite_1x1/` | límite | Mapa de una casilla |
| `datos_limite_mapa_vacio/` | límite | Mapa sin filas (solo comentarios) |
| `datos_escape/` | SVG | Símbolos y nombres con `& < > "` (escape XML) |
| `datos_grande/` | tamaño | Mapa pseudoaleatorio 40×40 |
