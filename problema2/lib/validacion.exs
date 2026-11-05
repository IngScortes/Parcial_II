Code.require_file("color.exs", __DIR__)

defmodule Validacion do
  @fondo "."

  def validar(filas, paleta) do
    definidos = simbolos_definidos(paleta, %{})

    mapa_vacio(filas) ++
      paleta_formato(paleta, %{}, []) ++
      fondo_definido(paleta) ++
      longitudes(filas, longitud_esperada(filas), []) ++
      simbolos_indefinidos(filas, 0, definidos, [])
  end

  defp mapa_vacio([]), do: ["mapa.txt: el mapa no contiene filas"]
  defp mapa_vacio(_filas), do: []

  defp paleta_formato([], _vistos, acumulado), do: :lists.reverse(acumulado)

  defp paleta_formato([{linea, {:error, motivo}} | resto], vistos, acumulado) do
    paleta_formato(resto, vistos, ["paleta.csv línea #{linea}: #{motivo}" | acumulado])
  end

  defp paleta_formato([{linea, {:ok, %Color{} = color}} | resto], vistos, acumulado) do
    acumulado = validar_hex(color, linea, acumulado)

    case Map.fetch(vistos, color.simbolo) do
      {:ok, primera} ->
        problema = "paleta.csv línea #{linea}: símbolo '#{color.simbolo}' repetido (ya declarado en la línea #{primera})"
        paleta_formato(resto, vistos, [problema | acumulado])

      :error ->
        paleta_formato(resto, Map.put(vistos, color.simbolo, linea), acumulado)
    end
  end

  defp validar_hex(color, linea, acumulado) do
    case Regex.match?(~r/^#[0-9A-Fa-f]{6}$/, color.hex) do
      true -> acumulado
      false -> ["paleta.csv línea #{linea}: el color '#{color.hex}' no tiene la forma #RRGGBB" | acumulado]
    end
  end

  defp fondo_definido(paleta) do
    case declara?(paleta, @fondo) do
      true -> []
      false -> ["paleta.csv: no se define el símbolo '#{@fondo}' (fondo)"]
    end
  end

  defp declara?([], _simbolo), do: false
  defp declara?([{_linea, {:ok, %Color{simbolo: simbolo}}} | _resto], simbolo), do: true
  defp declara?([_entrada | resto], simbolo), do: declara?(resto, simbolo)

  defp simbolos_definidos([], acumulado), do: acumulado

  defp simbolos_definidos([{_linea, {:ok, %Color{simbolo: simbolo}}} | resto], acumulado) do
    simbolos_definidos(resto, Map.put(acumulado, simbolo, true))
  end

  defp simbolos_definidos([_entrada | resto], acumulado), do: simbolos_definidos(resto, acumulado)

  defp longitud_esperada([]), do: 0
  defp longitud_esperada([{_linea, simbolos} | _resto]), do: length(simbolos)

  defp longitudes([], _esperada, acumulado), do: :lists.reverse(acumulado)

  defp longitudes([{linea, []} | resto], esperada, acumulado) do
    longitudes(resto, esperada, ["mapa.txt línea #{linea}: la fila está vacía" | acumulado])
  end

  defp longitudes([{linea, simbolos} | resto], esperada, acumulado) do
    case length(simbolos) do
      ^esperada ->
        longitudes(resto, esperada, acumulado)

      otra ->
        problema = "mapa.txt línea #{linea}: tiene #{otra} columnas y se esperaban #{esperada}"
        longitudes(resto, esperada, [problema | acumulado])
    end
  end

  defp simbolos_indefinidos([], _fila, _definidos, acumulado), do: :lists.reverse(acumulado)

  defp simbolos_indefinidos([{linea, simbolos} | resto], fila, definidos, acumulado) do
    acumulado = indefinidos_en_fila(simbolos, linea, fila, 0, definidos, acumulado)
    simbolos_indefinidos(resto, fila + 1, definidos, acumulado)
  end

  defp indefinidos_en_fila([], _linea, _fila, _columna, _definidos, acumulado), do: acumulado

  defp indefinidos_en_fila([simbolo | resto], linea, fila, columna, definidos, acumulado) do
    acumulado =
      case Map.has_key?(definidos, simbolo) do
        true -> acumulado
        false -> [problema_indefinido(simbolo, linea, fila, columna) | acumulado]
      end

    indefinidos_en_fila(resto, linea, fila, columna + 1, definidos, acumulado)
  end

  defp problema_indefinido(simbolo, linea, fila, columna) do
    "mapa.txt línea #{linea} (fila #{fila}, columna #{columna}): el símbolo '#{simbolo}' no está definido en la paleta"
  end
end
