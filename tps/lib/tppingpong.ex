defmodule Ping do
	use GenServer

	@name __MODULE__

	defmodule State do
		defstruct msg_count: 0, start_time: nil
	end

	defmodule Stats do
		defstruct msg_count: 0, msg_per_sec: 0
	end

	@impl true
  	def init(state) do
    	{:ok, state}
  	end

	# API
	def start_link(_init) do
		GenServer.start_link(__MODULE__, %State{}, name: @name)
	end

	def play(n) do
		GenServer.cast(@name, {:play, n})
	end

	def stats() do
		GenServer.call(@name, :stats)
	end

	# Impl
	@impl true
  	def handle_cast({:play, n}, _state) do
    	Enum.each(1..n, fn _ ->
			GenServer.cast(Pong, :ball)
    	end)

		{:noreply, %State{start_time: System.monotonic_time(:second)}}
 	end

	@impl true
  	def handle_cast(:ball, state) do
    	GenServer.cast(Pong, :ball)
		{:noreply, %State{state | msg_count: state.msg_count + 1}}
 	end

	@impl true
	def handle_call(:stats, _from, state) do
		current_time = System.monotonic_time(:second)
		elapsed_secs = current_time - state.start_time
		msg_per_sec = state.msg_count / elapsed_secs

		response = %Stats{msg_count: state.msg_count, msg_per_sec: msg_per_sec}
		{:reply, response, state}
	end

end

defmodule Pong do
    use GenServer

	def start_link(_init) do
		GenServer.start_link(__MODULE__, :ignore, name: __MODULE__)
	end

	@impl true
  	def init(state) do
    	{:ok, state}
  	end

	@impl	true
	def handle_cast(:ball, state) do
		GenServer.cast(Ping, :ball)
		{:noreply, state}
	end
end
