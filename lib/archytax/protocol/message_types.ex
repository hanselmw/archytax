defmodule Archytax.Protocol.MessageTypes do
  defmacro __using__(_) do
    quote do
      # Message Types
      @analog_message       0xE0 # LSB(bits 0-6)
      @digital_message      0x90 # LSB(bits 0-6)
      @report_analog_pin    0xC0 # disable/enable(0/1)
      @report_digital_port  0xD0 # disable/enable(0/1)
      @start_sysex          0xF0 # Start sysex
      @pin_mode             0xF4 # Set pin mode
      @set_digital_pin      0xF5 #
      @sysex_end            0xF7 # End sysex
      @protocol_version     0xF9 # first byte major version, second byte minor version
      @system_reset         0xFF #

      # Two byte digital data format, second nibble of byte 0 gives the port number (eg 0x92 is the third port, port 2)
      @digital_message_range 0x90..0x9F
      # Analog 14-bit data format
      @analog_message_range  0xE0..0xEF
    end
  end
end
