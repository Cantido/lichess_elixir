defmodule LichessElixir.Games do
  def playing(token) do
    HTTPoison.get!("https://lichess.org/api/account/playing", %{"Authorization" => "Bearer #{token}"}).body
    |> Jason.decode!()
    |> Map.fetch!("nowPlaying")
  end
end
