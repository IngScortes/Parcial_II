# Problema 2 — Regiones en un mapa de colores y SVG (Elixir, scripts .exs)

## Ejecución (desde esta carpeta, Elixir >= 1.14)
```bash
elixir problema2.exs                                  # datos -> salida
elixir problema2.exs datos_invalidos salida_invalidos # caso inválido (no genera SVG)
elixir pruebas.exs                                    # 11 pruebas
```

## Archivos
| Archivo | Rol |
|---|---|
| `problema2.exs` | Punto de entrada |
| `lib/mapas.exs` | **QUÉ**: `Parcial2.Mapas` (orquesta los pasos) |
| `lib/color.exs` | `Color` + `parse/1` y contraste |
| `lib/region.exs` | `Region` (struct) |
| `lib/mapa.exs` | `Mapa` (cuadrícula validada) |
| `lib/validacion.exs` | `Validacion`: validación recursiva propia |
| `lib/buscador.exs` | `Buscador`: dos funciones recursivas (recorrer / explorar) |
| `lib/svg.exs` | `Svg`: documento generado por fragmentos |
| `lib/reporte.exs` | `Reporte`: CSV y resumen |
| `lib/lector.exs`, `lib/escritor.exs` | Lectura perezosa y escritura por flujo |
| `pruebas.exs` | 11 pruebas (ExUnit) |
| `datos/`, `datos_invalidos/` | Entradas `mapa.txt` y `paleta.csv` |

Cada archivo de `lib/` carga sus dependencias con `Code.require_file`, por lo que puede cargarse de forma independiente.

Salidas: `regiones.csv`, `mapa_regiones.svg`, `resumen_regiones.txt`, `validacion_mapa.txt`.

## Decisiones documentadas
* Símbolos = tokens separados por espacios; `.` es fondo (se dibuja, no forma regiones).
* Las líneas en blanco se descartan por la regla general; "fila vacía" se detecta como mapa sin filas o fila sin símbolos.
* Con cualquier problema se escribe `validacion_mapa.txt` y NO se calculan regiones ni SVG.
