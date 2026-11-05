# Problema 1 — Rutas de entrega en una red dirigida (Elixir, scripts .exs)

## Ejecución (desde esta carpeta, Elixir >= 1.14)
```bash
elixir problema1.exs                                  # datos -> salida
elixir problema1.exs datos_invalidos salida_invalidos # caso con errores
elixir pruebas.exs                                    # 14 pruebas
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
| `problema1.exs` | Punto de entrada |
| `lib/rutas.exs` | **QUÉ**: `Rutas` (orquesta los pasos) |
| `lib/tramo.exs` | `Tramo` + `parse/1` |
| `lib/itinerario.exs` | `Itinerario` (struct y formato) |
| `lib/depuracion.exs` | `Depuracion`: validación recursiva propia |
| `lib/grafo.exs` | `Grafo`: lista de adyacencia |
| `lib/busqueda.exs` | `Busqueda`: backtracking recursivo |
| `lib/criterios.exs` | `Criterios`: mínimos con empates |
| `lib/alcance.exs` | `Alcance`: Stream infinito de centros alcanzables |
| `lib/consulta.exs` | `Consulta`: struct y parseo |
| `lib/reporte.exs` | `Reporte`: formato de texto |
| `lib/lector.exs`, `lib/escritor.exs`, `lib/consola.exs` | Lectura perezosa, escritura por flujo y salida por pantalla |
| `pruebas.exs` | 14 pruebas (ExUnit) |
| `datos/`, `datos_invalidos/` | Entradas `tramos.csv` y `consultas.txt` |

Cada archivo de `lib/` carga sus dependencias con `Code.require_file`, por lo que puede cargarse de forma independiente.

Salidas: `itinerarios.txt`, `errores_tramos.txt`, `depuracion_tramos.txt`, `alcance_centros.txt`.

## Decisiones documentadas
* Un centro "existe" si aparece en algún tramo válido tras la depuración.
* Consulta con origen == destino -> itinerario trivial de 0 tramos.
* Consultas mal formadas se registran en `itinerarios.txt` y se continúa.

## ¿Por qué converge el Stream infinito de alcance?
S0 = {origen}, S(n+1) = S(n) ∪ destinos(S(n)). (1) Es monótona: S(n) ⊆ S(n+1). (2) Está acotada por el
conjunto finito de centros |V|. (3) Solo puede crecer estrictamente a lo sumo |V|-1 veces, así que existe n con
S(n+1) = S(n). (4) Como S(n+1) depende solo de S(n), desde ahí es constante. El Stream es infinito
(`Stream.iterate/2`) pero `Stream.transform/3` hace `:halt` en el primer estado repetido: el consumo es finito.

## Casos de prueba incluidos
| Carpeta de entrada | Tipo | Qué prueba |
|---|---|---|
| `datos/` | válido | Ejemplo del enunciado (4 itinerarios A→D) |
| `datos_invalidos/` | inválido | Líneas mal formadas, bucle, repetido, centros inexistentes, consulta mal formada |
| `datos_limite/` | límite | Origen sin salidas (Stream estable en el paso 0), consultas A→A y D→D |
| `datos_vacio/` | límite | Archivos de entrada vacíos |
| `datos_grande/` | tamaño | 10 rombos en serie: 1024 itinerarios |
