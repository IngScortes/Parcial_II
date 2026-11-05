defmodule Grafo do
  defstruct adyacencia: %{}, centros: MapSet.new()

  def construir(tramos) do
    %Grafo{adyacencia: Enum.group_by(tramos, & &1.origen), centros: centros_de(tramos)}
  end

  def existe?(%Grafo{centros: centros}, centro), do: MapSet.member?(centros, centro)

  def salientes(%Grafo{adyacencia: adyacencia}, centro), do: Map.get(adyacencia, centro, [])

  defp centros_de(tramos) do
    tramos
    |> Enum.flat_map(fn tramo -> [tramo.origen, tramo.destino] end)
    |> MapSet.new()
  end
end
