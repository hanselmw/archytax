defmodule Archytax.Midi do
use Bitwise
  @moduledoc """
  Note ON and Note OFF interaction.
  """
  @midi %{
    C0: 0,
    C1: 12,
    C2: 24,
    C3: 36,
    C4: 48,
    C5: 60,
    C6: 72,
    C7: 84,
    C8: 96,
    C9: 108,
    C10: 120,
    CS0: 1,
    CS1: 13,
    CS2: 25,
    CS3: 37,
    CS4: 49,
    CS5: 61,
    CS6: 73,
    CS7: 85,
    CS8: 97,
    CS9: 109,
    CS10: 121,
    D0: 2,
    D1: 14,
    D2: 26,
    D3: 38,
    D4: 50,
    D5: 62,
    D6: 74,
    D7: 86,
    D8: 98,
    D9: 110,
    D10: 122,
    DS0: 3,
    DS1: 15,
    DS2: 27,
    DS3: 39,
    DS4: 51,
    DS5: 63,
    DS6: 75,
    DS7: 87,
    DS8: 99,
    DS9: 111,
    DS10: 123,
    E0: 4,
    E1: 16,
    E2: 28,
    E3: 40,
    E4: 52,
    E5: 64,
    E6: 76,
    E7: 88,
    E8: 100,
    E9: 112,
    E10: 124,
    F0: 5,
    F1: 17,
    F2: 29,
    F3: 41,
    F4: 53,
    F5: 65,
    F6: 77,
    F7: 89,
    F8: 101,
    F9: 113,
    F10: 125,
    FS0: 6,
    FS1: 18,
    FS2: 30,
    FS3: 42,
    FS4: 54,
    FS5: 66,
    FS6: 78,
    FS7: 90,
    FS8: 102,
    FS9: 114,
    FS10: 126,
    G0: 7,
    G1: 19,
    G2: 31,
    G3: 43,
    G4: 55,
    G5: 67,
    G6: 79,
    G7: 91,
    G8: 103,
    G9: 115,
    G10: 127,
    GS0: 8,
    GS1: 20,
    GS2: 32,
    GS3: 44,
    GS4: 56,
    GS5: 68,
    GS6: 80,
    GS7: 92,
    GS8: 104,
    GS9: 116,
    A0: 9,
    A1: 21,
    A2: 33,
    A3: 45,
    A4: 57,
    A5: 69,
    A6: 81,
    A7: 93,
    A8: 105,
    A9: 117,
    AS0: 10,
    AS1: 11,
    AS2: 34,
    AS3: 46,
    AS4: 58,
    AS5: 70,
    AS6: 82,
    AS7: 94,
    AS8: 106,
    AS9: 118,
    B0: 11,
    B1: 23,
    B2: 35,
    B3: 47,
    B4: 59,
    B5: 71,
    B6: 83,
    B7: 95,
    B8: 107,
    B9: 119,
  }

  def noteOn(pitch, velocity) do
    Archytax.write(0x90)
    Archytax.write(pitch)
    Archytax.write(velocity)
  end

  def noteOff(pitch, velocity) do
    Archytax.write(0x80)
    Archytax.write(pitch)
    Archytax.write(velocity)
  end

  def polyphonicKeyPressure(pitch, velocity) do
    Archytax.write(0xA0)
    Archytax.write(pitch)
    Archytax.write(velocity)
  end

  def channelPressure(pressure) do
    Archytax.write(0xD0)
    Archytax.write(pressure)
  end

  def pitchBendChange(value) do
    lowValue = value &&& 0x7F
    highValue = value >>> 7
    Archytax.write(0xE0)
    Archytax.write(lowValue)
    Archytax.write(highValue)
  end
  
end