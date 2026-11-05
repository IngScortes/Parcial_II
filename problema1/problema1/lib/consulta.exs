defmodule Parcial2.Rutas.Consulta do
  @moduledoc "Una consulta `origen,destino` con su línea física."
  defstruct [:linea, :origen, :destino]

  def parse(linea, texto) do
    case texto |> String.split(",") |> Enum.map(&String.trim/1) do
      [origen, destino] when origen != "" and destino != "" ->
        {:ok, %__MODULE__{linea: linea, origen: origen, destino: destino}}

      _ ->
        {:error, "línea #{linea}: consulta mal formada '#{texto}' (se esperaba origen,destino)"}
    end
  end

  def titulo(%__MODULE__{origen: o, destino: d}), do: "#{o} → #{d}"
end
