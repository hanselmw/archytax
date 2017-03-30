defmodule ArchytaxConnectionTest do
  use ExUnit.Case
  @example_state %{
    version: {2, 5},
    firmware_name: "StandardFirmata.ino",
    pins: %{
      0 => %{value: 0, mode: 16, report: 0},
      1 => %{value: 0, mode: 16, report: 0},
      2 => %{value: 0, mode: 16, report: 0},
      3 => %{value: 0, mode: 16, report: 0},
      4 => %{value: 0, mode: 16, report: 0},
      5 => %{value: 0, mode: 16, report: 0},
      6 => %{value: 0, mode: 16, report: 0},
      7 => %{value: 0, mode: 16, report: 0},
      8 => %{value: 0, mode: 16, report: 0},
      9 => %{value: 0, mode: 16, report: 0},
    }
  }

  #########################################
  ############## BLACK BOX ################
  #########################################

  # Successful calls

  test "Set mode for pin." do
    {:reply, response, _state} = Archytax.handle_call({:set_pin_mode, {8, 1}}, self(), Map.put(@example_state, :board, create_placeholder_board()) )
    assert response == :ok
  end

  test "Set digital pin value." do
    {:reply, response, _state} = Archytax.handle_call({:set_digital_pin, {8, 1}}, self(), Map.put(@example_state, :board, create_placeholder_board()) )
    assert response == :ok
  end

  test "Report digital port." do
    {:reply, response, _state} = Archytax.handle_call({:report_digital_port, {8, 1}}, self(), Map.put(@example_state, :board, create_placeholder_board()) )
    assert response == :ok
  end

  test "Digital write." do
    {:reply, response, _state} = Archytax.handle_call({:digital_write, {8, 1}}, self(), Map.put(@example_state, :board, create_placeholder_board()) )
    assert response == :ok
  end

  test "Analog write." do
    {:reply, response, _state} = Archytax.handle_call({:analog_write, {8, 1}}, self(), Map.put(@example_state, :board, create_placeholder_board()) )
    assert response == :ok
  end

  # Error calls

  test "Do not allow set mode for unexisting pin." do
    {:reply, {response, _message}, _state} = Archytax.handle_call({:set_pin_mode, {21, 1}}, self(), @example_state)
    assert response == :error
  end

  test "Do not allow to set a value on unexisting pin" do
    {:reply, {response, _message}, _state} = Archytax.handle_call({:set_digital_pin, {21, 1}}, self(), @example_state)
    assert response == :error
  end

  test "Do not allow to send digital message on unexisting pin" do
    {:reply, {response, _message}, _state} = Archytax.handle_call({:digital_write, {21, 1}}, self(), @example_state)
    assert response == :error
  end

  test "Do not allow to report digital pin on unexisting pin" do
    {:reply, {response, _message}, _state} = Archytax.handle_call({:report_digital_port, {21, 1}}, self(), @example_state)
    assert response == :error
  end

  test "Do not allow to send analog message on unexisting pin" do
    {:reply, {response, _message}, _state} = Archytax.handle_call({:analog_write, {21, 1}}, self(), @example_state)
    assert response == :error
  end

  #########################################
  ############## WHITE BOX ################
  #########################################

  test "Check pin mode after update." do
    new_state = Map.put(@example_state, :board, create_placeholder_board())
    {:reply, :ok , state} = Archytax.handle_call({:set_pin_mode, {8, 1}}, self(), new_state)
    assert get_in(state, [:pins, 8, :mode]) == 1
  end

  test "Check digital pin value after update." do
    new_state = Map.put(@example_state, :board, create_placeholder_board())
    {:reply, :ok , state} = Archytax.handle_call({:set_digital_pin, {8, 1}}, self(), new_state)
    assert get_in(state, [:pins, 8, :value]) == 1
  end

  test "Check digital pin value after digital write." do
    new_state = Map.put(@example_state, :board, create_placeholder_board())
    {:reply, :ok , state} = Archytax.handle_call({:digital_write, {8, 1}}, self(), new_state)
    assert get_in(state, [:pins, 8, :value]) == 1
  end

  test "Check digital pin state after report digital port." do
    new_state = Map.put(@example_state, :board, create_placeholder_board())
    {:reply, :ok , state} = Archytax.handle_call({:report_digital_port, {8, 1}}, self(), new_state)
    assert get_in(state, [:pins, 8, :report]) == 1
  end

  test "Check pin value after analog write." do
    new_state = Map.put(@example_state, :board, create_placeholder_board())
    {:reply, :ok , state} = Archytax.handle_call({:analog_write, {8, 200}}, self(), new_state)
    assert get_in(state, [:pins, 8, :value]) == 200
  end

  test "Get pins" do
    {:reply, {:ok, pins}, _state} = Archytax.handle_call({:get_pins}, self(), @example_state)
    assert get_in(pins, [3, :value]) == get_in(@example_state, [:pins, 3, :value])
  end

  test "Get Firmware name" do
    {:reply, {:ok, current_state}, _state} = Archytax.handle_call({:get_all}, self(), @example_state)
    assert get_in(current_state, [:firmware_name]) == get_in(@example_state, [:firmware_name])
  end

  def create_placeholder_board do
    {:ok, board} = Archytax.Board.init
    board
  end
end
