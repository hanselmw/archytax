defmodule Examples.Example8 do
  @moduledoc """
  Music example with a Piezo.
  """
  @world_1_melody [
                  :E7, :E7, 0, :E7,
                  0, :C7, :E7, 0,
                  :G7, 0, 0,  0,
                  :G6, 0, 0, 0,

                  :C7, 0, 0, :G6,
                  0, 0, :E6, 0,
                  0, :A6, 0, :B6,
                  0, :AS6, :A6, 0,

                  :G6, :E7, :G7,
                  :A7, 0, :F7, :G7,
                  0, :E7, 0, :C7,
                  :D7, :B6, 0, 0,

                  :C7, 0, 0, :G6,
                  0, 0, :E6, 0,
                  0, :A6, 0, :B6,
                  0, :AS6, :A6, 0,

                  :G6, :E7, :G7,
                  :A7, 0, :F7, :G7,
                  0, :E7, 0, :C7,
                  :D7, :B6, 0, 0
                  ]

  

  @world_1_tempo [
      12, 12, 12, 12,
      12, 12, 12, 12,
      12, 12, 12, 12,
      12, 12, 12, 12,

      12, 12, 12, 12,
      12, 12, 12, 12,
      12, 12, 12, 12,
      12, 12, 12, 12,

      9, 9, 9,
      12, 12, 12, 12,
      12, 12, 12, 12,
      12, 12, 12, 12,

      12, 12, 12, 12,
      12, 12, 12, 12,
      12, 12, 12, 12,
      12, 12, 12, 12,

      9, 9, 9,
      12, 12, 12, 12,
      12, 12, 12, 12,
      12, 12, 12, 12,
      ]

  @underworld_melody [
                          :C4, :C5, :A3, :A4,
                          :AS3, :AS4, 0,
                          0,
                          :C4, :C5, :A3, :A4,
                          :AS3, :AS4, 0,
                          0,
                          :F3, :F4, :D3, :D4,
                          :DS3, :DS4, 0,
                          0,
                          :F3, :F4, :D3, :D4,
                          :DS3, :DS4, 0,
                          0, :DS4, :CS4, :D4,
                          :CS4, :DS4,
                          :DS4, :GS3,
                          :G3, :CS4,
                          :C4, :FS4, :F4, :E3, :AS4, :A4,
                          :GS4, :DS4, :B3,
                          :AS3, :A3, :GS3,
                          0, 0, 0
                        ]

  @underworld_tempo [
                      12, 12, 12, 12,
                      12, 12, 6,
                      3,
                      12, 12, 12, 12,
                      12, 12, 6,
                      3,
                      12, 12, 12, 12,
                      12, 12, 6,
                      3,
                      12, 12, 12, 12,
                      12, 12, 6,
                      6, 18, 18, 18,
                      6, 6,
                      6, 6,
                      6, 6,
                      18, 18, 18, 18, 18, 18,
                      10, 10, 10,
                      10, 10, 10,
                      3, 3, 3
                      ]

  import Archytax.Utilities
  use GenServer

  # Client
  def start_link(device_port, opts \\ []) do
    GenServer.start_link(__MODULE__, {device_port, opts}, name: __MODULE__)
  end

  # Server
  
  def init({device_port, opts }) do
    Archytax.start_link(device_port, opts)
    initial_state = %{}
    {:ok, initial_state}
  end


  ######################
      # SETUP #
  ######################
  def handle_info({:archytax, {:ready, _anything}}, state ) do
    IO.puts "Let's go"
    Archytax.set_pin_mode(3, 1)
    delay(1000)

    spawn(fn -> loop() end)
    {:noreply, state}
  end

  def handle_info(_anything, state) do
    {:noreply, state}
  end

  defp loop do
    # IEx.pry
    world_1 = Enum.zip(@world_1_melody, @world_1_tempo)
    Enum.each(world_1, &play_note/1)
    delay(5000)
    underworld = Enum.zip(@underworld_melody, @underworld_tempo)
    Enum.each(underworld, &play_note/1)
    delay(5000)
    loop()
  end

  def play_note({note, tempo}) do
    Archytax.Tone.play(3, note, tempo)
    temp = case tempo do
      0 -> 1
      _ -> tempo
    end
    note_duration = 1000 / temp
    pause_between_notes = note_duration * 1.30 |> round
    delay(pause_between_notes)
    Archytax.Tone.play(3, 0, note_duration)
  end

end