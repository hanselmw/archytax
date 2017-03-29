defmodule Archytax.Board do
  def init do
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
      {:error, :einval} ->
        {:error, "Configurations invalid."}
      {:error, something_else} ->
        {:error, something_else}
      _ ->
        {:error, "Unknown error"}
    end
  end

  def send(pid, message) do
    Nerves.UART.write(pid, message)
  end

  def read(pid, ms \\ 60000) do
    Nerves.UART.read(pid, ms)
  end

  def update_pin_mode(pins_map, pin, mode) do
    new_pin_map = Map.put(pins_map[pin], :mode, mode)
    Map.put(pins_map, pin, new_pin_map)
  end

  def update_pin_value(pins_map, pin, val) do
    new_pin_map = Map.put(pins_map[pin], :value, val)
    Map.put(pins_map, pin, new_pin_map)
  end

  def update_analog_channel_value(pins_map, analog_channel, val) do
    pin = Enum.find_index(pins_map, fn({_key_number, pin_data}) -> pin_data[:analog_channel] == analog_channel end) # Find pin number for analog channel
    new_pin_map = Map.put(pins_map[pin], :value, val)
    Map.put(pins_map, pin, new_pin_map)
  end
end