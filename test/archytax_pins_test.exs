defmodule ArchytaxConnectionTest do
  @example_state %{
    version: {2, 5},
    firmware_name: "StandardFirmata.ino",
    pins: %{
      0 => %{value: 0, mode: 16},
      1 => %{value: 0, mode: 16},
      2 => %{value: 0, mode: 16},
      3 => %{value: 0, mode: 16},
      4 => %{value: 0, mode: 16},
      5 => %{value: 0, mode: 16},
      6 => %{value: 0, mode: 16},
      7 => %{value: 0, mode: 16},
      8 => %{value: 0, mode: 16},
      9 => %{value: 0, mode: 16},
    }
  }
  use ExUnit.Case

  test "Do not allow set mode for unexisting pin." do
    {:reply, {response, _message}, _state} = Archytax.handle_call({:set_pin_mode, {21, 1}}, self(), @example_state)
    assert response == :error
  end

  test "Do not allow to set a value on unexisting pin" do
    {:reply, {response, _message}, _state} = Archytax.handle_call({:set_digital_pin, {21, 1}}, self(), @example_state)
    assert response == :error
  end

  test "Do not allow to report digital pin on unexisting pin" do
    {:reply, {response, _message}, _state} = Archytax.handle_call({:report_digital_port, {21, 1}}, self(), @example_state)
    assert response == :error
  end

  test "Get pins" do
    {:reply, {:ok, pins}, _state} = Archytax.handle_call({:get_pins}, self(), @example_state)
    assert get_in(pins, [3, :value]) == get_in(@example_state, [:pins, 3, :value])
  end

end
