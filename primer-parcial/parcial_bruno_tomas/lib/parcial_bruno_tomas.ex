# (1)

defmodule Products do
  defmodule State do
    defstruct products: []
  end

  def start() do
    spawn(fn -> loop(%State{}) end)
  end

  def loop(state) do

    receive do
      {:visit_product, name, from} ->
        send(from, {:ok})
        loop(%State{products: [name] ++ state.products})

      {:last_n_products, n, from} ->
        last = state.products
          |> Enum.uniq()
          |> Enum.take(n)

        send(from, {:ok, last})
        loop(state)

      {:prod_freq, from} ->
        send(from, {:ok, state.products |> Enum.frequencies})
        loop(state)
    end

  end
end

# (2)

defmodule Bidding do
  defmodule State do
    defstruct current_price: 0, clients: [], last_bidding: :os.system_time(:second), winning_client: nil
  end
  defmodule Client do
    defstruct name: "", pid: nil
  end

  use GenServer

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(base_price) do
    GenServer.start_link(__MODULE__, %State{current_price: base_price}, name: __MODULE__)
  end

  def register(bid, name, pid) do
    GenServer.call(bid, {:register, name, pid})
  end

  def make_offer(bid, name, offer) do
    GenServer.call(bid, {:offer, name, offer})
  end

  @impl true
  def handle_call({:register, name, pid}, _from, state) do
    if state.clients |> Enum.empty?() do
      GenServer.cast(__MODULE__, :loop)
    end
    new_clients = state.clients ++ [%Client{name: name, pid: pid}]
    {:reply, {:ok, state.current_price}, %State{state | clients: new_clients}}
  end

  @impl true
  def handle_call({:offer, name, offer}, _from, state) do
    if state.current_price < offer do
      state.clients |> Enum.each(fn u -> send(u.pid, {:new_offer, name, offer}) end)
      {:reply, {:ok, :accepted, offer}, %State{state | current_price: offer, last_bidding: :os.system_time(:second), winning_client: name}}
    else
      {:reply, {:ok, :rejected, state.current_price}, state}
    end
  end

  @impl true
  def handle_cast(:loop, state) do
    now = :os.system_time(:second)
    if now - state.last_bidding > 60 do
      state.clients |> Enum.each(fn u -> send(u.pid, {:winner, state.winning_client}) end)
    else
      GenServer.cast(__MODULE__, :loop)
    end
    {:noreply, state}
  end

end
