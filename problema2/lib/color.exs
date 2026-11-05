defmodule Color do
  @umbral_luminancia 150
  @negro "#000000"
  @blanco "#FFFFFF"

  defstruct [:simbolo, :nombre, :hex, :linea]

  def parse(texto) do
    texto
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> construir()
  end

  def contraste("#" <> <<rojo::binary-size(2), verde::binary-size(2), azul::binary-size(2)>>) do
    luminancia =
      0.299 * String.to_integer(rojo, 16) +
        0.587 * String.to_integer(verde, 16) +
        0.114 * String.to_integer(azul, 16)

    texto_para(luminancia > @umbral_luminancia)
  end

  defp texto_para(true), do: @negro
  defp texto_para(false), do: @blanco

  defp construir([simbolo, nombre, hex]) when simbolo != "" and nombre != "" and hex != "" do
    {:ok, %Color{simbolo: simbolo, nombre: nombre, hex: hex}}
  end

  defp construir([_simbolo, _nombre, _hex]) do
    {:error, "hay campos vacíos (se espera simbolo,nombre,color_hex)"}
  end

  defp construir(campos) do
    {:error, "se esperaban 3 campos (simbolo,nombre,color_hex) y se encontraron #{length(campos)}"}
  end
end
