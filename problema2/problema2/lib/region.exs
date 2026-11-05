defmodule Parcial2.Mapas.Region do
  @moduledoc """
  Región conexa de un mismo símbolo. `desde`/`hasta` son las esquinas de la caja
  envolvente `{fila_min, columna_min}` / `{fila_max, columna_max}`.
  `primera` es la primera casilla hallada al recorrer filas y columnas en orden.
  """
  defstruct [:id, :simbolo, :celdas, :area, :perimetro, :desde, :hasta, :primera]
end
