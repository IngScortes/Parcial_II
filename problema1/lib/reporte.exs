Code.require_file("escritor.exs", __DIR__)
Code.require_file("tramo.exs", __DIR__)
Code.require_file("itinerario.exs", __DIR__)
Code.require_file("consulta.exs", __DIR__)

defmodule Reporte do
  def linea_error_tramo(numero, texto, motivo) do
    Escritor.linea("Línea #{numero} | #{texto} | #{motivo}")
  end

  def linea_descarte({%Tramo{} = tramo, motivo}) do
    Escritor.linea("Línea #{tramo.linea} | #{Tramo.a_texto(tramo)} | #{motivo}")
  end

  def bloque_itinerarios({:error, consulta, motivo}) do
    [Escritor.linea(titulo(consulta)), Escritor.linea("ERROR: #{motivo}"), "\n"]
  end

  def bloque_itinerarios({:sin_itinerarios, consulta, _alcance}) do
    [Escritor.linea(titulo(consulta)), Escritor.linea("sin itinerarios"), "\n"]
  end

  def bloque_itinerarios({:ok, consulta, _alcance, itinerarios, optimos}) do
    [
      Escritor.linea(titulo(consulta)),
      detalle(itinerarios),
      Escritor.linea("Total: #{plural(length(itinerarios))}"),
      Escritor.linea("Menos tramos: #{unir(optimos.tramos)}"),
      Escritor.linea("Menor tiempo: #{unir(optimos.minutos)}"),
      Escritor.linea("Menor costo: #{unir(optimos.costo)}"),
      "\n"
    ]
  end

  def bloque_alcance({:error, _consulta, _motivo}), do: []

  def bloque_alcance({:sin_itinerarios, consulta, alcance}) do
    cierre = "El destino #{consulta.destino} no es alcanzable: sin itinerarios (no se hizo búsqueda exhaustiva)"
    bloque_alcance(consulta, alcance, cierre)
  end

  def bloque_alcance({:ok, consulta, alcance, _itinerarios, _optimos}) do
    bloque_alcance(consulta, alcance, "El destino #{consulta.destino} es alcanzable")
  end

  def resumen_pantalla({:error, _consulta, motivo}), do: "ERROR: #{motivo}"

  def resumen_pantalla({:sin_itinerarios, consulta, _alcance}) do
    "#{Consulta.titulo(consulta)}: sin itinerarios"
  end

  def resumen_pantalla({:ok, consulta, _alcance, itinerarios, _optimos}) do
    "#{Consulta.titulo(consulta)}: #{plural(length(itinerarios))}"
  end

  defp bloque_alcance(consulta, %{estados: estados, paso_estable: estable}, cierre) do
    [
      Escritor.linea(titulo(consulta)),
      pasos(estados),
      Escritor.linea("Estados distintos: #{length(estados)}"),
      Escritor.linea("Se estabiliza en el paso #{estable} (el paso #{estable + 1} repite el paso #{estable})"),
      Escritor.linea(cierre),
      "\n"
    ]
  end

  defp detalle(itinerarios) do
    itinerarios
    |> Enum.with_index(1)
    |> Enum.map(fn {itinerario, numero} -> Escritor.linea(Itinerario.formato(itinerario, numero)) end)
  end

  defp pasos(estados) do
    estados
    |> Enum.with_index()
    |> Enum.map(fn {conjunto, paso} -> Escritor.linea("Paso #{paso}: #{conjunto_a_texto(conjunto)}") end)
  end

  defp titulo(:mal_formada), do: "=== consulta inválida ==="
  defp titulo(%Consulta{} = consulta), do: "=== #{Consulta.titulo(consulta)} ==="

  defp conjunto_a_texto(conjunto) do
    "{" <> (conjunto |> Enum.sort() |> Enum.join(", ")) <> "}"
  end

  defp unir(numeros), do: Enum.join(numeros, ", ")

  defp plural(1), do: "1 itinerario"
  defp plural(cantidad), do: "#{cantidad} itinerarios"
end
