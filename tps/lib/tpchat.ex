defmodule ChatSystem do

  defmodule State do
    defstruct rooms: %{}
  end

  use GenServer

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(_init) do
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  def create_room(name) do
    GenServer.cast(__MODULE__, {:create, name})
  end

  def lookup_room(name) do
    GenServer.call(__MODULE__, {:lookup, name})
  end

  def list_rooms() do
    GenServer.call(__MODULE__, :list)
  end

  @impl true
  def handle_cast({:create, name}, state) do
    {:ok, pid} = ChatRoom.start_link(:ok)

    new_rooms = state.rooms |> Map.put(name, pid)

    {:noreply, %{state | rooms: new_rooms}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    response = state.rooms |> Map.get(name, "room not found")

    {:reply, response, state}
  end

  @impl true
  def handle_call(:list, _from, state) do
    response = state.rooms |> Map.keys()

    {:reply, response, state}
  end

end

defmodule ChatRoom do

  defmodule State do
    defstruct messages: %{}, users: %{}
  end

  use GenServer

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(_init) do
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  def join(chat_room, user_name, client_pid) do
    GenServer.call(chat_room, {:join, user_name, client_pid})
  end

  def talk(chat_room, user_name, message) do
    GenServer.cast(chat_room, {:talk, user_name, message})
  end

  def list_users(chat_room) do
    GenServer.call(chat_room, :list)
  end

  @impl true
  def handle_call({:join, user_name, client_pid}, _from, state) do
    new_users = state.users |> Map.put(user_name, client_pid)

    {:reply, {:joined, state.messages}, %{state | users: new_users}}
  end

  @impl true
  def handle_call(:list, _from, state) do
    user_names = state.users |> Map.keys()

    {:reply, {:users, user_names}, state}
  end

  @impl true
  def handle_cast({:talk, user_name, message}, state) do
    state.users |> Map.values() |> Enum.each(fn v -> send(v, {:new_message, %{user_name => message}}) end)

    new_messages = state.messages |> Map.put(user_name, message)

    {:noreply, %{state | messages: new_messages}}
  end

end
