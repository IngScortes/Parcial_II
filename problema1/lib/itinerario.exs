defmodule Itinerario do
  defstruct centros: [], minutos: 0, costo: 0

  def n_tramos(%Itinerario{centros: centros}), do: length(centros) - 1

  def formato(%Itinerario{} = itinerario, numero) do
    recorrido = Enum.join(itinerario.centros, " → ")

    "Itinerario #{numero}: #{recorrido} | tramos: #{n_tramos(itinerario)} | " <>
      "#{itinerario.minutos} min | costo: #{itinerario.costo}"
  end
end
