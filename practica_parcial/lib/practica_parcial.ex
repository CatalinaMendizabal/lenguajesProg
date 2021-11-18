# Implementar un proceso en Elixir que permita mantener las cotizaciones de un conjunto de acciones de la bolsa.
# (sin usar GenServer).
# El proceso debe responder a los mensajes:
# {:crear_accion, "IBM", 12} ---> {ok}
# {:consultar_valor, "IBM"} ---> {ok, 12}
# {:actualizar_cotizacion, "IBM", 12.3} ---> {ok}
# {:consultar_historia, "IBM"} ---> {ok, [12.3, 12]}

defmodule Bolsa do

  defmodule State do
    defstruct acciones: %{}
  end

  def start do
    spawn(fn -> init() end)
  end

  def init() do
    loop(%State{})
  end

  def loop(state) do
    receive do

      {:crear_accion, name, value, from} ->
        send(from, :ok)
        nuevas_acciones = state.acciones |> Map.put(name, [value])
        loop(%State{acciones: nuevas_acciones})

      {:consultar_valor, name, from} ->
        value = state.acciones
          |> Map.get(name)
          |> List.first()
        send(from, {:ok , value})
        loop(state)

      {:actualizar_cotizacion, name, value, from} ->
        values = state.acciones |> Map.get(name)
        new_values = [value] ++ values
        new_acciones = state.acciones |> Map.put(name, new_values)

        send(from, :ok)

        loop(%State{acciones: new_acciones})

      {:consultar_historia, name, from} ->
        values = state.acciones |> Map.get(name)
        send(from, {:ok, values})
        loop(state)
    end

  end

end

# Implementar un proceso 'Banco' (usando GenServer) que permita realizar las operaciones para crear una cuenta,
# depositar/retirar una cantidad de dinero, ver la cantidad total de dinero en el banco.
# Utilizar una estructura para las cuentas (por ejemplo: %Cuenta{...} con los campos id, nombre, balance).

defmodule Banco do

  defmodule State do
    defstruct accounts: []
  end
  defmodule Account do
    defstruct id: 0, name: "" , balance: 0
  end

  use GenServer

  def start_link(_ignore) do
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  @impl true
  def init(init) do
    {:ok, init}
  end

  def nueva_cuenta(id, name) do
    GenServer.call(__MODULE__, {:create, id, name})
  end

  def depositar(id, amount) do
    GenServer.call(__MODULE__, {:deposit, id, amount})
  end

  def retirar(id, amount) do
    GenServer.call(__MODULE__, {:withdraw, id, amount})
  end

  def total() do
    GenServer.call(__MODULE__, :total)
  end

  @impl true
  def handle_call({:create, id, name}, _from, state) do
    accounts = state.accounts
    # Habria que chequear si la cuenta ya existe
    new_accounts = accounts ++ [%Account{id: id, name: name}]
    new_state = %State{accounts: new_accounts}

    {:reply, {:ok, :cuenta_creada, id}, new_state}
  end

  @impl true
  def handle_call({:deposit, id, amount}, _from, state) do
    account = state.accounts |> Enum.find(fn x -> x.id == id end)
    new_account = %Account{id: account.id, name: account.name, balance: account.balance + amount}

    new_accounts = (state.accounts |> Enum.filter(fn x -> x.id != id end)) ++ [new_account]
    new_state = %State{accounts: new_accounts}

    {:reply, {:ok, :su_saldo_es, new_account.balance}, new_state}
  end

  @impl true
  def handle_call({:withdraw, id, amount}, _from, state) do
    account = state.accounts |> Enum.find(fn x -> x.id == id end)
    new_account = %Account{id: account.id, name: account.name, balance: account.balance - amount}

    new_accounts = (state.accounts |> Enum.filter(fn x -> x.id != id end)) ++ [new_account]
    new_state = %State{accounts: new_accounts}

    {:reply, {:ok, :su_saldo_es, new_account.balance}, new_state}
  end

  @impl true
  def handle_call(:total, _from, state) do
    total = state.accounts |> List.foldl(0, fn a, acc -> a.balance + acc end)
    {:reply, {:ok, total}, state}
  end

end

defmodule Sessions do
  defmodule State do
    defstruct users: []
  end
  defmodule User do
    defstruct pid: nil, name: "", status: :online, last_time: System.monotonic_time(:second)
  end

  use GenServer

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
    GenServer.cast(__MODULE__, :loop)
  end

  def register_user(name, pid) do
    GenServer.cast(__MODULE__, {:register, name, pid})
  end

  def deregister(name) do
    GenServer.cast(__MODULE__, {:deregister, name})
  end

  def user_still_active(name) do
    GenServer.cast(__MODULE__, {:active, name})
  end

  def get_online_users do
    GenServer.call(__MODULE__, :get_online)
  end

  @impl true
  def handle_cast({:register, name, pid}, state) do

    new_users = state.users ++ [%User{pid: pid, name: name}]

    {:noreply, %State{users: new_users}}
  end

  @impl true
  def handle_cast({:deregister, name}, state) do

    new_users = state.users |> Enum.filter(fn e -> e.name != name end)

    {:noreply, %State{users: new_users}}
  end

  @impl true
  def handle_cast({:active, name}, state) do
    user = state.users |> Enum.find(fn e -> e.name == name end)
    new_user = %User{pid: user.pid, name: user.name, last_time: System.monotonic_time(:second)}

    users = state.users |> Enum.filter(fn e -> e.name != name end)
    new_users = users ++ [new_user]

    {:noreply, %State{users: new_users}}
  end

  @impl true
  def handle_cast(:loop, state) do
    now = System.monotonic_time(:second)

    active = state.users
      |> Enum.filter(fn u -> now - u.last_time <= 5 * 60 && u.status == :online end)

    inactive = state.users
      |> Enum.filter(fn u -> now - u.last_time > 5 * 60 && u.status == :online end)

    inactive |> Enum.each(fn u -> send(u.pid, {:status_change, :offline}) end)

    new_users = active ++ (inactive
      |> List.foldl([], fn u, acc -> acc ++ [%User{pid: u.pid, name: u.name, status: :offline, last_time: u.last_time}] end))

    GenServer.cast(__MODULE__, :loop)
    {:noreply, %State{users: new_users}}
  end

  @impl true
  def handle_call(:get_online, _from, state) do
    users = state.users |> Enum.filter(fn e -> e.status == :online end) |> Enum.map(fn e -> e.name end)

    {:reply, {:online_users, users}, state}
  end

end
