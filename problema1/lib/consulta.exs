defmodule Consulta do
  defstruct [:linea, :origen, :destino]

  def parse(linea, texto) do
    texto
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> construir(linea, texto)
  end

  def titulo(%Consulta{origen: origen, destino: destino}), do: "#{origen} → #{destino}"

  defp construir([origen, destino], linea, _texto) when origen != "" and destino != "" do
    {:ok, %Consulta{linea: linea, origen: origen, destino: destino}}
  end

  defp construir(_campos, linea, texto) do
    {:error, "línea #{linea}: consulta mal formada '#{texto}' (se esperaba origen,destino)"}
  end
end
