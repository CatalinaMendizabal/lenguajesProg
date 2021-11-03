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
    account = state.accounts |> Enum.filter(fn x -> x.id == id end) |> List.first()
    new_account = %Account{id: account.id, name: account.name, balance: account.balance + amount}

    new_accounts = (state.accounts |> Enum.filter(fn x -> x.id != id end)) ++ [new_account]
    new_state = %State{accounts: new_accounts}

    {:reply, {:ok, :su_saldo_es, new_account.balance}, new_state}
  end

  @impl true
  def handle_call({:withdraw, id, amount}, _from, state) do
    account = state.accounts |> Enum.filter(fn x -> x.id == id end) |> List.first()
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
