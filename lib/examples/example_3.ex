defmodule Examples.Example3 do
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
      |> Map.put(:analog_channel_5, 500) # Initial value
    {:ok, initial_state}
  end

  # Simply get the current analog value for channel 5 (to simplify example)
  def handle_call({:get_analog_value}, _from, state) do
    {:reply, {:ok, state[:analog_channel_5]}, state}
  end

  # INFO

  def handle_info({:archytax, {:firmware_info, firmware_info}}, state ) do
    IO.puts "Interface says: #{firmware_info}"
    {:noreply, state}
  end

  def handle_info({:archytax, {:ready, _anything}}, state ) do
    IO.puts "Let's go"
    Archytax.set_pin_mode(13, 1)
    Archytax.report_analog_pin(5,1)

    spawn(fn -> loop() end)
    {:noreply, state}
  end

  def handle_info({:archytax, {:analog_read, {_pin, value}}}, state) do
    state = state 
      |> Map.put(:analog_channel_5, value)
    {:noreply, state}
  end

  def handle_info(_anything, state) do
    IO.puts "Something not useful for this one received."
    {:noreply, state}
  end

  defp loop do
    IO.puts("Begin")
    {:ok, analog_val} = Examples.Example3.get_analog_value()
    IO.inspect analog_val
    Archytax.set_digital_pin(13,1)
    :timer.sleep analog_val
    IO.puts("Turn off")
    Archytax.set_digital_pin(13,0)
    :timer.sleep analog_val
    loop()
  end

end