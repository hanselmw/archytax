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
      IO.puts("Here gonna parse sysex")
      # Remove last byte as it is not necessary to execute firmata operation
      parsed_data = binary_part(data, 0, byte_size(data) - 1)
      << command :: size(8), command_data :: binary >> = parsed_data
      outbox = [ execute(<< command >> <> command_data) | outbox ]
    else
      IO.puts("keep storing data")
      code_bin = << @start_sysex, data :: binary >>
    end
    parse({outbox, code_bin}, << >>)
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
    bin_list = :binary.bin_to_list(data)
    parsed_list = Enum.filter(bin_list, fn(b)-> b in 32..126 end)
    firmware_name = :binary.list_to_bin(parsed_list)
    {:firmware_name, firmware_name}
  end

end