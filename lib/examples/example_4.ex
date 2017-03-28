defmodule Examples.Example4 do
  @moduledoc """
  Show the simple usage of a TMP/Dallas temperature sensor getting the value from analog read and print it
  on a specified interval
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

  def handle_info({:archytax, {:ready, _anything}}, state ) do
    IO.puts "Let's go"
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

  defp loop do
    IO.puts("Begin")
    voltage = getVoltage()
    IO.inspect voltage
    degreesC = getCelsius(voltage)
    degreesF = getFahrenheit(degreesC)
    IO.puts "Celsius: #{degreesC} / Fahrenheit: #{degreesF}"
    :timer.sleep 2000
    loop()
  end

  defp getVoltage do
    {:ok, analog_val} = Examples.Example4.get_analog_value()
    analog_val * 0.004882814
  end

  defp getCelsius(voltage) do
    (voltage - 0.5) * 100.0
  end

  defp getFahrenheit(celsius) do
    celsius * (9.0/5.0) + 32.0
  end

end