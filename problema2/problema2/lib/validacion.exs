Code.require_file("color.exs", __DIR__)

defmodule Parcial2.Mapas.Validacion do
  @moduledoc """
  QUÉ: detectar TODOS los problemas del mapa y la paleta antes de calcular nada.

    * mapa sin filas / filas sin símbolos
    * filas de distinta longitud
    * símbolos del mapa no definidos en la paleta
    * `.` ausente de la paleta
    * colores que no tienen la forma `#RRGGBB`
    * símbolos repetidos en la paleta (y líneas mal formadas)

  CÓMO: funciones recursivas propias sobre listas, con acumulador. Dentro de
  este módulo NO se usa `Enum` ni `Stream` (`:lists.reverse/1` es de Erlang).

  Nota: las líneas en blanco del archivo ya fueron descartadas por la regla
  general de lectura, por eso una "fila vacía" solo puede ser un mapa sin
  filas o una fila sin símbolos tras separar por espacios.

  Entradas:
    * `filas`: `[{linea_fisica, [simbolos]}]`
    * `paleta`: `[{linea_fisica, {:ok, %Color{}} | {:error, motivo}}]`
  Salida: lista de textos (vacía = todo correcto).
  """
  alias Parcial2.Mapas.Color

  def validar(filas, paleta) do
    definidos = simbolos_definidos(paleta, %{})

    mapa_vacio(filas) ++
      paleta_formato(paleta, %{}, []) ++
      fondo_definido(paleta) ++
      longitudes(filas, longitud_esperada(filas), []) ++
      simbolos_indefinidos(filas, 0, definidos, [])
  end

  # --- mapa sin filas ------------------------------------------------------
  defp mapa_vacio([]), do: ["mapa.txt: el mapa no contiene filas"]
  defp mapa_vacio(_), do: []

  # --- paleta: líneas inválidas, hex y repetidos ---------------------------
  defp paleta_formato([], _vistos, acc), do: :lists.reverse(acc)

  defp paleta_formato([{linea, {:error, motivo}} | resto], vistos, acc),
    do: paleta_formato(resto, vistos, ["paleta.csv línea #{linea}: #{motivo}" | acc])

  defp paleta_formato([{linea, {:ok, %Color{} = color}} | resto], vistos, acc) do
    acc =
      case Regex.match?(~r/^#[0-9A-Fa-f]{6}$/, color.hex) do
        true -> acc
        false -> ["paleta.csv línea #{linea}: el color '#{color.hex}' no tiene la forma #RRGGBB" | acc]
      end

    case Map.fetch(vistos, color.simbolo) do
      {:ok, primera} ->
        paleta_formato(
          resto,
          vistos,
          ["paleta.csv línea #{linea}: símbolo '#{color.simbolo}' repetido (ya declarado en la línea #{primera})" | acc]
        )

      :error ->
        paleta_formato(resto, Map.put(vistos, color.simbolo, linea), acc)
    end
  end

  # --- '.' debe existir ----------------------------------------------------
  defp fondo_definido(paleta) do
    if declara?(paleta, "."), do: [], else: ["paleta.csv: no se define el símbolo '.' (fondo)"]
  end

  defp declara?([], _simbolo), do: false
  defp declara?([{_, {:ok, %Color{simbolo: s}}} | _], s), do: true
  defp declara?([_ | resto], simbolo), do: declara?(resto, simbolo)

  # --- conjunto de símbolos definidos (mapa símbolo => true) ---------------
  defp simbolos_definidos([], acc), do: acc

  defp simbolos_definidos([{_, {:ok, %Color{simbolo: s}}} | resto], acc),
    do: simbolos_definidos(resto, Map.put(acc, s, true))

  defp simbolos_definidos([_ | resto], acc), do: simbolos_definidos(resto, acc)

  # --- longitudes de fila --------------------------------------------------
  defp longitud_esperada([]), do: 0
  defp longitud_esperada([{_linea, simbolos} | _]), do: length(simbolos)

  defp longitudes([], _esperada, acc), do: :lists.reverse(acc)

  defp longitudes([{linea, []} | resto], esperada, acc),
    do: longitudes(resto, esperada, ["mapa.txt línea #{linea}: la fila está vacía" | acc])

  defp longitudes([{linea, simbolos} | resto], esperada, acc) do
    case length(simbolos) do
      ^esperada ->
        longitudes(resto, esperada, acc)

      otra ->
        longitudes(resto, esperada, [
          "mapa.txt línea #{linea}: tiene #{otra} columnas y se esperaban #{esperada}" | acc
        ])
    end
  end

  # --- símbolos del mapa no definidos (recorre filas y, dentro, columnas) --
  defp simbolos_indefinidos([], _fila, _definidos, acc), do: :lists.reverse(acc)

  defp simbolos_indefinidos([{linea, simbolos} | resto], fila, definidos, acc) do
    acc = indefinidos_en_fila(simbolos, linea, fila, 0, definidos, acc)
    simbolos_indefinidos(resto, fila + 1, definidos, acc)
  end

  defp indefinidos_en_fila([], _linea, _fila, _col, _definidos, acc), do: acc

  defp indefinidos_en_fila([s | resto], linea, fila, col, definidos, acc) do
    acc =
      if Map.has_key?(definidos, s),
        do: acc,
        else: [
          "mapa.txt línea #{linea} (fila #{fila}, columna #{col}): el símbolo '#{s}' no está definido en la paleta"
          | acc
        ]

    indefinidos_en_fila(resto, linea, fila, col + 1, definidos, acc)
  end
end
