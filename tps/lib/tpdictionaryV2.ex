defmodule TranslatorV2 do

  defmodule State do
    defstruct dictionary: %{"hola" => "hello", "mundo" => "world"}, document_count: 0, word_count: 0, word_frequency: %{}
      def new_state(document_count, word_count, word_frequency) do
        %State{
          document_count: document_count,
          word_count: word_count,
          word_frequency: word_frequency
        }
      end
  end

  @name Translator

  use GenServer

  @impl true
  def init(state) do
    {:ok, state}
  end

  # API
  def start_link(init) do
    GenServer.start_link(__MODULE__, init, name: @name)
  end

  def start_link() do
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def translate(doc) do
    GenServer.call(@name, {:translate, doc})
  end

  @spec stats :: any
  def stats() do
    GenServer.call(@name, :stats)
  end

  @impl true
	def handle_call({:translate, doc}, _from, state) do
    words = doc
      |> String.downcase()
      |> String.split(" ")

    word_count =
      words
      |> Kernel.length()

    translation = words
      |> Enum.map(fn word -> Map.get(state.dictionary, word, word <> "?") end)
      |> Enum.join(" ")

    freq = Enum.frequencies(words)

    new_word_frequency = Map.merge(state.word_frequency, freq, fn _k, v1, v2 -> v1 + v2 end)

    updated_word_count = word_count + state.word_count
    updated_document_count = if (word_count > 1) do state.document_count + 1 else state.document_count end

		{:reply, translation, %State{state | word_frequency: new_word_frequency, word_count: updated_word_count, document_count: updated_document_count}}
	end

  def handle_call(:stats, _from, state) do
    {:reply, %{word_count: state.word_count, document_count: state.document_count, word_frequency: state.word_frequency}, state}
  end

end

defmodule TranslatorSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {TranslatorV2, %TranslatorV2.State{dictionary: %{"mano" => "hand", "dedo" => "finger"}, document_count: 0, word_count: 0, word_frequency: %{}}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
