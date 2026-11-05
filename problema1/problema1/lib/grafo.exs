defmodule Parcial2.Rutas.Grafo do
  @moduledoc """
  Grafo dirigido: lista de adyacencia que respeta el orden de aparición en el
  archivo (así los itinerarios salen en un orden reproducible).
  """
  defstruct adyacencia: %{}, centros: MapSet.new()

  def construir(tramos) do
    %__MODULE__{
      adyacencia: Enum.group_by(tramos, & &1.origen),
      centros: Enum.reduce(tramos, MapSet.new(), &(&2 |> MapSet.put(&1.origen) |> MapSet.put(&1.destino)))
    }
  end

  def existe?(%__MODULE__{centros: centros}, centro), do: MapSet.member?(centros, centro)

  def salientes(%__MODULE__{adyacencia: ady}, centro), do: Map.get(ady, centro, [])
end
