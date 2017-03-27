defmodule Archytax.Protocol.Sysex do
  use Archytax.Protocol.Messages
  use Archytax.Protocol.MessageTypes
  use Archytax.Protocol.Modes
  require IEx

  # No more bytes to pase. Stop and return current bytestring if exists and complete commands on outbox.
  def parse({outbox, code_bin}, << >>) do
    {outbox, code_bin}
  end

  def parse({outbox, _code_bin}, << @protocol_version :: size(8), mayor_v :: size(8), minor_v :: size(8), data :: binary >>) do
    outbox = [ {:only_version, mayor_v, minor_v } | outbox ]
    parse({outbox, << >>}, data)
  end

  def parse({outbox, code_bin}, << @start_sysex :: size(8), data :: binary >>) do
    last_byte = String.last(data)
    if last_byte == << 0xF7 >> do
      # Remove last byte as it is not necessary to execute firmata operation
      parsed_data = binary_part(data, 0, byte_size(data) - 1)
      << command :: size(8), command_data :: binary >> = parsed_data
      outbox = [ execute(<< command >> <> command_data) | outbox ]
    else
      code_bin = << @start_sysex, data :: binary >>
    end
    parse({outbox, code_bin}, << >>)
  end

  # Working with Analog messages
  # Return analog byte as the pin and the value operating with the lsb and msb provided
  def parse({outbox, code_bin}, << analog_byte :: size(8), lsb :: size(8), msb :: size(8),
                                   data :: binary >>) when analog_byte in @analog_message_range  do
    outbox = [{:analog_read, {analog_byte, lsb ||| (msb <<< 7) } }]
    parse({outbox, code_bin}, data)
  end

  # Store the data and return
  def parse({outbox, code_bin}, << data :: binary >>) do
    IO.inspect(data)
    parse({outbox, code_bin <> data }, << >>)
  end
  #########
  # Sysex #
  #########

  def execute(<< @report_firmware :: size(8), data :: binary >>) do
    << mayor_v :: size(8), minor_v :: size(8), _rest :: binary >> = data
    bin_list = :binary.bin_to_list(data)
    parsed_list = Enum.filter(bin_list, fn(b)-> b in 32..126 end)
    firmware_name = :binary.list_to_bin(parsed_list)
    {:firmware_info, {mayor_v, minor_v, firmware_name}}
  end

  def execute(<< @capability_response :: size(8), data :: binary >>) do
    pins_data = binary_part(data, 0, byte_size(data) - 1) # remove last << 127  >> byte
    pins_data = String.split(pins_data, << 0x7f >>) # 0x7f separate each pin data on the binary

    pins_array = Stream.map(pins_data, &(:binary.bin_to_list &1) ) # lazy convert to array to apply enum func
      |> Enum.reverse
      |> Stream.with_index(0)
    #OPTIMIZE add validator for supported modes according to firmata before setting mode
    # Acumulator is pin_map with a operation instruction
    pins_information = Enum.reduce(pins_array, %{} , &insert_capability_info/2 )
    {:capability_response, pins_information}
  end

  def execute(<< @analog_mapping_response :: size(8), data :: binary >>) do
    pins_list = :binary.bin_to_list(data)
      |> Stream.with_index(0)
    analog_information = Enum.reduce(pins_list, %{}, &insert_analog_info/2)
    {:analog_response, analog_information}
  end

  def execute(<< @pin_state_response :: size(8), pin_number :: size(8), pin_mode :: size(8), pin_state :: binary >>) do
    {:pin_state_response, {pin_number, pin_mode, pin_state}}
  end

  def execute(<< unknown :: size(8), _data :: binary >>) do
    IO.puts "#{unknown} is not a recognized sysex command."
    {:unknown}
  end

  # Initialize pin mode to each pin and insert into pins list
  def insert_capability_info({pin_list, pin_number}, pins_store) do
    pin = %{}
    { pin_map, _anything } = Enum.reduce(pin_list, { %{}, {:mode, 0}}, &eval_pin_capability/2 )
    new_map = Map.put(pin, :supported_modes, pin_map)
    new_map = Map.put(new_map, :mode, @unknown)
    # [ new_map | pins_store ]
    Map.put(pins_store, pin_number, new_map)
  end

  # Initialize pin mode to each pin and insert into pins list
  def insert_analog_info({byte, pin_number}, pins_store) do
    pin = case byte do
      127 ->
        %{analog_channel: nil} # doesn't support analog
      analog_channel_val ->
        %{analog_channel: analog_channel_val} # analog channel for pin_number
    end
    Map.put(pins_store, pin_number, pin) # update pins_store map
  end

  # Evaluate pin capability response for `pin` and set the mode and resolution in a Map%{:mode_number => resolution val }
  def eval_pin_capability(byte, {pin_map, {:mode, _anything}}) do
    new_map = Map.put(pin_map, byte, nil)
    {new_map, {:resolution, byte}} # set new mode and instruct that next byte is this mode resolution
  end

  def eval_pin_capability(byte, {pin_map, {:resolution, mode_key}}) do
    new_map = Map.put(pin_map, mode_key, byte)
    {new_map, {:mode, true}} # set resolution for mode and instruct next byte is mode byte
  end

end