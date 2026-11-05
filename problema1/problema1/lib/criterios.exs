Code.require_file("itinerario.exs", __DIR__)

defmodule Parcial2.Rutas.Criterios do
  @moduledoc """
  QUÉ: identificar qué itinerarios minimizan (a) tramos, (b) tiempo y (c) costo,
  conservando todos los empates.

  CÓMO: una única función genérica `indices_minimos/2` parametrizada por la
  "clave" a minimizar. Devuelve números de itinerario (base 1).
  """
  alias Parcial2.Rutas.Itinerario

  def optimos([]), do: %{tramos: [], minutos: [], costo: []}

  def optimos(itinerarios) do
    %{
      tramos: indices_minimos(itinerarios, &Itinerario.n_tramos/1),
      minutos: indices_minimos(itinerarios, & &1.minutos),
      costo: indices_minimos(itinerarios, & &1.costo)
    }
  end

  def indices_minimos(itinerarios, clave) do
    numerados = Enum.with_index(itinerarios, 1)
    minimo = numerados |> Enum.map(fn {it, _} -> clave.(it) end) |> Enum.min()
    for {it, n} <- numerados, clave.(it) == minimo, do: n
  end
end
