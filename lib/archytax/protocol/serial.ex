defmodule Archytax.Protocol.Serial do
  defmacro __using__(_) do
    quote do
      @HW_SERIAL0 = 0x00
      @HW_SERIAL1 = 0x01
      @HW_SERIAL2 = 0x02
      @HW_SERIAL3 = 0x03

      @SW_SERIAL0 = 0x08
      @SW_SERIAL1 = 0x09
      @SW_SERIAL2 = 0x0A
      @SW_SERIAL3 = 0x0B
    end
  end
end