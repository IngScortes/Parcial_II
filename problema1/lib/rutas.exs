Code.require_file("lector.exs", __DIR__)
Code.require_file("escritor.exs", __DIR__)
Code.require_file("consola.exs", __DIR__)
Code.require_file("tramo.exs", __DIR__)
Code.require_file("depuracion.exs", __DIR__)
Code.require_file("grafo.exs", __DIR__)
Code.require_file("alcance.exs", __DIR__)
Code.require_file("busqueda.exs", __DIR__)
Code.require_file("criterios.exs", __DIR__)
Code.require_file("consulta.exs", __DIR__)
Code.require_file("reporte.exs", __DIR__)

defmodule Rutas do
  @entrada_por_defecto "datos"
  @salida_por_defecto "salida"

  @archivo_tramos "tramos.csv"
  @archivo_consultas "consultas.txt"
  @archivo_itinerarios "itinerarios.txt"
  @archivo_alcance "alcance_centros.txt"
  @archivo_errores "errores_tramos.txt"
  @archivo_descartes "depuracion_tramos.txt"

  @encabezado_errores "# Errores en tramos.csv: línea | contenido | motivo"
  @encabezado_descartes "# Tramos descartados: línea | contenido | motivo"

  def main do
    System.argv()
    |> carpetas()
    |> ejecutar()
    |> generar_mensaje()
    |> Consola.mostrar()
  end

  def ejecutar({entrada, salida}), do: ejecutar(entrada, salida)

  def ejecutar(entrada, salida) do
    ruta_tramos = Path.join(entrada, @archivo_tramos)
    ruta_consultas = Path.join(entrada, @archivo_consultas)

    with :ok <- Lector.verificar([ruta_tramos, ruta_consultas]) do
      File.mkdir_p!(salida)

      tramos = leer_tramos(ruta_tramos, salida)
      {validos, descartados} = Depuracion.depurar(tramos)
      registrar_descartes(descartados, salida)

      resumenes =
        validos
        |> Grafo.construir()
        |> responder_consultas(ruta_consultas, salida)

      {:ok, %{tramos: length(tramos), descartados: length(descartados), resumenes: resumenes}}
    end
  end

  defp carpetas([]), do: {@entrada_por_defecto, @salida_por_defecto}
  defp carpetas([entrada]), do: {entrada, @salida_por_defecto}
  defp carpetas([entrada, salida | _resto]), do: {entrada, salida}

  defp leer_tramos(ruta, salida) do
    lineas =
      ruta
      |> Lector.lineas_utiles()
      |> Stream.map(fn {numero, texto} -> {numero, texto, Tramo.parse(texto)} end)

    lineas
    |> Stream.flat_map(&linea_con_error/1)
    |> Escritor.con_encabezado(@encabezado_errores)
    |> Escritor.volcar(Path.join(salida, @archivo_errores))

    lineas
    |> Stream.flat_map(&tramo_valido/1)
    |> Enum.to_list()
  end

  defp linea_con_error({numero, texto, {:error, motivo}}) do
    [Reporte.linea_error_tramo(numero, texto, motivo)]
  end

  defp linea_con_error({_numero, _texto, {:ok, _tramo}}), do: []

  defp tramo_valido({numero, _texto, {:ok, tramo}}), do: [%Tramo{tramo | linea: numero}]
  defp tramo_valido({_numero, _texto, {:error, _motivo}}), do: []

  defp registrar_descartes(descartados, salida) do
    descartados
    |> Stream.map(&Reporte.linea_descarte/1)
    |> Escritor.con_encabezado(@encabezado_descartes)
    |> Escritor.volcar(Path.join(salida, @archivo_descartes))
  end

  defp responder_consultas(grafo, ruta, salida) do
    itinerarios = Escritor.abrir(Path.join(salida, @archivo_itinerarios))
    alcance = Escritor.abrir(Path.join(salida, @archivo_alcance))

    try do
      ruta
      |> Lector.lineas_utiles()
      |> Stream.map(fn {numero, texto} -> Consulta.parse(numero, texto) end)
      |> Stream.map(&resolver(&1, grafo))
      |> Stream.map(&escribir_resultado(&1, itinerarios, alcance))
      |> Enum.map(&Reporte.resumen_pantalla/1)
    after
      Escritor.cerrar(itinerarios)
      Escritor.cerrar(alcance)
    end
  end

  defp escribir_resultado(resultado, itinerarios, alcance) do
    Escritor.escribir(itinerarios, Reporte.bloque_itinerarios(resultado))
    Escritor.escribir(alcance, Reporte.bloque_alcance(resultado))
    resultado
  end

  defp resolver({:error, motivo}, _grafo), do: {:error, :mal_formada, motivo}

  defp resolver({:ok, consulta}, grafo) do
    consulta
    |> centros_inexistentes(grafo)
    |> resolver_existentes(consulta, grafo)
  end

  defp centros_inexistentes(consulta, grafo) do
    [consulta.origen, consulta.destino]
    |> Enum.uniq()
    |> Enum.reject(&Grafo.existe?(grafo, &1))
  end

  defp resolver_existentes([], consulta, grafo) do
    alcance = Alcance.calcular(grafo, consulta.origen)
    buscar(Alcance.alcanzable?(alcance, consulta.destino), consulta, alcance, grafo)
  end

  defp resolver_existentes(faltantes, consulta, _grafo) do
    centros = Enum.map_join(faltantes, " y ", fn centro -> "'#{centro}'" end)
    {:error, consulta, "el centro #{centros} no existe en la red"}
  end

  defp buscar(false, consulta, alcance, _grafo), do: {:sin_itinerarios, consulta, alcance}

  defp buscar(true, consulta, alcance, grafo) do
    itinerarios = Busqueda.itinerarios(grafo, consulta.origen, consulta.destino)
    {:ok, consulta, alcance, itinerarios, Criterios.optimos(itinerarios)}
  end

  defp generar_mensaje({:ok, resultado}) do
    encabezado = [
      "Tramos bien formados: #{resultado.tramos}",
      "Tramos descartados en la depuración: #{resultado.descartados}",
      "",
      "Resumen por consulta:"
    ]

    detalle = Enum.map(resultado.resumenes, fn resumen -> "  " <> resumen end)
    Enum.join(encabezado ++ detalle, "\n")
  end

  defp generar_mensaje({:error, {:archivos_faltantes, faltantes}}) do
    Enum.map_join(faltantes, "\n", fn ruta -> "ERROR: falta el archivo requerido: #{ruta}" end)
  end
end
