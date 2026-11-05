Code.require_file("grafo.exs", __DIR__)

defmodule Parcial2.Rutas.Alcance do
  @moduledoc """
  QUÉ: conjuntos de centros alcanzables desde un origen, paso a paso, hasta que
  se estabilizan.

  CÓMO: `Stream.iterate/2` produce la secuencia INFINITA de estados
  S0 = {origen}, S(n+1) = S(n) ∪ destinos de los tramos que salen de S(n).
  `Stream.transform/3` corta (`:halt`) en el primer estado idéntico al anterior.

  ¿Por qué converge aunque el Stream sea infinito?
    1. La secuencia es monótona: S(n) ⊆ S(n+1) (la unión nunca quita centros).
    2. Está acotada: todos los estados son subconjuntos del conjunto finito de
       centros de la red (|V| elementos).
    3. Un conjunto que crece estrictamente en cada paso solo puede hacerlo a lo
       sumo |V| - 1 veces; después algún paso no añade nada (S(n+1) = S(n)).
    4. Como S(n+1) depende solo de S(n), a partir de ahí todos los pasos son
       iguales: se estabilizó. El Stream es infinito, pero el consumo es finito
       porque solo se piden estados hasta el primer repetido.
  """
  alias Parcial2.Rutas.Grafo

  @doc "Stream infinito de MapSets (paso 0, paso 1, ...)."
  def pasos(%Grafo{} = grafo, origen) do
    Stream.iterate(MapSet.new([origen]), &expandir(grafo, &1))
  end

  @doc """
  Consume solo los pasos necesarios. Devuelve `%{estados: [MapSet], paso_estable: n}`
  donde `estados` son los estados distintos (paso 0..n) y `n` el paso donde se
  estabiliza.
  """
  def calcular(%Grafo{} = grafo, origen) do
    estados =
      grafo
      |> pasos(origen)
      |> Stream.transform(nil, fn
        estado, estado -> {:halt, estado}
        estado, _previo -> {[estado], estado}
      end)
      |> Enum.to_list()

    %{estados: estados, paso_estable: length(estados) - 1}
  end

  def alcanzable?(%{estados: estados}, centro), do: MapSet.member?(List.last(estados), centro)

  defp expandir(grafo, alcanzados) do
    Enum.reduce(alcanzados, alcanzados, fn centro, acc ->
      grafo
      |> Grafo.salientes(centro)
      |> Enum.reduce(acc, &MapSet.put(&2, &1.destino))
    end)
  end
end
