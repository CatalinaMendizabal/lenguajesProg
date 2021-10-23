defmodule HackerNews do
  defmodule State do
    defstruct subscribers: [], links: []
  end

  use GenServer

  @impl true
  def init(state) do
    {:ok, state}
  end

  def start_link(_init) do
    url = "https://news.ycombinator.com/newest"
    {:ok, response} = HTTPoison.get(url)
    html = response.body
    {:ok, doc} = Floki.parse_document(html)

    story_links = doc |> Floki.attribute("a.titlelink", "href")

    GenServer.start_link(__MODULE__, %State{subscribers: [], links: story_links}, name: __MODULE__)
  end

  def subscribe(pid) do
    GenServer.cast(__MODULE__, {:subscribe, pid})
  end

  def start() do
    GenServer.cast(__MODULE__, :update)
  end

  def loop(_state) do
    Process.sleep(10000)
    GenServer.cast(__MODULE__, :update)
  end

  @impl true
  def handle_cast(:update, state) do

    url = "https://news.ycombinator.com/newest"
    {:ok, response} = HTTPoison.get(url)
    html = response.body
    {:ok, doc} = Floki.parse_document(html)

    story_links = doc |> Floki.attribute("a.titlelink", "href")

    message = story_links -- state.links

    if((message |> Kernel.length) > 0) do
      state.subscribers |> Enum.each(fn e -> send(e, message) end)
    end

    loop(state)
    {:noreply, %{state | links: story_links}}

  end

  @impl true
  def handle_cast({:subscribe, pid}, state) do
    {:noreply, %{state | subscribers: state.subscribers ++ [pid]}}
  end
end
