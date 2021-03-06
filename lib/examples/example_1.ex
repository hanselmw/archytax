defmodule Examples.Example1 do
  @moduledoc """
  Pretty basic example of Archytax usage, set pin mode for leds on 13,10,7 to OUTPUT
  and turn them on
  """
  use GenServer

  def start_link(device_port, opts \\ []) do
    GenServer.start_link(__MODULE__, {device_port, opts}, name: __MODULE__)
  end

  def init({device_port, opts }) do
    Archytax.start_link(device_port, opts)
    {:ok, %{}}
  end

  def handle_info({:archytax, {:firmware_info, firmware_info}}, state ) do
    IO.puts "Interface says: #{firmware_info}"
    {:noreply, state}
  end

  def handle_info({:archytax, {:ready, _anything}}, state ) do
    IO.puts "Let's go"
    Archytax.set_pin_mode(13, 1)
    Archytax.set_pin_mode(10, 1)
    Archytax.set_pin_mode(7, 1)
    Archytax.set_digital_pin(13,1)
    Archytax.set_digital_pin(10,1)
    Archytax.set_digital_pin(7,1)
    {:noreply, state}
  end

  def handle_info(_anything, state) do
    IO.puts "Something not useful for this one received."
    {:noreply, state}
  end

end