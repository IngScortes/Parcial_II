Code.require_file("escritor.exs", __DIR__)

defmodule Reporte do
  @separador ";"

  def linea_csv(region) do
    [region.id, region.simbolo, region.area, region.perimetro, coordenada(region.desde), coordenada(region.hasta)]
    |> Enum.join(@separador)
    |> Escritor.linea()
  end

  def resumen([]), do: ["Número de regiones: 0", "El mapa solo contiene fondo."]

  def resumen(regiones) do
    mayor_area = regiones |> Enum.map(& &1.area) |> Enum.max()
    mayor_perimetro = regiones |> Enum.map(& &1.perimetro) |> Enum.max()

    [
      "Número de regiones: #{length(regiones)}",
      "Mayor área (#{mayor_area}): " <> detalle(regiones, fn region -> region.area == mayor_area end),
      "Mayor perímetro (#{mayor_perimetro}): " <> detalle(regiones, fn region -> region.perimetro == mayor_perimetro end)
    ]
  end

  defp coordenada({fila, columna}), do: "{#{fila},#{columna}}"

  defp detalle(regiones, filtro) do
    regiones
    |> Enum.filter(filtro)
    |> Enum.map_join(", ", fn region -> "región #{region.id} (#{region.simbolo})" end)
  end
end
