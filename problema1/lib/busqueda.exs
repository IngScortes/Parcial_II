Code.require_file("grafo.exs", __DIR__)
Code.require_file("itinerario.exs", __DIR__)

defmodule Busqueda do
  def itinerarios(%Grafo{} = grafo, origen, destino) do
    explorar(grafo, origen, destino, [origen], 0, 0)
  end

  defp explorar(_grafo, destino, destino, camino, minutos, costo) do
    [%Itinerario{centros: Enum.reverse(camino), minutos: minutos, costo: costo}]
  end

  defp explorar(grafo, actual, destino, camino, minutos, costo) do
    grafo
    |> Grafo.salientes(actual)
    |> Enum.reject(fn tramo -> tramo.destino in camino end)
    |> Enum.flat_map(fn tramo ->
      siguiente = [tramo.destino | camino]
      explorar(grafo, tramo.destino, destino, siguiente, minutos + tramo.minutos, costo + tramo.costo)
    end)
  end
end
