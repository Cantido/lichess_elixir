defmodule LichessElixir.NDJSON do
  alias LichessElixir.HTTPStream
  require Logger

  def stream(url, _headers) do
    http_stream(url)
    |> chunk_by_char(?\n)
    |> Stream.map(&IO.chardata_to_string/1)
    |> Stream.map(&Jason.decode!/1)
  end

  def chunk_by_char(stream, char) do
    chunk_fun = fn
      ^char, acc -> {:cont, Enum.reverse(acc), []}
      x, acc -> {:cont, [x | acc]}
    end

    after_fun = fn
      [] -> {:cont, []}
      acc -> {:cont, Enum.reverse(acc), []}
    end

    Stream.chunk_while(stream, [], chunk_fun, after_fun)
  end

  defp http_stream(url) do
    {:ok, pid} = HTTPStream.start(url)

    Stream.resource(
      fn -> {pid, 0} end,
      fn {pid, n} ->
        chunk = HTTPStream.get(pid, n)
        {[chunk], {pid, n + 1}}
      end,
      fn _acc -> :ok end
    )
  end
end
