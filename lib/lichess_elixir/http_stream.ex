defmodule LichessElixir.HTTPStream do
  use GenServer

  def start(url) do
    GenServer.start(__MODULE__, [url])
  end

  def start_link(url) do
    GenServer.start_link(__MODULE__, [url])
  end

  def init([url]) do
    resp = HTTPoison.get!(url, %{}, stream_to: self(), async: :once, recv_timeout: :infinity)
    HTTPoison.stream_next(resp)
    {:ok, %{buf: [], waiting: %{}, resp: resp}}
  end

  def get(pid, n) do
    GenServer.call(pid, {:get, n}, :infinity)
  end

  def handle_call({:get, n}, from, state) do
    if has_index?(state.buf, n) do
      val = Enum.reverse(state.buf) |> Enum.at(n)

      {:reply, val, state}
    else
      waiting = Map.update(state.waiting, n, [from], &[from | &1])
      {:noreply, %{state | waiting: waiting}}
    end
  end

  defp has_index?(buf, n) do
    Enum.count(buf) > n
  end

  def handle_info(%HTTPoison.AsyncStatus{}, %{resp: resp} = state) do
    HTTPoison.stream_next(resp)
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncHeaders{}, %{resp: resp} = state) do
    HTTPoison.stream_next(resp)
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: data}, %{resp: resp} = state) do
    HTTPoison.stream_next(resp)
    {:noreply, push(state, data)}
  end

  def handle_info(%HTTPoison.AsyncEnd{}, state) do
    {:stop, :normal, state}
  end

  defp push(state, data) when is_binary(data) do
    buf = Enum.reverse(:binary.bin_to_list(data)) ++ state.buf

    can_reply =
      Map.filter(state.waiting, fn {index, _waiting_for_index} ->
        has_index?(buf, index)
      end)

    Enum.each(can_reply, fn {index, recipients} ->
      val = Enum.reverse(buf) |> Enum.at(index)
      Enum.each(recipients, fn recipient ->
        :ok = GenServer.reply(recipient, val)
      end)
    end)

    still_waiting = Map.drop(state.waiting, Map.values(can_reply))

    %{state | buf: buf, waiting: still_waiting}
  end
end
