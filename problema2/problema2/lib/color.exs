defmodule Parcial2.Mapas.Color do
  @moduledoc """
  Entrada de la paleta. `parse/1` solo comprueba la ESTRUCTURA de la línea
  (3 campos, símbolo y nombre no vacíos). El formato `#RRGGBB` y los símbolos
  repetidos los verifica la validación recursiva, para poder reportarlos todos.
  """
  defstruct [:simbolo, :nombre, :hex, :linea]

  def parse(texto) do
    case texto |> String.split(",") |> Enum.map(&String.trim/1) do
      [simbolo, nombre, hex] when simbolo != "" and nombre != "" and hex != "" ->
        {:ok, %__MODULE__{simbolo: simbolo, nombre: nombre, hex: hex}}

      [_, _, _] ->
        {:error, "hay campos vacíos (se espera simbolo,nombre,color_hex)"}

      campos ->
        {:error, "se esperaban 3 campos (simbolo,nombre,color_hex) y se encontraron #{length(campos)}"}
    end
  end

  @doc "Color de texto (negro/blanco) con buen contraste sobre `hex` (#RRGGBB)."
  def contraste("#" <> <<r::binary-size(2), g::binary-size(2), b::binary-size(2)>>) do
    luminancia =
      0.299 * String.to_integer(r, 16) + 0.587 * String.to_integer(g, 16) +
        0.114 * String.to_integer(b, 16)

    if luminancia > 150, do: "#000000", else: "#FFFFFF"
  end
end
