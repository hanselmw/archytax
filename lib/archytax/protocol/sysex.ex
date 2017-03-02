defmodule Archytax.Protocol.Sysex do
  use Archytax.Protocol.Messages
  use Archytax.Protocol.MessageTypes
  use Archytax.Protocol.Modes
  require IEx

  # No more bytes to pase. Stop and return current bytestring if exists and complete commands on outbox.
  def parse({outbox, code_bin}, "") do
    {outbox, code_bin}
  end

  def parse({outbox, code_bin}, << @protocol_version :: size(8), mayor_v :: size(8), minor_v :: size(8), data :: binary >>) do
    outbox = [ {:only_version, %{mayor: mayor_v, minor: minor_v} } | outbox ]
    parse({outbox, code_bin}, data)
  end

  def parse({outbox, code_bin}, << @start_sysex >>)  do
    code_bin = {:sysex, << @start_sysex >>}
    parse({outbox, code_bin}, "")
  end

  def parse({outbox, code_bin}, << @start_sysex :: size(8), data :: binary >>) do
    last_byte = String.last(data)
    if last_byte == 0xF7 do
      IO.puts("Here gonna parse sysex")
    else
      IO.puts("keep storing data")
      code_bin = {:sysex, << @start_sysex, data :: binary >>}
    end
    parse({outbox, code_bin}, "")
  end

  def parse({outbox, code_bin}, << data :: binary >>) do
    IO.inspect(data)
    parse({outbox, code_bin}, "")
  end

end