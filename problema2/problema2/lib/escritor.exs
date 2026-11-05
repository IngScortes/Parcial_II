defmodule Parcial2.Escritor do
  @moduledoc """
  QUÉ: escribir salidas creando/reemplazando el archivo en cada ejecución y
  sin armar nunca un único string con todo el contenido.

  CÓMO: dos modalidades.

    * `volcar/2`: un Stream de fragmentos (iodata) se canaliza con
      `Stream.into(File.stream!(ruta))`; el archivo se trunca al abrirse.
    * `abrir/1`, `escribir/2`, `cerrar/1`: dispositivo abierto para cuando un
      mismo ciclo alimenta varios archivos a la vez.
  """

  @doc "Escribe un Stream/enumerable de fragmentos (iodata) en `ruta`."
  def volcar(fragmentos, ruta) do
    ruta |> Path.dirname() |> File.mkdir_p!()
    fragmentos |> Stream.into(File.stream!(ruta)) |> Stream.run()
    ruta
  end

  @doc "Abre `ruta` para escritura (reemplaza si existe)."
  def abrir(ruta) do
    ruta |> Path.dirname() |> File.mkdir_p!()
    File.open!(ruta, [:write, :utf8])
  end

  def escribir(dispositivo, iodata), do: IO.write(dispositivo, iodata)
  def cerrar(dispositivo), do: File.close(dispositivo)

  @doc "Termina un fragmento con salto de línea."
  def linea(iodata), do: [iodata, "\n"]
end
