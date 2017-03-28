defmodule Examples.Example5 do
  @moduledoc """
  Show the simple usage of a Photo Resistor with a Led
  """
  use GenServer

  # Client
  def start_link(device_port, opts \\ []) do
    GenServer.start_link(__MODULE__, {device_port, opts}, name: __MODULE__)
  end

  def get_analog_value() do
    GenServer.call(__MODULE__, {:get_analog_value})
  end

  # Server
  
  def init({device_port, opts }) do
    Archytax.start_link(device_port, opts)
    initial_state = %{}
    initial_state = initial_state
      |> Map.put(:analog_channel_0, 0) # Initial value
    {:ok, initial_state}
  end

  # Simply get the current analog value for channel 5 (to simplify example)
  def handle_call({:get_analog_value}, _from, state) do
    {:reply, {:ok, state[:analog_channel_0]}, state}
  end

  # INFO

  def handle_info({:archytax, {:firmware_info, firmware_info}}, state ) do
    IO.puts "Interface says: #{firmware_info}"
    {:noreply, state}
  end

  # Setup
  def handle_info({:archytax, {:ready, _anything}}, state ) do
    IO.puts "Let's go"
    Archytax.set_pin_mode(9, 3) # PWM
    Archytax.report_analog_pin(0,1) # A0

    spawn(fn -> loop() end)
    {:noreply, state}
  end

  def handle_info({:archytax, {:analog_read, {_pin, value}}}, state) do
    state = state 
      |> Map.put(:analog_channel_0, value)
    {:noreply, state}
  end

  def handle_info(_anything, state) do
    IO.puts "Something not useful for this one received."
    {:noreply, state}
  end

  # APP Core

  defp loop do
    led_val = getLedValue() # get valid led value from the photo resistor
    Archytax.analog_write(9, led_val) # Write analog value into the led
    loop()
  end

  # Get photo resistor data and transform it into a valid analog value for the led
  defp getLedValue do
    {:ok, analog_val} = Examples.Example5.get_analog_value()
    leftSpan = 1023 # Analog value range
    righSpan = 255 # Led range

    valueScaled = (analog_val - 0)/leftSpan

    round(valueScaled * righSpan)
  end

end