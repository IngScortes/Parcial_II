defmodule Escritor do
  def volcar(fragmentos, ruta) do
    crear_carpeta(ruta)

    fragmentos
    |> Stream.into(File.stream!(ruta))
    |> Stream.run()

    ruta
  end

  def abrir(ruta) do
    crear_carpeta(ruta)
    File.open!(ruta, [:write, :utf8])
  end

  def escribir(dispositivo, contenido), do: IO.write(dispositivo, contenido)

  def cerrar(dispositivo), do: File.close(dispositivo)

  def linea(contenido), do: [contenido, "\n"]

  def con_encabezado(fragmentos, texto), do: Stream.concat([linea(texto)], fragmentos)

  defp crear_carpeta(ruta) do
    ruta
    |> Path.dirname()
    |> File.mkdir_p!()
  end
end
