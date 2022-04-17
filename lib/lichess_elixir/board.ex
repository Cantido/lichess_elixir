defmodule LichessElixir.Board do
  alias LichessElixir.NDJSON

  def stream(game_id, token) do
    NDJSON.stream("https://lichess.org/api/board/game/stream/#{game_id}", %{"Authorization" => "Bearer #{token}"})
  end
end
