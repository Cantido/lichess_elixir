defmodule LichessElixir.TV do
  def feed do
    LichessElixir.NDJSON.stream("https://lichess.org/api/tv/feed", %{})
  end
end
