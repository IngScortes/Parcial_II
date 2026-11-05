Code.require_file("tramo.exs", __DIR__)

defmodule Depuracion do
  def depurar(tramos), do: depurar(tramos, %{}, [], [])

  defp depurar([], _vistos, aceptados, descartados) do
    {:lists.reverse(aceptados), :lists.reverse(descartados)}
  end

  defp depurar([%Tramo{origen: centro, destino: centro} = tramo | resto], vistos, aceptados, descartados) do
    motivo = "bucle: el tramo sale y llega al mismo centro (#{centro})"
    depurar(resto, vistos, aceptados, [{tramo, motivo} | descartados])
  end

  defp depurar([%Tramo{} = tramo | resto], vistos, aceptados, descartados) do
    pareja = {tramo.origen, tramo.destino}

    case Map.fetch(vistos, pareja) do
      {:ok, linea_primera} ->
        motivo = motivo_repetido(tramo, linea_primera)
        depurar(resto, vistos, aceptados, [{tramo, motivo} | descartados])

      :error ->
        depurar(resto, Map.put(vistos, pareja, tramo.linea), [tramo | aceptados], descartados)
    end
  end

  defp motivo_repetido(tramo, linea_primera) do
    "repetido: ya existe #{tramo.origen}→#{tramo.destino} (primera aparición en la línea #{linea_primera})"
  end
end
