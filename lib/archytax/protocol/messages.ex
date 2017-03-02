defmodule Archytax.Protocol.Messages do
  defmacro __using__(_) do
    quote do
      use Bitwise
      # SysEx commands
      @reserved               0x00-0x0F # the first 16 bytes are reserved for custom commands
      @serial_message              0x60 # communicate with serial devices, including other boards
      @encoder_data                0x61 # reply with encoders current positions
      @analog_mapping_query        0x69 # ask for mapping of analog to pin numbers
      @analog_mapping_response     0x6A # reply with mapping info
      @capability_query            0x6B # ask for supported modes and resolution of all pins
      @capability_response         0x6C # reply with supported modes and resolution
      @pin_state_query             0x6D # ask for a pin's current mode and state (different than value)
      @pin_state_response          0x6E # reply with a pin's current mode and state (different than value)
      @extended_analog             0x6F # analog write (pwm, servo, etc) to any pin
      @servo_config                0x70 # pin number and min and max pulse
      @string_data                 0x71 # a string message with 14-bits per char
      @stepper_data                0x72 # control a stepper motor
      @onewire_data                0x73 # send an onewire read/write/reset/select/skip/search request
      @shift_data                  0x75 # shiftout config/data message (reserved - not yet implemented)
      @i2c_request                 0x76 # i2c request messages from a host to an i/o board
      @i2c_reply                   0x77 # i2c reply messages from an i/o board to a host
      @i2c_config                  0x78 # enable i2c and provide any configuration settings
      @report_firmware             0x79 # report name and version of the firmware
      @sampleing_interval          0x7A # the interval at which analog input is sampled (default = 19ms)
      @scheduler_data              0x7B # send a createtask/deletetask/addtotask/schedule/querytasks/querytask request to the scheduler
      @sysex_non_realtime          0x7E # midi reserved for non-realtime messages
      @sysex_realtime              0x7F # midi reserved for realtime messages

      @i2c_write                   B00000000
      @i2c_read                    B00001000
      @i2c_read_continuously       B00010000
      @i2c_stop_reading            B00011000
      @i2c_read_write_mode_mask    B00011000
      @i2c_10bit_address_mode_mask B00100000
      @i2c_end_tx_mask             B01000000
      @i2c_stop_tx                 1
      @i2c_restart_tx              0
      @i2c_max_queries             8
      @i2c_register_not_specified  -1
    end
  end
end
