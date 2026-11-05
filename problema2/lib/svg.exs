Code.require_file("color.exs", __DIR__)
Code.require_file("mapa.exs", __DIR__)

defmodule Svg do
  @lado 40
  @color_borde "#334155"
  @grosor_borde 1
  @tamano_fuente 16
  @ajuste_texto 6

  def fragmentos(%Mapa{} = mapa, paleta, regiones) do
    etiquetas = Map.new(regiones, fn region -> {region.primera, region} end)

    casillas =
      Stream.flat_map(0..(mapa.filas - 1)//1, fn fila ->
        Stream.map(0..(mapa.columnas - 1)//1, fn columna ->
          casilla(mapa, paleta, etiquetas, {fila, columna})
        end)
      end)

    Stream.concat([[encabezado(mapa)], casillas, [cierre()]])
  end

  def escapar(texto) do
    texto
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end

  defp encabezado(%Mapa{} = mapa) do
    ancho = @lado * mapa.columnas
    alto = @lado * mapa.filas

    [
      ~s(<?xml version="1.0" encoding="UTF-8"?>\n),
      ~s(<svg xmlns="http://www.w3.org/2000/svg" width="#{ancho}" height="#{alto}" ),
      ~s(viewBox="0 0 #{ancho} #{alto}" font-family="sans-serif" font-size="#{@tamano_fuente}" ),
      ~s(text-anchor="middle">\n)
    ]
  end

  defp cierre, do: "</svg>\n"

  defp casilla(mapa, paleta, etiquetas, {fila, columna} = posicion) do
    color = Map.fetch!(paleta, Mapa.simbolo(mapa, posicion))
    x = columna * @lado
    y = fila * @lado

    etiquetar(Map.fetch(etiquetas, posicion), rectangulo(color, posicion, x, y), color, x, y)
  end

  defp rectangulo(color, posicion, x, y) do
    ~s(<rect x="#{x}" y="#{y}" width="#{@lado}" height="#{@lado}" ) <>
      ~s(fill="#{escapar(color.hex)}" stroke="#{@color_borde}" stroke-width="#{@grosor_borde}">) <>
      "<title>#{escapar(descripcion(color, posicion))}</title></rect>\n"
  end

  defp etiquetar({:ok, region}, rectangulo, color, x, y) do
    [
      rectangulo,
      ~s(<text x="#{x + div(@lado, 2)}" y="#{y + div(@lado, 2) + @ajuste_texto}" ),
      ~s(fill="#{escapar(Color.contraste(color.hex))}" font-weight="bold">),
      escapar(Integer.to_string(region.id)),
      "</text>\n"
    ]
  end

  defp etiquetar(:error, rectangulo, _color, _x, _y), do: rectangulo

  defp descripcion(color, {fila, columna}) do
    "#{color.nombre} (#{color.simbolo}) en {#{fila},#{columna}}"
  end
end
