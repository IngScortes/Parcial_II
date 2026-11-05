Code.require_file("lib/mapas.exs", __DIR__)
ExUnit.start()

defmodule MapasTest do
  use ExUnit.Case, async: true

  @moduletag :tmp_dir

  defp filas(texto) do
    texto
    |> String.split("\n", trim: true)
    |> Enum.with_index(1)
    |> Enum.map(fn {l, n} -> {n, String.split(l)} end)
  end

  defp paleta(lineas) do
    lineas
    |> Enum.with_index(1)
    |> Enum.map(fn {l, n} ->
      case Color.parse(l) do
        {:ok, c} -> {n, {:ok, %Color{c | linea: n}}}
        e -> {n, e}
      end
    end)
  end

  @pal ["A,agua,#2563EB", "B,bosque,#16A34A", "C,cultivo,#F59E0B", ".,fondo,#F1F5F9"]
  @mapa "A A . B B\nA . . B .\n. . C . .\nC C C . B\nC . . B B"

  describe "Buscador" do
    test "ejemplo del enunciado" do
      rs = @mapa |> filas() |> Mapa.desde_filas() |> Buscador.regiones()

      assert Enum.map(rs, &{&1.id, &1.simbolo, &1.area, &1.perimetro, &1.desde, &1.hasta}) == [
               {1, "A", 3, 8, {0, 0}, {1, 1}},
               {2, "B", 3, 8, {0, 3}, {1, 4}},
               {3, "C", 5, 12, {2, 0}, {4, 2}},
               {4, "B", 3, 8, {3, 3}, {4, 4}}
             ]
    end

    test "las diagonales no unen regiones" do
      rs = "A .\n. A" |> filas() |> Mapa.desde_filas() |> Buscador.regiones()
      assert length(rs) == 2
    end

    test "solo fondo y una sola casilla (límites)" do
      assert [] = ". .\n. ." |> filas() |> Mapa.desde_filas() |> Buscador.regiones()
      assert [%{area: 1, perimetro: 4}] = "A" |> filas() |> Mapa.desde_filas() |> Buscador.regiones()
    end

    test "mapa grande 300x300 sin desbordar (región en serpiente)" do
      n = 300
      texto = for(_f <- 1..n, do: Enum.map_join(1..n, " ", fn _ -> "A" end)) |> Enum.join("\n")
      [r] = texto |> filas() |> Mapa.desde_filas() |> Buscador.regiones()
      assert r.area == n * n
      assert r.perimetro == 4 * n
    end
  end

  describe "Validacion" do
    test "mapa y paleta correctos" do
      assert [] = Validacion.validar(filas(@mapa), paleta(@pal))
    end

    test "detecta TODOS los problemas" do
      mapa = "A A B\nA Z\n"
      pal = ["A,agua,#2563EB", "A,otra,#000000", "B,bosque,verde", "mala linea"]
      problemas = Validacion.validar(filas(mapa), paleta(pal))
      texto = Enum.join(problemas, "\n")
      assert texto =~ "'Z' no está definido"
      assert texto =~ "tiene 2 columnas y se esperaban 3"
      assert texto =~ "símbolo 'A' repetido"
      assert texto =~ "'verde' no tiene la forma #RRGGBB"
      assert texto =~ "no se define el símbolo '.'"
      assert texto =~ "se esperaban 3 campos"
    end

    test "mapa sin filas" do
      assert Enum.any?(Validacion.validar([], paleta(@pal)), &(&1 =~ "no contiene filas"))
    end
  end

  describe "Svg" do
    test "escapa texto peligroso" do
      assert Svg.escapar(~s(<a & "b" 'c'>)) == "&lt;a &amp; &quot;b&quot; &apos;c&apos;&gt;"
    end
  end

  describe "Mapas.ejecutar/2 (extremo a extremo)" do
    test "entrada válida genera CSV, SVG y resumen", %{tmp_dir: dir} do
      File.write!(Path.join(dir, "mapa.txt"), "# c\n" <> @mapa <> "\n")
      File.write!(Path.join(dir, "paleta.csv"), Enum.join(@pal, "\n") <> "\n")
      out = Path.join(dir, "out")
      assert {:ok, %{resumen: _resumen}} = Mapas.ejecutar(dir, out)
      assert File.read!(Path.join(out, "regiones.csv")) =~ "3;C;5;12;{2,0};{4,2}"
      svg = File.read!(Path.join(out, "mapa_regiones.svg"))
      assert svg =~ ~s(width="200" height="200")
      assert length(Regex.scan(~r/<rect /, svg)) == 25
      assert File.read!(Path.join(out, "resumen_regiones.txt")) =~ "Número de regiones: 4"
    end

    test "entrada inválida: reporta y NO genera regiones ni SVG", %{tmp_dir: dir} do
      File.write!(Path.join(dir, "mapa.txt"), "A Q\nA\n")
      File.write!(Path.join(dir, "paleta.csv"), "A,agua,#2563EB\n")
      out = Path.join(dir, "out")
      assert {:error, {:entrada_invalida, problemas}} = Mapas.ejecutar(dir, out)
      assert Enum.any?(problemas, &(&1 =~ "'Q'"))
      assert File.read!(Path.join(out, "validacion_mapa.txt")) =~ "'Q' no está definido"
      refute File.exists?(Path.join(out, "regiones.csv"))
      refute File.exists?(Path.join(out, "mapa_regiones.svg"))
    end

    test "falta un archivo: informa sin excepción", %{tmp_dir: dir} do
      File.write!(Path.join(dir, "mapa.txt"), "A\n")
      assert {:error, {:archivos_faltantes, [ruta]}} = Mapas.ejecutar(dir, Path.join(dir, "out"))
      assert ruta =~ "paleta.csv"
    end
  end
end
