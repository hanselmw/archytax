defmodule Archytax.Tone do
  @moduledoc """
  Define the tones used by Tone.play to interact with components like the Piezo.
  """
  @tones %{
           B0:  31,
           C1:  33,
           CS1: 35,
           D1:  37,
           DS1: 39,
           E1:  41,
           F1:  44,
           FS1: 46,
           G1:  49,
           GS1: 52,
           A1:  55,
           AS1: 58,
           B1:  62,
           C2:  65,
           CS2: 69,
           D2:  73,
           DS2: 78,
           E2:  82,
           F2:  87,
           FS2: 93,
           G2:  98,
           GS2: 104,
           A2:  110,
           AS2: 117,
           B2:  123,
           C3:  131,
           CS3: 139,
           D3:  147,
           DS3: 156,
           E3:  165,
           F3:  175,
           FS3: 185,
           G3:  196,
           GS3: 208,
           A3:  220,
           AS3: 233,
           B3:  247,
           C4:  262,
           CS4: 277,
           D4:  294,
           DS4: 311,
           E4:  330,
           F4:  349,
           FS4: 370,
           G4:  392,
           GS4: 415,
           A4:  440,
           AS4: 466,
           B4:  494,
           C5:  523,
           CS5: 554,
           D5:  587,
           DS5: 622,
           E5:  659,
           F5:  698,
           FS5: 740,
           G5:  784,
           GS5: 831,
           A5:  880,
           AS5: 932,
           B5:  988,
           C6:  1047,
           CS6: 1109,
           D6:  1175,
           DS6: 1245,
           E6:  1319,
           F6:  1397,
           FS6: 1480,
           G6:  1568,
           GS6: 1661,
           A6:  1760,
           AS6: 1865,
           B6:  1976,
           C7:  2093,
           CS7: 2217,
           D7:  2349,
           DS7: 2489,
           E7:  2637,
           F7:  2794,
           FS7: 2960,
           G7:  3136,
           GS7: 3322,
           A7:  3520,
           AS7: 3729,
           B7:  3951,
           C8:  4186,
           CS8: 4435,
           D8:  4699,
           DS8: 4978
        }


  def play(pin, tone, tempo \\ 1)

  def play(pin, tone, tempo) when is_binary(tone) do
    tone_atom = String.to_atom(tone)
    play(pin, tone_atom, tempo)
  end

  def play(pin, 0, _tempo) do
    note_duration = 83 / 1 |> Float.floor |> round

    delay_value = 0
    num_cycles = 0

    IO.puts "Frequency: 0 at #{note_duration}, delay value is : #{delay_value}"
    IO.puts "Cycles: #{num_cycles}"

    write_note(pin, delay_value, num_cycles)
  end

  def play(pin, tone, tempo) do
    frequency = cond do
      is_integer(tone) && tone != 0 ->
        tone
      true ->
        @tones[tone]
    end
    note_duration = 1000 / tempo |> Float.floor |> round

    delay_value = 1000000 / frequency / 2 |> Float.floor |> round
    num_cycles = frequency * note_duration / 1000 |> Float.floor |> round

    IO.puts "Frequency: #{@tones[tone]} at #{note_duration}, delay value is : #{delay_value}"
    IO.puts "Cycles: #{num_cycles}"

    write_note(pin, delay_value, num_cycles)
  end

  def write_note(_pin, _delay_value, 0) do
    :ok
  end

  def write_note(pin, delay_value, cycle) do
    Archytax.set_digital_pin(pin, 1)
    Archytax.Utilities.delay_microseconds(delay_value)
    Archytax.set_digital_pin(pin, 0)
    Archytax.Utilities.delay_microseconds(delay_value)
    write_note(pin, delay_value, cycle - 1)
  end
  
end