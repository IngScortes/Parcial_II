Code.require_file("lib/rutas.exs", __DIR__)
ExUnit.start()

defmodule Parcial2.RutasTest do
  use ExUnit.Case, async: true
  alias Parcial2.Rutas
  alias Parcial2.Rutas.{Alcance, Busqueda, Criterios, Depuracion, Grafo, Tramo}

  @moduletag :tmp_dir

  defp tramos(lista) do
    lista
    |> Enum.with_index(1)
    |> Enum.map(fn {texto, n} ->
      {:ok, t} = Tramo.parse(texto)
      %Tramo{t | linea: n}
    end)
  end

  defp grafo(lista), do: lista |> tramos() |> Depuracion.depurar() |> elem(0) |> Grafo.construir()

  @ejemplo ["A,B,8,5", "B,D,7,4", "A,C,6,2", "C,D,12,1", "B,C,3,2", "C,B,4,1", "A,A,2,1", "A,B,9,7"]

  describe "Tramo.parse/1" do
    test "válido" do
      assert {:ok, %Tramo{origen: "A", destino: "B", minutos: 8, costo: 5}} = Tramo.parse("A,B,8,5")
    end

    test "inválidos" do
      assert {:error, _} = Tramo.parse("A,B,8")
      assert {:error, _} = Tramo.parse("A,B,0,5")
      assert {:error, _} = Tramo.parse("A,B,x,5")
      assert {:error, _} = Tramo.parse(",B,1,5")
      assert {:error, _} = Tramo.parse("A,B,1,-3")
    end
  end

  describe "Depuracion" do
    test "descarta bucles y repetidos, conserva la primera y las direcciones contrarias" do
      {ok, desc} = @ejemplo |> tramos() |> Depuracion.depurar()
      assert length(ok) == 6
      assert [{%Tramo{linea: 7}, _}, {%Tramo{linea: 8}, _}] = desc
      assert Enum.any?(ok, &(&1.origen == "B" and &1.destino == "C"))
      assert Enum.any?(ok, &(&1.origen == "C" and &1.destino == "B"))
    end

    test "lista vacía" do
      assert {[], []} = Depuracion.depurar([])
    end
  end

  describe "Busqueda y Criterios" do
    test "ejemplo del enunciado" do
      g = grafo(@ejemplo)
      its = Busqueda.itinerarios(g, "A", "D")
      assert Enum.map(its, & &1.centros) == [~w(A B D), ~w(A B C D), ~w(A C D), ~w(A C B D)]
      assert Enum.map(its, &{&1.minutos, &1.costo}) == [{15, 9}, {23, 8}, {18, 3}, {17, 7}]
      assert %{tramos: [1, 3], minutos: [1], costo: [3]} = Criterios.optimos(its)
    end

    test "sin camino y límite origen == destino" do
      g = grafo(@ejemplo)
      assert Busqueda.itinerarios(g, "B", "A") == []
      assert [%{centros: ["A"], minutos: 0, costo: 0}] = Busqueda.itinerarios(g, "A", "A")
    end

    test "no repite centros aunque haya ciclos" do
      g = grafo(["A,B,1,1", "B,A,1,1", "B,C,1,1"])
      assert [%{centros: ~w(A B C)}] = Busqueda.itinerarios(g, "A", "C")
    end

    test "empates en el mínimo se conservan" do
      its = Busqueda.itinerarios(grafo(["A,B,5,5", "A,C,5,5", "B,D,5,5", "C,D,5,5"]), "A", "D")
      assert %{tramos: [1, 2], minutos: [1, 2], costo: [1, 2]} = Criterios.optimos(its)
    end
  end

  describe "Alcance (Stream infinito)" do
    test "se estabiliza y consume solo lo necesario" do
      r = Alcance.calcular(grafo(@ejemplo), "A")
      assert r.paso_estable == 2
      assert length(r.estados) == 3
      assert Alcance.alcanzable?(r, "D")
    end

    test "el Stream es realmente infinito (se pueden pedir más pasos)" do
      assert grafo(@ejemplo) |> Alcance.pasos("A") |> Enum.take(50) |> length() == 50
    end

    test "origen sin salidas: estabiliza en el paso 0" do
      r = Alcance.calcular(grafo(@ejemplo), "D")
      assert r.paso_estable == 0
      refute Alcance.alcanzable?(r, "A")
    end
  end

  describe "Rutas.ejecutar/2 (extremo a extremo)" do
    test "genera los archivos con el formato del enunciado", %{tmp_dir: dir} do
      File.write!(Path.join(dir, "tramos.csv"), "# c\n" <> Enum.join(@ejemplo, "\n") <> "\nbasura\nA,B,x,1\n")
      File.write!(Path.join(dir, "consultas.txt"), "A,D\nB,A\nZ,A\nmala\n\n# nada\n")
      salida = Path.join(dir, "out")
      assert :ok = Rutas.ejecutar(dir, salida)

      itin = File.read!(Path.join(salida, "itinerarios.txt"))
      assert itin =~ "Itinerario 3: A → C → D | tramos: 2 | 18 min | costo: 3"
      assert itin =~ "Total: 4 itinerarios"
      assert itin =~ "Menos tramos: 1, 3"
      assert itin =~ "sin itinerarios"
      assert itin =~ "el centro 'Z' no existe en la red"

      errores = File.read!(Path.join(salida, "errores_tramos.txt"))
      assert errores =~ "Línea 10 | basura"
      assert errores =~ "Línea 11 | A,B,x,1"

      deps = File.read!(Path.join(salida, "depuracion_tramos.txt"))
      assert deps =~ "Línea 8 | A,A,2,1"
      assert File.read!(Path.join(salida, "alcance_centros.txt")) =~ "Se estabiliza en el paso 2"
    end

    test "falta de archivo: informa y no lanza excepción", %{tmp_dir: dir} do
      assert {:error, {:archivos_faltantes, [_, _]}} = Rutas.ejecutar(dir, Path.join(dir, "out"))
    end

    test "archivos vacíos (límite)", %{tmp_dir: dir} do
      File.write!(Path.join(dir, "tramos.csv"), "")
      File.write!(Path.join(dir, "consultas.txt"), "")
      assert :ok = Rutas.ejecutar(dir, Path.join(dir, "out"))
    end
  end
end
