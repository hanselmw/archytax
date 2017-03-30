defmodule Archytax.Board do
  use Bitwise
  
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

  @doc """
  Update the pin attribute `attribute` for the specified `pin` with `value`.
  returns the whole `pins_map` with the updated attribute.
  """
  def update_pin_attribute(pins_map, pin, attribute, value) do
    check_pin_usage(pin)
    case pins_map[pin] do
      # Not found pin
      nil ->
        {:error, "Pin not found"}
      # Pin found
      _map ->
        new_pin_map = Map.put(pins_map[pin], attribute, value)
        {:ok , Map.put(pins_map, pin, new_pin_map)}
    end
  end

  def update_analog_channel_value(pins_map, analog_channel, val) do
    pin = Enum.find_index(pins_map, fn({_key_number, pin_data}) -> pin_data[:analog_channel] == analog_channel end) # Find pin number for analog channel
    {:ok, new_pins_map} = update_pin_attribute(pins_map, pin, :value, val)
    new_pins_map
  end

  def report_analog_pin(pins_map, analog_channel, report_value) do
    pin = Enum.find_index(pins_map, fn({_key_number, pin_data}) -> pin_data[:analog_channel] == analog_channel end)
    {:ok, new_pins_map} = update_pin_attribute(pins_map, pin, :report, report_value)
    new_pins_map
  end


  # Parse incoming digital messages
  def parse_digital_message(new_pins_map, _port, _port_value, 8) do
    new_pins_map # return the new pins map with the values updated for the input pins.
  end

  # TODO Find a way to set the counter with default value 0 without elixir warning.
  def parse_digital_message(pins, port, port_value, counter) do
    index = 8 * port + counter
    pin_record = Map.get(pins, index)
    pins = 
      if pin_record && (pin_record[:mode] == 0 || pin_record[:mode] == 11) do # If pin is set as digital input or pullup get the digital value reading
        digital_value = (port_value >>> (counter &&& 0x07)) &&& 0x01 # Get the digital value for the pin number IN the port. (0..8)
        update_pin_attribute(pins, index, :value, digital_value) # updated pins map
      else
        pins # this pin reamins the same
      end
    parse_digital_message(pins, port, port_value, counter + 1)
  end

  defp check_pin_usage(pin) when pin == 0 or pin == 1 do
    IO.puts ("WARNING: It seems that you are manipulating pin #{pin}.")
  end

  defp check_pin_usage(pin) do
    :ok
  end

end