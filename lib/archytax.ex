defmodule Archytax do
  require IEx
  use GenServer
  alias Archytax.Protocol.Sysex, as: Sysex
  alias Archytax.Board, as: Board
  #######
  # API #
  #######

  def start_link(device_port, opts \\ []) do
    GenServer.start_link(__MODULE__, {device_port, opts}, name: __MODULE__)
  end

  def write(message) do
    GenServer.call(__MODULE__, {:send_message, message})
  end

  def read(time \\ nil) do
    GenServer.call(__MODULE__, {:read, time})
  end

  ######################
  # Callback Functions #
  ######################
  def init({device_port, opts }) do
    speed = opts[:speed] || 57600
    {:ok, board} = Board.init
    {:ok, _response} = Board.open(board, device_port, speed, true)
    Nerves.UART.write(board, <<0xFF>>)
    Nerves.UART.write(board, <<0xF9>>)
    state = %{}
    state = Map.put(state, :board, board)
    state = Map.put(state, :code_bin, <<>>)
    {:ok, state}
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

  # Messages from board to serial
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
    {:noreply, state}
  end
end
