# Problema 2 — Regiones en un mapa de colores y exportación SVG.
# Uso:  elixir problema2.exs [carpeta_entrada] [carpeta_salida]
# Por defecto: datos  ->  salida   (ejecutar desde esta carpeta)
Code.require_file("lib/mapas.exs", __DIR__)

case System.argv() do
  [] -> Parcial2.Mapas.ejecutar()
  [entrada] -> Parcial2.Mapas.ejecutar(entrada)
  [entrada, salida | _] -> Parcial2.Mapas.ejecutar(entrada, salida)
end
