defmodule Archytax.Sensors.Temperature do
  @moduledoc """
  Temperature Sensors handy functions
  """

  @doc """
  Get temperature from voltage in the specified unit of measurement `atom` for temperature.

  Valid temperatures: `:celsius`, `:fahrenheit`, `:kelvin`.
  ## Examples

      iex> Archytax.Sensors.Temperature.getTempFromVoltage(:celsius, 0.92773466)
      42.7734660

  """
  def getTempFromVoltage(:celsius, voltage) do
    (voltage - 0.5) * 100.0
  end

  def getTempFromVoltage(:fahrenheit, voltage) do
    ((voltage - 0.5) * 100.0) * (9.0/5.0) + 32.0
  end

  def getTempFromVoltage(:kelvin, voltage) do
    ((voltage - 0.5) * 100.0) +  273.15
  end


  @doc """
  Convert temperature from `atom1`, to `atom2` according to `temp` value.

  Valid temperature units: `:celsius`, `:fahrenheit`, `:kelvin`.

  ## Examples
      iex> Archytax.Sensors.Temperature.convertTemp(:celsius, :kelvin, 31.0)
      304.15

      iex> Archytax.Sensors.Temperature.convertTemp(:kelvin, :celsius, 304.15)
      31.0
  """
  def convertTemp(:celsius, :fahrenheit, temp) do
    temp * (9.0/5.0) + 32.0
  end

  def convertTemp(:celsius, :kelvin, temp) do
    temp + 273.15
  end

  def convertTemp(:fahrenheit, :celsius, temp) do
     (temp - 32) * 5.0/9.0
  end

  def convertTemp(:fahrenheit, :kelvin, temp) do
    (temp + 459.67) * 5.0/9.0
  end

  def convertTemp(:kelvin, :celsius, temp) do
    temp - 273.15
  end

  def convertTemp(:kelvin, :fahrenheit, temp) do
    temp * (9.0/5.0) - 459.67
  end

end