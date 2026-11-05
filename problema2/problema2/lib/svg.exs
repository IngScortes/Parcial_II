Code.require_file("color.exs", __DIR__)
Code.require_file("mapa.exs", __DIR__)

defmodule Parcial2.Mapas.Svg do
  @moduledoc """
  QUÉ: producir el SVG del mapa: una casilla = rectángulo de 40×40 con el color
  de la paleta, borde visible y el ID de cada región escrito en una de sus casillas.

  CÓMO: `fragmentos/3` devuelve un Stream perezoso (encabezado → un rectángulo por
  casilla → cierre). Nunca se concatena el documento completo: el escritor lo
  consume fragmento a fragmento. Todo texto que entra al XML pasa por `escapar/1`.
  """
  alias Parcial2.Mapas.{Color, Mapa}

  @lado 40

  def fragmentos(%Mapa{} = mapa, paleta, regiones) do
    ancho = @lado * mapa.columnas
    alto = @lado * mapa.filas
    etiquetas = Map.new(regiones, &{&1.primera, &1})

    encabezado = [
      ~s(<?xml version="1.0" encoding="UTF-8"?>\n),
      ~s(<svg xmlns="http://www.w3.org/2000/svg" width="#{ancho}" height="#{alto}" ),
      ~s(viewBox="0 0 #{ancho} #{alto}" font-family="sans-serif" font-size="16" ),
      ~s(text-anchor="middle">\n)
    ]

    casillas =
      Stream.flat_map(0..(mapa.filas - 1)//1, fn f ->
        Stream.map(0..(mapa.columnas - 1)//1, fn c ->
          casilla(mapa, paleta, etiquetas, {f, c})
        end)
      end)

    Stream.concat([[encabezado], casillas, ["</svg>\n"]])
  end

  defp casilla(mapa, paleta, etiquetas, {f, c} = pos) do
    simbolo = Mapa.simbolo(mapa, pos)
    color = Map.fetch!(paleta, simbolo)
    x = c * @lado
    y = f * @lado

    rect =
      ~s(<rect x="#{x}" y="#{y}" width="#{@lado}" height="#{@lado}" ) <>
        ~s(fill="#{escapar(color.hex)}" stroke="#334155" stroke-width="1">) <>
        "<title>#{escapar(descripcion(color, pos))}</title></rect>\n"

    case Map.fetch(etiquetas, pos) do
      {:ok, region} ->
        [
          rect,
          ~s(<text x="#{x + div(@lado, 2)}" y="#{y + div(@lado, 2) + 6}" ),
          ~s(fill="#{escapar(Color.contraste(color.hex))}" font-weight="bold">),
          escapar(Integer.to_string(region.id)),
          "</text>\n"
        ]

      :error ->
        rect
    end
  end

  defp descripcion(color, {f, c}),
    do: "#{color.nombre} (#{color.simbolo}) en {#{f},#{c}}"

  @doc "Escapa los 5 caracteres especiales de XML."
  def escapar(texto) when is_binary(texto) do
    texto
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end
end
