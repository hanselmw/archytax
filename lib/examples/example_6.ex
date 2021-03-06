defmodule Examples.Example6 do
  @moduledoc """
  Show basic example of report digital port to turn ON a led when a button is pressed.
  """
  use GenServer

  # Client
  def start_link(device_port, opts \\ []) do
    GenServer.start_link(__MODULE__, {device_port, opts}, name: __MODULE__)
  end

  def get_button_value(pin) do
    GenServer.call(__MODULE__, {:get_button_value, pin})
  end

  # Server
  
  def init({device_port, opts }) do
    Archytax.start_link(device_port, opts)
    initial_state = %{}
    {:ok, initial_state}
  end

  def handle_call({:get_button_value, pin}, _from, state) do
    {:ok, pins} = Archytax.get_pins
    digital_value = get_in(pins, [pin, :value]) || 0
    {:reply, {:ok, digital_value}, state}
  end

  ######################
      # SETUP #
  ######################
  def handle_info({:archytax, {:ready, _anything}}, state ) do
    IO.puts "Let's go"
    Archytax.set_pin_mode(13, 1)
    Archytax.set_pin_mode(7, 0) # Input mode
    Archytax.report_digital_port(7 ,1) # Report digital port value

    spawn(fn -> loop() end)
    {:noreply, state}
  end

  def handle_info(_anything, state) do
    IO.puts "Something not useful for this one received."
    {:noreply, state}
  end

  defp loop do
    # button2_val = Examples.Example6.get_button_value(4)
    led_val = case Examples.Example6.get_button_value(7) do
      {:ok, 0} -> 1
      {:ok, 1} -> 0
    end
    Archytax.set_digital_pin(13, led_val)
    loop()
  end

end