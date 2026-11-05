defmodule Tramo do
  defstruct [:origen, :destino, :minutos, :costo, :linea]

  def parse(texto) do
    texto
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> construir()
  end

  def a_texto(%Tramo{} = tramo) do
    "#{tramo.origen},#{tramo.destino},#{tramo.minutos},#{tramo.costo}"
  end

  defp construir([origen, destino, minutos, costo]) do
    with :ok <- no_vacio(origen, "origen"),
         :ok <- no_vacio(destino, "destino"),
         {:ok, minutos} <- entero_positivo(minutos, "minutos"),
         {:ok, costo} <- entero_positivo(costo, "costo") do
      {:ok, %Tramo{origen: origen, destino: destino, minutos: minutos, costo: costo}}
    end
  end

  defp construir(campos) do
    {:error, "se esperaban 4 campos (origen,destino,minutos,costo) y se encontraron #{length(campos)}"}
  end

  defp no_vacio("", nombre), do: {:error, "el campo #{nombre} está vacío"}
  defp no_vacio(_valor, _nombre), do: :ok

  defp entero_positivo(texto, nombre) do
    texto
    |> Integer.parse()
    |> validar_entero(texto, nombre)
  end

  defp validar_entero({numero, ""}, _texto, _nombre) when numero > 0, do: {:ok, numero}
  defp validar_entero(_resultado, texto, nombre) do
    {:error, "#{nombre} debe ser un entero positivo y se recibió '#{texto}'"}
  end
end
