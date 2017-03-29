defmodule ArchytaxConnectionTest do
  @example_state %{
    version: {2, 5},
    firmware_name: "StandardFirmata.ino",
    pins: %{
      0 => %{value: 0, mode: 16},
      1 => %{value: 0, mode: 16},
      2 => %{value: 0, mode: 16},
      3 => %{value: 0, mode: 16},
    }
  }
  use ExUnit.Case

  test "Do not allow set mode for unexisting pin." do
    {:reply, {response, _message}, _state} = Archytax.handle_call({:set_pin_mode, {13, 1}}, self(), @example_state)
    assert response == :error
  end

  test "Get pins" do
    {:reply, {:ok, pins}, _state} = Archytax.handle_call({:get_pins}, self(), @example_state)
    assert get_in(pins, [3, :value]) == get_in(@example_state, [:pins, 3, :value])
  end

end
