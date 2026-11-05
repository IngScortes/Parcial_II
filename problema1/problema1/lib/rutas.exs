Code.require_file("lector.exs", __DIR__)
Code.require_file("escritor.exs", __DIR__)
Code.require_file("tramo.exs", __DIR__)
Code.require_file("depuracion.exs", __DIR__)
Code.require_file("grafo.exs", __DIR__)
Code.require_file("alcance.exs", __DIR__)
Code.require_file("busqueda.exs", __DIR__)
Code.require_file("criterios.exs", __DIR__)
Code.require_file("consulta.exs", __DIR__)
Code.require_file("reporte.exs", __DIR__)

defmodule Parcial2.Rutas do
  @moduledoc """
  PROBLEMA 1 — Rutas de entrega en una red dirigida.

  Este módulo es el QUÉ: describe, en orden, lo que el programa hace. Cada paso
  delega el CÓMO en un módulo especializado:

      Lector        -> leer líneas útiles (File.stream!, perezoso)
      Tramo         -> convertir una línea en struct
      Depuracion    -> descartar bucles y repetidos (recursión propia)
      Grafo         -> estructura de adyacencia
      Alcance       -> Stream infinito de centros alcanzables
      Busqueda      -> backtracking recursivo de itinerarios simples
      Criterios     -> mínimos por tramos / tiempo / costo (con empates)
      Reporte       -> formato de texto
      Escritor      -> salida por flujo

  ## Restricciones y decisiones documentadas
    * Centros: cualquier texto sin comas (se comparan sensibles a mayúsculas).
    * Un centro "existe" si aparece en algún tramo válido tras la depuración.
    * Consultas mal formadas se reportan en `itinerarios.txt` y se continúa.
    * origen == destino produce el itinerario trivial de 0 tramos.
  """
  alias Parcial2.{Escritor, Lector}
  alias Parcial2.Rutas.{Alcance, Busqueda, Consulta, Criterios, Depuracion, Grafo, Reporte, Tramo}

  def ejecutar(entrada \\ "datos", salida \\ "salida") do
    archivos = %{
      tramos: Path.join(entrada, "tramos.csv"),
      consultas: Path.join(entrada, "consultas.txt")
    }

    with :ok <- Lector.verificar([archivos.tramos, archivos.consultas]) do
      File.mkdir_p!(salida)

      tramos = leer_tramos(archivos.tramos, salida)
      {validos, descartados} = Depuracion.depurar(tramos)
      informar_descartes(descartados, salida)

      grafo = Grafo.construir(validos)
      responder_consultas(archivos.consultas, grafo, salida)
      :ok
    end
  end

  # ------------------------------------------------------------------
  # Paso 1: leer y convertir tramos (perezoso). El grafo se arma DESPUÉS.
  # ------------------------------------------------------------------
  defp leer_tramos(ruta, salida) do
    parseadas =
      ruta
      |> Lector.lineas_utiles()
      |> Stream.map(fn {numero, texto} -> {numero, texto, Tramo.parse(texto)} end)

    # errores_tramos.txt se escribe a medida que se detectan
    parseadas
    |> Stream.flat_map(fn
      {n, texto, {:error, motivo}} -> [Reporte.linea_error_tramo(n, texto, motivo)]
      _ -> []
    end)
    |> encabezado("# Errores en tramos.csv: línea | contenido | motivo")
    |> Escritor.volcar(Path.join(salida, "errores_tramos.txt"))

    tramos =
      parseadas
      |> Stream.flat_map(fn
       {n, _texto, {:ok, %Tramo{} = tramo}} -> [ %Tramo{tramo | linea: n}]
        _ -> []
      end)
      |> Enum.to_list()

    IO.puts("Tramos bien formados: #{length(tramos)}")
    tramos
  end

  # ------------------------------------------------------------------
  # Paso 2: registrar descartes de la depuración recursiva
  # ------------------------------------------------------------------
  defp informar_descartes(descartados, salida) do
    descartados
    |> Stream.map(&Reporte.linea_descarte/1)
    |> encabezado("# Tramos descartados: línea | contenido | motivo")
    |> Escritor.volcar(Path.join(salida, "depuracion_tramos.txt"))

    IO.puts("Tramos descartados en la depuración: #{length(descartados)}")
  end

  # ------------------------------------------------------------------
  # Paso 3: resolver cada consulta y escribir lo que se produce
  # ------------------------------------------------------------------
  defp responder_consultas(ruta, grafo, salida) do
    itin = Escritor.abrir(Path.join(salida, "itinerarios.txt"))
    alc = Escritor.abrir(Path.join(salida, "alcance_centros.txt"))

    try do
      IO.puts("\nResumen por consulta:")

      ruta
      |> Lector.lineas_utiles()
      |> Stream.map(fn {n, texto} -> Consulta.parse(n, texto) end)
      |> Stream.map(&resolver(&1, grafo))
      |> Stream.each(fn resultado ->
        Escritor.escribir(itin, Reporte.bloque_itinerarios(resultado))
        Escritor.escribir(alc, Reporte.bloque_alcance(resultado))
        IO.puts("  " <> Reporte.resumen_pantalla(resultado))
      end)
      |> Stream.run()
    after
      Escritor.cerrar(itin)
      Escritor.cerrar(alc)
    end
  end

  @doc "Resuelve una consulta ya parseada. Devuelve un mapa de resultado."
  def resolver({:error, motivo}, _grafo),
    do: %{consulta: "mal formada", error: motivo, alcance: nil, itinerarios: [], optimos: nil}

  def resolver({:ok, %Consulta{} = c}, grafo) do
    base = %{consulta: c, error: nil, alcance: nil, itinerarios: [], optimos: nil}

    case centros_inexistentes(grafo, c) do
      [] ->
        alcance = Alcance.calcular(grafo, c.origen)

        if Alcance.alcanzable?(alcance, c.destino) do
          its = Busqueda.itinerarios(grafo, c.origen, c.destino)
          %{base | alcance: alcance, itinerarios: its, optimos: Criterios.optimos(its)}
        else
          # destino inalcanzable: se omite la búsqueda exhaustiva
          %{base | alcance: alcance}
        end

      faltan ->
        %{base | error: "el centro #{Enum.map_join(faltan, " y ", &"'#{&1}'")} no existe en la red"}
    end
  end

  defp centros_inexistentes(grafo, c) do
    [c.origen, c.destino] |> Enum.uniq() |> Enum.reject(&Grafo.existe?(grafo, &1))
  end

  # antepone una línea de encabezado a un Stream
  defp encabezado(stream, texto), do: Stream.concat([Escritor.linea(texto)], stream)
end
