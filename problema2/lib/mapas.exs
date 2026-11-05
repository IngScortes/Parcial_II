Code.require_file("lector.exs", __DIR__)
Code.require_file("escritor.exs", __DIR__)
Code.require_file("consola.exs", __DIR__)
Code.require_file("color.exs", __DIR__)
Code.require_file("mapa.exs", __DIR__)
Code.require_file("validacion.exs", __DIR__)
Code.require_file("buscador.exs", __DIR__)
Code.require_file("svg.exs", __DIR__)
Code.require_file("reporte.exs", __DIR__)

defmodule Mapas do
  @entrada_por_defecto "datos"
  @salida_por_defecto "salida"

  @archivo_mapa "mapa.txt"
  @archivo_paleta "paleta.csv"
  @archivo_validacion "validacion_mapa.txt"
  @archivo_regiones "regiones.csv"
  @archivo_svg "mapa_regiones.svg"
  @archivo_resumen "resumen_regiones.txt"

  @encabezado_csv "id;simbolo;area;perimetro;desde;hasta"
  @mensaje_validacion_correcta "Validación correcta: sin problemas."

  def main do
    System.argv()
    |> carpetas()
    |> ejecutar()
    |> generar_mensaje()
    |> Consola.mostrar()
  end

  def ejecutar({entrada, salida}), do: ejecutar(entrada, salida)

  def ejecutar(entrada, salida) do
    ruta_mapa = Path.join(entrada, @archivo_mapa)
    ruta_paleta = Path.join(entrada, @archivo_paleta)

    with :ok <- Lector.verificar([ruta_mapa, ruta_paleta]) do
      File.mkdir_p!(salida)

      filas = leer_mapa(ruta_mapa)
      paleta = leer_paleta(ruta_paleta)

      filas
      |> Validacion.validar(paleta)
      |> procesar(filas, paleta, salida)
    end
  end

  defp carpetas([]), do: {@entrada_por_defecto, @salida_por_defecto}
  defp carpetas([entrada]), do: {entrada, @salida_por_defecto}
  defp carpetas([entrada, salida | _resto]), do: {entrada, salida}

  defp leer_mapa(ruta) do
    ruta
    |> Lector.lineas_utiles()
    |> Stream.map(fn {linea, texto} -> {linea, String.split(texto)} end)
    |> Enum.to_list()
  end

  defp leer_paleta(ruta) do
    ruta
    |> Lector.lineas_utiles()
    |> Stream.map(fn {linea, texto} -> {linea, texto |> Color.parse() |> con_linea(linea)} end)
    |> Enum.to_list()
  end

  defp con_linea({:ok, color}, linea), do: {:ok, %Color{color | linea: linea}}
  defp con_linea({:error, _motivo} = error, _linea), do: error

  defp procesar([], filas, paleta, salida) do
    registrar_validacion([@mensaje_validacion_correcta], salida)
    {:ok, %{resumen: generar_regiones(filas, paleta, salida), salida: salida}}
  end

  defp procesar(problemas, _filas, _paleta, salida) do
    registrar_validacion(problemas, salida)
    {:error, {:entrada_invalida, problemas}}
  end

  defp registrar_validacion(lineas, salida) do
    lineas
    |> Stream.map(&Escritor.linea/1)
    |> Escritor.volcar(Path.join(salida, @archivo_validacion))
  end

  defp generar_regiones(filas, paleta, salida) do
    mapa = Mapa.desde_filas(filas)
    regiones = Buscador.regiones(mapa)

    regiones
    |> Stream.map(&Reporte.linea_csv/1)
    |> Escritor.con_encabezado(@encabezado_csv)
    |> Escritor.volcar(Path.join(salida, @archivo_regiones))

    mapa
    |> Svg.fragmentos(colores_por_simbolo(paleta), regiones)
    |> Escritor.volcar(Path.join(salida, @archivo_svg))

    resumen = Reporte.resumen(regiones)

    resumen
    |> Stream.map(&Escritor.linea/1)
    |> Escritor.volcar(Path.join(salida, @archivo_resumen))

    resumen
  end

  defp colores_por_simbolo(paleta) do
    for {_linea, {:ok, color}} <- paleta, into: %{}, do: {color.simbolo, color}
  end

  defp generar_mensaje({:ok, %{resumen: resumen, salida: salida}}) do
    lineas =
      ["Validación correcta: mapa y paleta sin problemas.", ""] ++
        resumen ++ ["", "Archivos generados en #{salida}/"]

    Enum.join(lineas, "\n")
  end

  defp generar_mensaje({:error, {:entrada_invalida, problemas}}) do
    encabezado = "Se encontraron #{length(problemas)} problema(s); ver #{@archivo_validacion}"
    detalle = Enum.map(problemas, fn problema -> "  - " <> problema end)
    Enum.join([encabezado | detalle], "\n")
  end

  defp generar_mensaje({:error, {:archivos_faltantes, faltantes}}) do
    Enum.map_join(faltantes, "\n", fn ruta -> "ERROR: falta el archivo requerido: #{ruta}" end)
  end
end
