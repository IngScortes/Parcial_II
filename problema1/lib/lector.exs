defmodule Lector do
  def lineas_utiles(ruta) do
    ruta
    |> File.stream!()
    |> Stream.with_index(1)
    |> Stream.map(fn {texto, numero} -> {numero, String.trim(texto)} end)
    |> Stream.filter(fn {_numero, texto} -> util?(texto) end)
  end

  def verificar(rutas) do
    rutas
    |> Enum.reject(&File.regular?/1)
    |> resultado_verificacion()
  end

  defp util?(""), do: false
  defp util?("#" <> _resto), do: false
  defp util?(_texto), do: true

  defp resultado_verificacion([]), do: :ok
  defp resultado_verificacion(faltantes), do: {:error, {:archivos_faltantes, faltantes}}
end
