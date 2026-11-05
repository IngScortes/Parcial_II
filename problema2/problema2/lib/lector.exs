defmodule Parcial2.Lector do
  @moduledoc """
  QUÉ: entregar las líneas "útiles" de un archivo de texto, cada una con su
  número de línea física original.

  CÓMO: `File.stream!/1` + transformaciones perezosas (`Stream.with_index/2`,
  `Stream.map/2`, `Stream.reject/2`). No se crea ninguna lista intermedia ni se
  usa `File.read!/1`. Se ignoran líneas en blanco y líneas cuyo primer
  carácter no blanco es `#`.
  """

  @doc "Stream de `{numero_linea_fisica, texto_sin_espacios_extremos}`."
  def lineas_utiles(ruta) do
    ruta
    |> File.stream!()
    |> Stream.with_index(1)
    |> Stream.map(fn {texto, numero} -> {numero, String.trim(texto)} end)
    |> Stream.reject(fn {_numero, texto} -> util?(texto) == false end)
  end

  defp util?(""), do: false
  defp util?("#" <> _), do: false
  defp util?(_), do: true

  @doc "Devuelve la lista de rutas que NO existen (lista vacía = todo en orden)."
  def faltantes(rutas), do: Enum.reject(rutas, &File.regular?/1)

  @doc "Imprime qué archivos faltan. Devuelve `:ok` si no falta ninguno."
  def verificar(rutas) do
    case faltantes(rutas) do
      [] ->
        :ok

      lista ->
        Enum.each(lista, &IO.puts("ERROR: falta el archivo requerido: #{&1}"))
        {:error, {:archivos_faltantes, lista}}
    end
  end
end
