# Problema 1 — Rutas de entrega en una red dirigida (Elixir, scripts .exs)

## Ejecución (desde esta carpeta, Elixir >= 1.14)
```bash
elixir problema1.exs                                  # datos -> salida
elixir problema1.exs datos_invalidos salida_invalidos # caso con errores
elixir pruebas.exs                                    # 14 pruebas
```

## Archivos
| Archivo | Rol |
|---|---|
| `problema1.exs` | Punto de entrada |
| `lib/rutas.exs` | **QUÉ**: `Parcial2.Rutas` (orquesta los pasos) |
| `lib/tramo.exs` | `Tramo` + `parse/1` |
| `lib/itinerario.exs` | `Itinerario` (struct y formato) |
| `lib/depuracion.exs` | `Depuracion`: validación recursiva propia |
| `lib/grafo.exs` | `Grafo`: lista de adyacencia |
| `lib/busqueda.exs` | `Busqueda`: backtracking recursivo |
| `lib/criterios.exs` | `Criterios`: mínimos con empates |
| `lib/alcance.exs` | `Alcance`: Stream infinito de centros alcanzables |
| `lib/consulta.exs` | `Consulta`: struct y parseo |
| `lib/reporte.exs` | `Reporte`: formato de texto |
| `lib/lector.exs`, `lib/escritor.exs` | Lectura perezosa y escritura por flujo |
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
