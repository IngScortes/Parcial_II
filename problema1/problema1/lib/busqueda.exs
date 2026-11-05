Code.require_file("grafo.exs", __DIR__)
Code.require_file("itinerario.exs", __DIR__)

defmodule Parcial2.Rutas.Busqueda do
  @moduledoc """
  QUÉ: todos los itinerarios simples entre un origen y un destino.

  CÓMO: backtracking recursivo (DFS). En cada centro se prueban los tramos
  salientes en orden de archivo, descartando destinos ya presentes en el camino
  (así un centro no se repite). Al llegar al destino la rama termina: un camino
  simple no puede pasar por el destino y regresar a él.

  Decisión documentada: si origen == destino se devuelve el itinerario trivial
  de un solo centro (0 tramos, 0 min, costo 0).
  """
  alias Parcial2.Rutas.{Grafo, Itinerario}

  def itinerarios(%Grafo{} = grafo, origen, destino),
    do: explorar(grafo, origen, destino, [origen], 0, 0)

  # Caso base: el centro actual ya es el destino.
  defp explorar(_grafo, destino, destino, camino_inverso, minutos, costo),
    do: [%Itinerario{centros: :lists.reverse(camino_inverso), minutos: minutos, costo: costo}]

  # Caso recursivo: extender por cada tramo saliente cuyo destino no esté en el camino.
  defp explorar(grafo, actual, destino, camino_inverso, minutos, costo) do
    grafo
    |> Grafo.salientes(actual)
    |> Enum.reject(&(&1.destino in camino_inverso))
    |> Enum.flat_map(fn tramo ->
      explorar(
        grafo,
        tramo.destino,
        destino,
        [tramo.destino | camino_inverso],
        minutos + tramo.minutos,
        costo + tramo.costo
      )
    end)
  end
end
