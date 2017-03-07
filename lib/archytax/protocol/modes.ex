defmodule Archytax.Protocol.Modes do
  defmacro __using__(_) do
    quote do
      @input 0x00
      @output 0x01
      @analog 0x02
      @pwm 0x03
      @servo 0x04
      @shift 0x05
      @i2c 0x06
      @onewire 0x07
      @stepper 0x08
      @encoder 0x09
      @serial 0x0a
      @input_pullup 0x0b
      @ignore 0x7f
      @ping_read 0x75
      @unknown 0x10

      @modes [
        @input,
        @output,
        @analog,
        @pwm,
        @servo,
        @shift,
        @i2c,
        @onewire,
        @stepper,
        @encoder,
        @serial,
        @input_pullup,
        @ignore,
        @ping_read,
        @unknown
      ]
    end
  end
end

