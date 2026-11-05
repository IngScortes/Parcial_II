Code.require_file("mapa.exs", __DIR__)
Code.require_file("region.exs", __DIR__)

defmodule Buscador do
  @fondo "."

  def regiones(%Mapa{} = mapa), do: recorrer(mapa, {0, 0}, MapSet.new(), [])

  defp recorrer(%Mapa{filas: filas}, {filas, _columna}, _visitadas, acumulado) do
    Enum.reverse(acumulado)
  end

  defp recorrer(%Mapa{columnas: columnas} = mapa, {fila, columnas}, visitadas, acumulado) do
    recorrer(mapa, {fila + 1, 0}, visitadas, acumulado)
  end

  defp recorrer(mapa, {fila, columna} = posicion, visitadas, acumulado) do
    simbolo = Mapa.simbolo(mapa, posicion)
    siguiente = {fila, columna + 1}

    if simbolo == @fondo or MapSet.member?(visitadas, posicion) do
      recorrer(mapa, siguiente, visitadas, acumulado)
    else
      {celdas, visitadas} = explorar(mapa, posicion, simbolo, visitadas, [])
      region = construir(mapa, length(acumulado) + 1, simbolo, posicion, celdas)
      recorrer(mapa, siguiente, visitadas, [region | acumulado])
    end
  end

  defp explorar(mapa, posicion, simbolo, visitadas, celdas) do
    visitadas = MapSet.put(visitadas, posicion)
    explorar_vecinos(mapa, vecinos(posicion), simbolo, visitadas, [posicion | celdas])
  end

  defp explorar_vecinos(_mapa, [], _simbolo, visitadas, celdas), do: {celdas, visitadas}

  defp explorar_vecinos(mapa, [vecino | resto], simbolo, visitadas, celdas) do
    if Mapa.simbolo(mapa, vecino) == simbolo and not MapSet.member?(visitadas, vecino) do
      {celdas, visitadas} = explorar(mapa, vecino, simbolo, visitadas, celdas)
      explorar_vecinos(mapa, resto, simbolo, visitadas, celdas)
    else
      explorar_vecinos(mapa, resto, simbolo, visitadas, celdas)
    end
  end

  defp vecinos({fila, columna}) do
    [{fila - 1, columna}, {fila + 1, columna}, {fila, columna - 1}, {fila, columna + 1}]
  end

  defp construir(mapa, id, simbolo, primera, celdas) do
    filas = Enum.map(celdas, &elem(&1, 0))
    columnas = Enum.map(celdas, &elem(&1, 1))

    %Region{
      id: id,
      simbolo: simbolo,
      celdas: Enum.sort(celdas),
      area: length(celdas),
      perimetro: perimetro(mapa, celdas, simbolo),
      desde: {Enum.min(filas), Enum.min(columnas)},
      hasta: {Enum.max(filas), Enum.max(columnas)},
      primera: primera
    }
  end

  defp perimetro(mapa, celdas, simbolo) do
    Enum.reduce(celdas, 0, fn posicion, total ->
      total + Enum.count(vecinos(posicion), fn vecino -> Mapa.simbolo(mapa, vecino) != simbolo end)
    end)
  end
end
