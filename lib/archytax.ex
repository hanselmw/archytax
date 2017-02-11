defmodule Archytax do
  require IEx
  use GenServer
  use Archytax.Protocol.Messages
  use Archytax.Protocol.MessageTypes
  use Archytax.Protocol.Modes
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
    {:noreply, state}
  end
end
