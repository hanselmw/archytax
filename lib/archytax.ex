defmodule Archytax do
  @moduledoc """
  This is the Main Module of the Library, 
  it serves as a bridge for the interface and the Board, 
  also manage the messages coming from the connected devices. 
  """

  require IEx
  use GenServer
  use Archytax.Protocol.MessageTypes
  use Archytax.Protocol.Messages
  alias Archytax.Protocol.Sysex, as: Sysex
  alias Archytax.Board, as: Board
  ############################
  ############ API ###########
  ############################


  def start_link(device_port, opts \\ []) do
    opts = Keyword.put(opts, :interface, self()) # Set interface PID as the original caller or start_link
    GenServer.start_link(__MODULE__, {device_port, opts}, name: __MODULE__)
  end

  @doc """
  Try to create a new connection using the existing Board GenServer
  """
  def reconnect(port, opts \\ []) do
    GenServer.call(__MODULE__, {:reconnect, {port, opts}})
  end

  @doc """
  Send any kind of information to the Board.
  """
  def write(message) do
    GenServer.call(__MODULE__, {:send_message, message})
  end

  @doc """
  Issue a sysex command message to the Board.
  command is always necessary, data is optional for some commands.
  """
  def sysex_write(command, data \\ "") do
    GenServer.call(__MODULE__, {:send_sysex_message, {command, data}})
  end

  @doc """
  Set the pin mode of the specified mode, for pin modes codes, check firmata documentation:
  https://github.com/firmata/protocol/blob/master/protocol.md
  """
  def set_pin_mode(pin_number, mode) do
    GenServer.call(__MODULE__, {:set_pin_mode, {pin_number, mode}})
  end

  @doc """
  Set the digital value for the specified pin.
  """
  def set_digital_pin(pin_number, val) do
    GenServer.call(__MODULE__, {:set_digital_pin, {pin_number, val}})
  end

  @doc """
  Not gonna make it to the final version.
  """
  def read(time \\ nil) do
    GenServer.call(__MODULE__, {:read, time})
  end

  @doc """
  Get the current state of Archytax.
  """
  def get_all() do
    GenServer.call(__MODULE__, {:get_all})
  end

  ######################
  # Callback Functions #
  ######################
  def init({device_port, opts }) do
    speed = opts[:speed] || 57600
    {:ok, board} = Board.init
    {:ok, _response} = Board.open(board, device_port, speed, true)
    Board.send(board, <<@system_reset>>) # Reset device
    state = %{}
    state = Map.put(state, :board, board)
    state = Map.put(state, :code_bin, <<>>)
    state = Map.put(state, :interface, opts[:interface])
    {:ok, state}
  end

  def handle_call({:reconnect, {port, opts}}, _from, state) do
    board = state.board
    speed = opts[:speed] || 57600
    {:ok, _response} = Board.open(state.board, port, speed, true)
    Board.send(board, <<@system_reset>>) # Reset device
    new_state = %{}
    new_state = Map.put(new_state, :board, board)
    new_state = Map.put(new_state, :code_bin, <<>>)
    {:reply, :ok, new_state}
  end

  # Send message to the Board
  def handle_call({:send_message, message}, _from, state) do
    case Board.send(state.board, message) do
      :ok ->
        {:reply, :ok , state}
      {:error, reason} ->
        {:reply, {:error, reason}, state}
      _ ->
        {:reply, {:error, "Unknown Reason"}, state}
    end
  end

  # Send sysex message command without data.
  def handle_call({:send_sysex_message, {command, ""}}, _from, state) do
    case Board.send(state.board, <<@start_sysex, command, @sysex_end>>) do
      :ok ->
        {:reply, :ok , state}
      {:error, reason} ->
        {:reply, {:error, reason}, state}
      _ ->
        {:reply, {:error, "Unknown Reason"}, state}
    end
  end

  # Send sysex message command with data.
  def handle_call({:send_sysex_message, {command, data}}, _from, state) do
    case Board.send(state.board, <<@start_sysex, command, data, @sysex_end>>) do
      :ok ->
        {:reply, :ok , state}
      {:error, reason} ->
        {:reply, {:error, reason}, state}
      _ ->
        {:reply, {:error, "Unknown Reason"}, state}
    end
  end

  # ...
  def handle_call({:read, time}, _from, state) do
    case Board.read(state.board, time) do
      {:ok, data} ->
        {:reply, {:ok, data}, state}
      {:error, reason} ->
        {:reply, {:error, reason}, state}
      _ ->
        {:reply, {:error, "Unknown reason"}, state} 
    end
  end

  # Update pins map information and set the pin mode as specified.
  def handle_call({:set_pin_mode, {pin, mode}}, _from, state) do
    new_pins_map = Board.update_pin_mode(state.pins, pin, mode)
    state = state |> Map.put(:pins, new_pins_map)
    Board.send(state.board, << @pin_mode, pin, mode >>)
    {:reply, :ok, state}
  end

  # Update pins map and set digital value on specified pin.
  def handle_call({:set_digital_pin, {pin, val}}, _from, state) do
    new_pins_map = Board.update_digital_pin_val(state.pins, pin, val)
    state = state |> Map.put(:pins, new_pins_map)
    Board.send(state.board, << @set_digital_pin, pin, val >>)
    {:reply, :ok, state}
  end

  def handle_call({:get_all}, _from, state) do
    {:reply, {:ok, state}, state}
  end

  ###########################
  # Info messages Functions #
  ###########################

  # Messages from board to serial
  def handle_info({:nerves_uart, port, {:error, :eio}}, state ) do
    IO.puts "The connection with the device on #{port} has been lost."
    {:noreply, state}
  end

  def handle_info({:nerves_uart, _port, data}, state) do
    IO.inspect data
    outbox = []
    new_byte_string = << >>
    bytes_string = state.code_bin <> data
    {outbox, new_byte_string} = Sysex.parse({outbox, << >>}, bytes_string)
    state = Map.put(state, :code_bin, new_byte_string)
    Enum.each(outbox, fn(instruction) -> send(self(), instruction) end)
    {:noreply, state}
  end


  def handle_info({:only_version, major, minor }, state) do
    IO.puts "Version #{major}.#{minor}"
    state = state |> Map.put(:version, {major, minor})
    {:noreply, state}
  end

  def handle_info({:firmware_info, {mayor_v, minor_v, firmware_name}}, state) do
    IO.puts "#{firmware_name}, version #{mayor_v}.#{minor_v}"
    state = state |> Map.put(:version, {mayor_v, minor_v})
    state = state |> Map.put(:firmware_name, firmware_name)

    contact_interface(state[:interface], {:firmware_info, "#{firmware_name}, version #{mayor_v}.#{minor_v}" })

    Board.send(state.board, <<@start_sysex, @capability_query, @sysex_end >>) # SECOND QUERY

    {:noreply, state}
  end

  def handle_info({:capability_response, capability}, state) do
    state = state |> Map.put(:pins, capability)
    Board.send(state.board, << @start_sysex, @analog_mapping_query, @sysex_end >>)
    {:noreply, state}
  end

  def handle_info({:analog_response, analog_data}, state) do
    pins = state.pins
    new_pins = MapUtils.deep_merge(pins, analog_data)
    state = state 
      |> Map.put(:pins, new_pins)
    IO.puts "App is ready here."
    contact_interface(state[:interface], {:ready, state[:pins]})
    {:noreply, state}
  end

  def handle_info(anything, state) do
    IO.inspect anything
    IO.puts "I failed..."
    {:noreply, state}
  end

  defp contact_interface(interface_pid, info) do
    send(interface_pid, {:archytax, info})
  end
end
