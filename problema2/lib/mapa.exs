defmodule Mapa do
  defstruct [:filas, :columnas, :celdas]

  def desde_filas(filas) do
    %Mapa{filas: length(filas), columnas: columnas_de(filas), celdas: celdas_de(filas)}
  end

  def simbolo(%Mapa{celdas: celdas}, posicion), do: Map.get(celdas, posicion)

  defp columnas_de([]), do: 0
  defp columnas_de([{_linea, simbolos} | _resto]), do: length(simbolos)

  defp celdas_de(filas) do
    for {{_linea, simbolos}, fila} <- Enum.with_index(filas),
        {simbolo, columna} <- Enum.with_index(simbolos),
        into: %{},
        do: {{fila, columna}, simbolo}
  end
end
