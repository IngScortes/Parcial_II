Code.require_file("mapa.exs", __DIR__)
Code.require_file("region.exs", __DIR__)

defmodule Parcial2.Mapas.Buscador do
  @moduledoc """
  QUÉ: encontrar todas las regiones (componentes conexos por arriba/abajo/
  izquierda/derecha del mismo símbolo; `.` es fondo) con área, perímetro y caja
  envolvente.

  CÓMO: dos funciones recursivas cooperan (como pide el enunciado):

    * `recorrer/4`  -> recorre las casillas en orden de filas y columnas y, ante
                       una casilla no visitada y que no sea fondo, abre una región.
    * `explorar/5`  -> desde una casilla, visita recursivamente los vecinos con el
                       mismo símbolo. Mantiene el conjunto `visitadas`, de modo
                       que ninguna casilla asignada se recorre dos veces.

  El ID de la región se asigna en el orden de descubrimiento, que coincide con
  la primera casilla de la región en orden ascendente de filas y columnas.
  """
  alias Parcial2.Mapas.{Mapa, Region}

  @fondo "."

  def regiones(%Mapa{} = mapa), do: recorrer(mapa, {0, 0}, MapSet.new(), [])

  # --- recorrer todas las casillas aún no visitadas -------------------------
  defp recorrer(%Mapa{filas: filas}, {filas, _col}, _visitadas, acc), do: :lists.reverse(acc)

  defp recorrer(%Mapa{columnas: columnas} = mapa, {fila, columnas}, visitadas, acc),
    do: recorrer(mapa, {fila + 1, 0}, visitadas, acc)

  defp recorrer(mapa, {fila, col} = pos, visitadas, acc) do
    simbolo = Mapa.simbolo(mapa, pos)
    siguiente = {fila, col + 1}

    if simbolo == @fondo or MapSet.member?(visitadas, pos) do
      recorrer(mapa, siguiente, visitadas, acc)
    else
      {celdas, visitadas} = explorar(mapa, pos, simbolo, visitadas, [])
      region = construir(mapa, length(acc) + 1, simbolo, pos, celdas)
      recorrer(mapa, siguiente, visitadas, [region | acc])
    end
  end

  # --- explorar vecinos del mismo símbolo -----------------------------------
  defp explorar(mapa, pos, simbolo, visitadas, celdas) do
    visitadas = MapSet.put(visitadas, pos)
    explorar_vecinos(mapa, vecinos(pos), simbolo, visitadas, [pos | celdas])
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

  defp vecinos({f, c}), do: [{f - 1, c}, {f + 1, c}, {f, c - 1}, {f, c + 1}]

  # --- medidas de la región --------------------------------------------------
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

  # lados que tocan el borde (símbolo nil) o una casilla de otro símbolo
  defp perimetro(mapa, celdas, simbolo) do
    Enum.reduce(celdas, 0, fn pos, total ->
      total + Enum.count(vecinos(pos), &(Mapa.simbolo(mapa, &1) != simbolo))
    end)
  end
end
