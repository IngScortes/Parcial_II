Code.require_file("grafo.exs", __DIR__)

defmodule Alcance do
  def pasos(%Grafo{} = grafo, origen) do
    Stream.iterate(MapSet.new([origen]), fn alcanzados -> expandir(grafo, alcanzados) end)
  end

  def calcular(%Grafo{} = grafo, origen) do
    estados =
      grafo
      |> pasos(origen)
      |> Stream.transform(nil, &hasta_estabilizar/2)
      |> Enum.to_list()

    %{estados: estados, paso_estable: length(estados) - 1}
  end

  def alcanzable?(%{estados: estados}, centro) do
    estados
    |> List.last()
    |> MapSet.member?(centro)
  end

  defp hasta_estabilizar(estado, estado), do: {:halt, estado}
  defp hasta_estabilizar(estado, _previo), do: {[estado], estado}

  defp expandir(grafo, alcanzados) do
    Enum.reduce(alcanzados, alcanzados, fn centro, acumulado ->
      grafo
      |> Grafo.salientes(centro)
      |> Enum.reduce(acumulado, fn tramo, conjunto -> MapSet.put(conjunto, tramo.destino) end)
    end)
  end
end
