defmodule Parcial2.Rutas.Itinerario do
  @moduledoc "Itinerario simple: secuencia de centros con tiempo y costo totales."
  defstruct centros: [], minutos: 0, costo: 0

  @doc "Cantidad de tramos utilizados (centros - 1)."
  def n_tramos(%__MODULE__{centros: centros}), do: length(centros) - 1

  @doc "Línea de texto de un itinerario ya numerado."
  def formato(%__MODULE__{} = it, numero) do
    "Itinerario #{numero}: #{Enum.join(it.centros, " → ")} | tramos: #{n_tramos(it)} | " <>
      "#{it.minutos} min | costo: #{it.costo}"
  end
end
