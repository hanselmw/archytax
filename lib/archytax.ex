defmodule Archytax do
  require IEx
  use GenServer
  use Archytax.Protocol.MessageTypes
  use Archytax.Protocol.Messages
  alias Archytax.Protocol.Sysex, as: Sysex
  alias Archytax.Board, as: Board
  #######
  # API #
  #######

  def start_link(device_port, opts \\ []) do
    GenServer.start_link(__MODULE__, {device_port, opts}, name: __MODULE__)
  end

  def reconnect(port, opts \\ []) do
    GenServer.call(__MODULE__, {:reconnect, {port, opts}})
  end

  def write(message) do
    GenServer.call(__MODULE__, {:send_message, message})
  end

  def set_pin_mode(pin_number, mode) do
    GenServer.call(__MODULE__, {:set_pin_mode, {pin_number, mode}})
  end

  def set_digital_pin(pin_number, val) do
    GenServer.call(__MODULE__, {:set_digital_pin, {pin_number, val}})
  end

  def read(time \\ nil) do
    GenServer.call(__MODULE__, {:read, time})
  end

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
    Board.send(board, <<@protocol_version>>) # Query protocol version
    state = %{}
    state = Map.put(state, :board, board)
    state = Map.put(state, :code_bin, <<>>)
    {:ok, state}
  end

  def handle_call({:reconnect, {port, opts}}, _from, state) do
    board = state.board
    speed = opts[:speed] || 57600
    {:ok, _response} = Board.open(state.board, port, speed, true)
    Board.send(board, <<@system_reset>>) # Reset device
    Board.send(board, <<@protocol_version>>) # Query protocol version
    new_state = %{}
    new_state = Map.put(new_state, :board, board)
    new_state = Map.put(new_state, :code_bin, <<>>)
    {:reply, :ok, new_state}
  end

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

  def handle_call({:set_pin_mode, {pin, mode}}, _from, state) do
    new_pins_map = Board.update_pin_mode(state.pins, pin, mode)
    state = state |> Map.put(:pins, new_pins_map)
    Board.send(state.board, << @pin_mode, pin, mode >>)
    {:reply, :ok, state}
  end

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

  def handle_info({:firmware_name, name}, state) do
    IO.puts name
    state = state |> Map.put(:firmware_name, name)

    Board.send(state.board, <<@start_sysex, @capability_query, @sysex_end >>) # SECOND QUERY

    {:noreply, state}
  end

  def handle_info({:capability_response, capability}, state) do
    state = state |> Map.put(:pins, capability)
    {:noreply, state}
  end

  def handle_info(anything, state) do
    IO.inspect anything
    IO.puts "I failed..."
    {:noreply, state}
  end
end
