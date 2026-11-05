Code.require_file("escritor.exs", __DIR__)

defmodule Parcial2.Mapas.Reporte do
  @moduledoc "QUÉ: dar formato a CSV, resumen y errores. No toca el disco."
  alias Parcial2.Escritor

  def encabezado_csv, do: Escritor.linea("id;simbolo;area;perimetro;desde;hasta")

  def linea_csv(r),
    do: Escritor.linea("#{r.id};#{r.simbolo};#{r.area};#{r.perimetro};#{coord(r.desde)};#{coord(r.hasta)}")

  def coord({f, c}), do: "{#{f},#{c}}"

  @doc "Líneas del resumen (sirven para pantalla y para resumen_regiones.txt)."
  def resumen([]), do: ["Número de regiones: 0", "El mapa solo contiene fondo."]

  def resumen(regiones) do
    max_area = regiones |> Enum.map(& &1.area) |> Enum.max()
    max_per = regiones |> Enum.map(& &1.perimetro) |> Enum.max()

    [
      "Número de regiones: #{length(regiones)}",
      "Mayor área (#{max_area}): " <> detalle(regiones, &(&1.area == max_area)),
      "Mayor perímetro (#{max_per}): " <> detalle(regiones, &(&1.perimetro == max_per))
    ]
  end

  defp detalle(regiones, filtro) do
    regiones
    |> Enum.filter(filtro)
    |> Enum.map_join(", ", &"región #{&1.id} (#{&1.simbolo})")
  end
end
