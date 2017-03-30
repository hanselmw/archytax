defmodule Archytax.Utilities do
  @moduledoc """
  A wide variety of functions, from conversions to common patterns.
  """

  @doc """
  Get true voltage from analog reading. Useful for temperature readings.
  """
  def getVoltage(analog_value) do
    analog_value * 0.004882814
  end

  @doc """
  Get the equivalent value from `value` in the `{to_min, to_max}` based on the original `value`
  in the range `{from_min, from_max}`

  You can send the range limits as four arguments
  Or directly as ranges
  ## Examples

      iex> Archytax.Utilities.mapRange(800, 0,1023, 0,255)
      199
      
      iex> Archytax.Utilities.mapRange(800, 0..1023, 0..255)
      199

  """
  def mapRange(value, from_range, to_range) do
    from_min..from_max = from_range
    to_min..to_max = to_range
    (value - from_min) * (to_max - to_min) / (from_max - from_min) + to_min |> round
  end

  def mapRange(value, from_min, from_max, to_min, to_max) do
    (value - from_min) * (to_max - to_min) / (from_max - from_min) + to_min |> round
  end

  @doc """
  Simple alias for timer sleep. Delay on miliseconds
  """
  def delay(miliseconds) do
    :timer.sleep(miliseconds)
  end

  @doc """
  Simple wrapper for timer.sleep into microseconds
  """
  def delay_microseconds(microseconds) do
    :timer.sleep (microseconds/1000) |> Float.floor |> round
  end

end