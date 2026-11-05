Code.require_file("itinerario.exs", __DIR__)

defmodule Criterios do
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
    minimo = numerados |> Enum.map(fn {itinerario, _numero} -> clave.(itinerario) end) |> Enum.min()

    for {itinerario, numero} <- numerados, clave.(itinerario) == minimo, do: numero
  end
end
