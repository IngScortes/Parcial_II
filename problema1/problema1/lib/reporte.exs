Code.require_file("escritor.exs", __DIR__)
Code.require_file("consulta.exs", __DIR__)
Code.require_file("itinerario.exs", __DIR__)
Code.require_file("tramo.exs", __DIR__)

defmodule Parcial2.Rutas.Reporte do
  @moduledoc """
  QUÉ: dar formato de texto a los resultados (itinerarios, alcance, errores).
  Todo devuelve iodata/listas de líneas; no toca el disco.
  """
  alias Parcial2.Escritor
  alias Parcial2.Rutas.{Consulta, Itinerario, Tramo}

  def linea_error_tramo(numero, texto, motivo),
    do: Escritor.linea("Línea #{numero} | #{texto} | #{motivo}")

  def linea_descarte({%Tramo{} = t, motivo}),
    do: Escritor.linea("Línea #{t.linea} | #{Tramo.a_texto(t)} | #{motivo}")

  @doc "Bloque de `itinerarios.txt` para un resultado."
  def bloque_itinerarios(%{error: motivo, consulta: consulta}) when not is_nil(motivo) do
    [Escritor.linea(titulo_error(consulta)), Escritor.linea("ERROR: #{motivo}"), "\n"]
  end

  def bloque_itinerarios(%{consulta: c, itinerarios: []}) do
    [Escritor.linea("=== #{Consulta.titulo(c)} ==="), Escritor.linea("sin itinerarios"), "\n"]
  end

  def bloque_itinerarios(%{consulta: c, itinerarios: its, optimos: opt}) do
    detalle =
      its
      |> Enum.with_index(1)
      |> Enum.map(fn {it, n} -> Escritor.linea(Itinerario.formato(it, n)) end)

    [
      Escritor.linea("=== #{Consulta.titulo(c)} ==="),
      detalle,
      Escritor.linea("Total: #{plural(length(its))}"),
      Escritor.linea("Menos tramos: #{Enum.join(opt.tramos, ", ")}"),
      Escritor.linea("Menor tiempo: #{Enum.join(opt.minutos, ", ")}"),
      Escritor.linea("Menor costo: #{Enum.join(opt.costo, ", ")}"),
      "\n"
    ]
  end

  @doc "Bloque de `alcance_centros.txt` para un resultado."
  def bloque_alcance(%{alcance: nil}), do: []

  def bloque_alcance(%{consulta: c, alcance: %{estados: estados, paso_estable: n}, itinerarios: its}) do
    pasos =
      estados
      |> Enum.with_index()
      |> Enum.map(fn {conjunto, i} -> Escritor.linea("Paso #{i}: #{conjunto_a_texto(conjunto)}") end)

    cierre =
      if its == [],
        do: "El destino #{c.destino} no es alcanzable: sin itinerarios (no se hizo búsqueda exhaustiva)",
        else: "El destino #{c.destino} es alcanzable"

    [
      Escritor.linea("=== #{Consulta.titulo(c)} ==="),
      pasos,
      Escritor.linea("Estados distintos: #{length(estados)}"),
      Escritor.linea("Se estabiliza en el paso #{n} (el paso #{n + 1} repite el paso #{n})"),
      Escritor.linea(cierre),
      "\n"
    ]
  end

  @doc "Línea de resumen para pantalla."
  def resumen_pantalla(%{error: motivo}) when not is_nil(motivo), do: "ERROR: #{motivo}"

  def resumen_pantalla(%{consulta: c, itinerarios: []}),
    do: "#{Consulta.titulo(c)}: sin itinerarios"

  def resumen_pantalla(%{consulta: c, itinerarios: its}),
    do: "#{Consulta.titulo(c)}: #{plural(length(its))}"

  defp titulo_error(%Consulta{} = c), do: "=== #{Consulta.titulo(c)} ==="
  defp titulo_error(texto) when is_binary(texto), do: "=== consulta inválida ==="

  defp conjunto_a_texto(conjunto), do: "{" <> (conjunto |> Enum.sort() |> Enum.join(", ")) <> "}"

  defp plural(1), do: "1 itinerario"
  defp plural(n), do: "#{n} itinerarios"
end
