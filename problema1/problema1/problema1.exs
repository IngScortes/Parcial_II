# Problema 1 — Rutas de entrega en una red dirigida.
# Uso:  elixir problema1.exs [carpeta_entrada] [carpeta_salida]
# Por defecto: datos  ->  salida   (ejecutar desde esta carpeta)
Code.require_file("lib/rutas.exs", __DIR__)

case System.argv() do
  [] -> Parcial2.Rutas.ejecutar()
  [entrada] -> Parcial2.Rutas.ejecutar(entrada)
  [entrada, salida | _] -> Parcial2.Rutas.ejecutar(entrada, salida)
end
