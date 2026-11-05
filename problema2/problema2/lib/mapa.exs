defmodule Parcial2.Mapas.Mapa do
  @moduledoc "Mapa ya validado: dimensiones y un mapa `{fila, columna} => símbolo`."
  defstruct [:filas, :columnas, :celdas]

  @doc "Construye el mapa a partir de `[{linea_fisica, [simbolos]}]` (ya validadas)."
  def desde_filas(filas) do
    celdas =
      for {{_linea, simbolos}, f} <- Enum.with_index(filas),
          {simbolo, c} <- Enum.with_index(simbolos),
          into: %{},
          do: {{f, c}, simbolo}

    columnas = filas |> List.first() |> elem(1) |> length()
    %__MODULE__{filas: length(filas), columnas: columnas, celdas: celdas}
  end

  def simbolo(%__MODULE__{celdas: celdas}, pos), do: Map.get(celdas, pos)
end
