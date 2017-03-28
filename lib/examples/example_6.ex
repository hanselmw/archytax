defmodule Examples.Example6 do
  @moduledoc """
  Show basic example of report digital port to turn ON a led when a button is pressed.
  """
  use GenServer

  # Client
  def start_link(device_port, opts \\ []) do
    GenServer.start_link(__MODULE__, {device_port, opts}, name: __MODULE__)
  end

  def get_button_value() do
    GenServer.call(__MODULE__, {:get_button_value})
  end

  # Server
  
  def init({device_port, opts }) do
    Archytax.start_link(device_port, opts)
    initial_state = %{}
    initial_state = initial_state
      |> Map.put(:button_value, 32) # Initial value
    {:ok, initial_state}
  end

  def handle_call({:get_button_value}, _from, state) do
    {:reply, {:ok, state[:button_value]}, state}
  end

  ######################
      # SETUP #
  ######################
  def handle_info({:archytax, {:ready, _anything}}, state ) do
    IO.puts "Let's go"
    Archytax.set_pin_mode(13, 0) # Input mode
    Archytax.report_digital_port(13 ,1) # Report digital port value

    spawn(fn -> loop() end)
    {:noreply, state}
  end

  def handle_info({:archytax, {:digital_read, {_pin, value}}}, state) do
    state = state 
      |> Map.put(:button_value, value)
    {:noreply, state}
  end

  def handle_info(_anything, state) do
    IO.puts "Something not useful for this one received."
    {:noreply, state}
  end

  defp loop do
    led_val = case Examples.Example6.get_button_value() do
      {:ok, 32} -> 0 # Button in standby
      {:ok , 0} -> 1 # Button pressed
    end
    Archytax.set_digital_pin(5, led_val)
    loop()
  end

end