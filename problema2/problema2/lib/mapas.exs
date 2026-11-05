Code.require_file("lector.exs", __DIR__)
Code.require_file("escritor.exs", __DIR__)
Code.require_file("color.exs", __DIR__)
Code.require_file("mapa.exs", __DIR__)
Code.require_file("validacion.exs", __DIR__)
Code.require_file("buscador.exs", __DIR__)
Code.require_file("svg.exs", __DIR__)
Code.require_file("reporte.exs", __DIR__)

defmodule Parcial2.Mapas do
  @moduledoc """
  PROBLEMA 2 — Regiones en un mapa de colores y exportación SVG.

  Este módulo es el QUÉ, en orden:

    1. verificar que existan los archivos de entrada
    2. leer mapa y paleta por flujo (File.stream!)
    3. validar con recursión propia (todos los problemas -> validacion_mapa.txt)
    4. si hay errores: detenerse, SIN calcular regiones ni SVG
    5. encontrar regiones, escribir regiones.csv, mapa_regiones.svg y resumen

  El CÓMO vive en: Lector, Color, Validacion, Mapa, Buscador, Svg, Reporte, Escritor.

  Decisiones: los símbolos del mapa son tokens separados por espacios; el
  símbolo `.` es fondo (se dibuja pero no forma regiones).
  """
  alias Parcial2.{Escritor, Lector}
  alias Parcial2.Mapas.{Buscador, Color, Mapa, Reporte, Svg, Validacion}

  def ejecutar(entrada \\ "datos", salida \\ "salida") do
    archivos = %{mapa: Path.join(entrada, "mapa.txt"), paleta: Path.join(entrada, "paleta.csv")}

    with :ok <- Lector.verificar([archivos.mapa, archivos.paleta]) do
      File.mkdir_p!(salida)

      filas = leer_mapa(archivos.mapa)
      paleta = leer_paleta(archivos.paleta)

      case Validacion.validar(filas, paleta) do
        [] ->
          escribir_validacion(salida, [])
          IO.puts("Validación correcta: mapa y paleta sin problemas.")
          procesar(filas, paleta, salida)

        problemas ->
          escribir_validacion(salida, problemas)
          IO.puts("Se encontraron #{length(problemas)} problema(s); ver validacion_mapa.txt")
          Enum.each(problemas, &IO.puts("  - " <> &1))
          {:error, :entrada_invalida}
      end
    end
  end

  # --- lectura por flujo ------------------------------------------------------
  defp leer_mapa(ruta) do
    ruta
    |> Lector.lineas_utiles()
    |> Stream.map(fn {linea, texto} -> {linea, String.split(texto)} end)
    |> Enum.to_list()
  end

  defp leer_paleta(ruta) do
    ruta
    |> Lector.lineas_utiles()
    |> Stream.map(fn {linea, texto} ->
      case Color.parse(texto) do
        {:ok, color} -> {linea, {:ok, %Color{color | linea: linea}}}
        error -> {linea, error}
      end
    end)
    |> Enum.to_list()
  end

  # --- salidas de validación ---------------------------------------------------
  defp escribir_validacion(salida, []),
    do: Escritor.volcar([Escritor.linea("Validación correcta: sin problemas.")], Path.join(salida, "validacion_mapa.txt"))

  defp escribir_validacion(salida, problemas) do
    problemas
    |> Stream.map(&Escritor.linea/1)
    |> Escritor.volcar(Path.join(salida, "validacion_mapa.txt"))
  end

  # --- cálculo y exportación ---------------------------------------------------
  defp procesar(filas, paleta, salida) do
    mapa = Mapa.desde_filas(filas)
    colores = for {_, {:ok, c}} <- paleta, into: %{}, do: {c.simbolo, c}
    regiones = Buscador.regiones(mapa)

    regiones
    |> Stream.map(&Reporte.linea_csv/1)
    |> then(&Stream.concat([Reporte.encabezado_csv()], &1))
    |> Escritor.volcar(Path.join(salida, "regiones.csv"))

    mapa
    |> Svg.fragmentos(colores, regiones)
    |> Escritor.volcar(Path.join(salida, "mapa_regiones.svg"))

    resumen = Reporte.resumen(regiones)
    resumen |> Stream.map(&Escritor.linea/1) |> Escritor.volcar(Path.join(salida, "resumen_regiones.txt"))

    IO.puts("")
    Enum.each(resumen, &IO.puts/1)
    IO.puts("\nArchivos generados en #{salida}/")
    :ok
  end
end
