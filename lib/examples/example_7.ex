defmodule Examples.Example7 do
  @moduledoc """
  Show usage of multiple digital inputs buttons to manipulate the leds blink.
  """
  use GenServer

  # Client
  def start_link(device_port, opts \\ []) do
    GenServer.start_link(__MODULE__, {device_port, opts}, name: __MODULE__)
  end

  def get_button_value(pin) do
    GenServer.call(__MODULE__, {:get_button_value, pin})
  end

  def test() do
    GenServer.call(__MODULE__, :test)
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

  def handle_call(:test, _from, state) do
    {:ok, pins} = Archytax.get_pins
    {:reply, {:ok, pins}, state}
  end

  ######################
      # SETUP #
  ######################
  def handle_info({:archytax, {:ready, _anything}}, state ) do
    IO.puts "Let's go"
    Archytax.set_pin_mode(13, 1)
    Archytax.set_pin_mode(10, 1)
    Archytax.set_pin_mode(8, 1)

    Archytax.set_pin_mode(7, 0) # Input mode
    Archytax.set_pin_mode(4, 0) # Input mode
    Archytax.report_digital_port(7 ,1) # Report digital port value
    Archytax.report_digital_port(4 ,1) # Report digital port value

    spawn(fn -> loop() end)
    {:noreply, state}
  end

  def handle_info(_anything, state) do
    {:noreply, state}
  end

  defp loop do
    led_val = case Examples.Example7.get_button_value(7) do
      {:ok, 0} -> 1
      {:ok, 1} -> 0
    end
    led_val2 = case Examples.Example7.get_button_value(4) do
      {:ok, 0} -> 1
      {:ok, 1} -> 0
    end

    led_val3 = 
      if led_val == 1 && led_val2 == 1 do
        1
      else
        0
      end
    Archytax.set_digital_pin(8, led_val)
    Archytax.set_digital_pin(10, led_val2)
    Archytax.set_digital_pin(13, led_val3)
    loop()
  end

end