defmodule LichessElixir.NDJSON do
  def stream(url, headers) do
    chunk_fun = fn
      ?\n, acc -> {:cont, Enum.reverse(acc), []}
      i, acc -> {:cont, [i | acc]}
    end

    after_fun = fn
      [] -> {:cont, []}
      acc -> {:cont, Enum.reverse(acc), []}
    end

    http_stream(url, headers)
    |> Stream.chunk_while([], chunk_fun, after_fun)
    |> Stream.map(&IO.chardata_to_string/1)
    |> Stream.map(&Jason.decode!/1)
  end


  defp http_stream(url, headers) do
    Stream.resource(
      fn -> HTTPoison.get!(url, headers, stream_to: self(), async: :once) end,
      fn %{id: ref} = acc ->
        HTTPoison.stream_next(acc)
        receive do
          %HTTPoison.AsyncStatus{id: ^ref} -> {[], acc}
          %HTTPoison.AsyncHeaders{id: ^ref} -> {[], acc}
          %HTTPoison.AsyncChunk{id: ^ref, chunk: data} -> {:binary.bin_to_list(data), acc}
          %HTTPoison.AsyncEnd{id: ^ref} -> {:halt, acc}
        end
      end,
      fn _acc -> :ok end
    )
  end
end
