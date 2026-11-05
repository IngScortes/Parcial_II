Code.require_file("tramo.exs", __DIR__)

defmodule Parcial2.Rutas.Depuracion do
  @moduledoc """
  QUÉ: depurar la red antes de armar el grafo. Se descartan

    * los tramos que salen y llegan al mismo centro (bucles), y
    * las repeticiones de la misma pareja origen→destino en la misma dirección
      (se conserva la primera aparición, aunque cambien tiempo o costo).

  Los tramos en direcciones contrarias son distintos y coexisten.

  CÓMO: recursión de cola sobre la lista de tramos, con un mapa de "parejas ya
  vistas" como acumulador. Aquí NO se usa `Enum` ni `Stream`
  (`:lists.reverse/1` es de Erlang). Cada tramo trae su `linea` original.
  """
  alias Parcial2.Rutas.Tramo

  @doc "Devuelve `{tramos_aceptados, [{tramo_descartado, motivo}]}` conservando el orden."
  def depurar(tramos), do: depurar(tramos, %{}, [], [])

  defp depurar([], _vistos, aceptados, descartados),
    do: {:lists.reverse(aceptados), :lists.reverse(descartados)}

  defp depurar([%Tramo{origen: c, destino: c} = t | resto], vistos, ok, desc),
    do:
      depurar(resto, vistos, ok, [
        {t, "bucle: el tramo sale y llega al mismo centro (#{c})"} | desc
      ])

  defp depurar([%Tramo{} = t | resto], vistos, ok, desc) do
    pareja = {t.origen, t.destino}

    case Map.fetch(vistos, pareja) do
      {:ok, linea_primera} ->
        motivo =
          "repetido: ya existe #{t.origen}→#{t.destino} (primera aparición en la línea #{linea_primera})"

        depurar(resto, vistos, ok, [{t, motivo} | desc])

      :error ->
        depurar(resto, Map.put(vistos, pareja, t.linea), [t | ok], desc)
    end
  end
end
