defmodule Archytax.Board do

  def start_link do
    Nerves.UART.start_link
  end

  def open(pid, device, speed, active \\ true) do
    case Nerves.UART.open(pid, device, speed: speed, active: active) do
      :ok ->
        {:ok, "Device connected"}
      {:error, :enoent} ->
        {:error, "The specified port couldn’t be found."}
      {:error, :eagain} ->
        {:error, "The specified port is already open."}
      {:error, :eacces} ->
        {:error, "Permission denied on specified port."}
      _ ->
        {:error, "Unknown error"}
    end
  end
end