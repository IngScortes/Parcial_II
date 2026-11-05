defmodule Parcial2.Rutas.Tramo do
  @moduledoc """
  Tramo dirigido entre dos centros. `linea` conserva la línea física original
  del archivo (se asigna después de `parse/1`).
  """
  defstruct [:origen, :destino, :minutos, :costo, :linea]

  @doc """
  Convierte `"origen,destino,minutos,costo"` en `{:ok, %Tramo{}}` o
  `{:error, motivo}`.
  """
  def parse(texto) when is_binary(texto) do
    campos = texto |> String.split(",") |> Enum.map(&String.trim/1)

    with {:ok, [origen, destino, minutos, costo]} <- cuatro_campos(campos),
         :ok <- no_vacio(origen, "origen"),
         :ok <- no_vacio(destino, "destino"),
         {:ok, minutos} <- entero_positivo(minutos, "minutos"),
         {:ok, costo} <- entero_positivo(costo, "costo") do
      {:ok, %__MODULE__{origen: origen, destino: destino, minutos: minutos, costo: costo}}
    end
  end

  @doc "Representación textual igual al formato de entrada."
  def a_texto(%__MODULE__{} = t), do: "#{t.origen},#{t.destino},#{t.minutos},#{t.costo}"

  defp cuatro_campos([_, _, _, _] = campos), do: {:ok, campos}

  defp cuatro_campos(campos),
    do:
      {:error,
       "se esperaban 4 campos (origen,destino,minutos,costo) y se encontraron #{length(campos)}"}

  defp no_vacio("", nombre), do: {:error, "el campo #{nombre} está vacío"}
  defp no_vacio(_valor, _nombre), do: :ok

  defp entero_positivo(texto, nombre) do
    case Integer.parse(texto) do
      {n, ""} when n > 0 -> {:ok, n}
      _ -> {:error, "#{nombre} debe ser un entero positivo y se recibió '#{texto}'"}
    end
  end
end
