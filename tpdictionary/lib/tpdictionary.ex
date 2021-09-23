defmodule Translator do

  defmodule Translator.State do
    defstruct document_count: 0, word_count: 0, word_frequency: %{}
      def new_state(document_count, word_count, word_frequency) do
        %Translator.State{
          document_count: document_count,
          word_count: word_count,
          word_frequency: word_frequency
        }
      end
  end

  def start() do
    spawn(&loop/0)
  end

  def loop() do
    loop(%Translator.State{})
  end

  def translate(document, dictionary) do
    document
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(fn word ->  Map.get(dictionary, word) end)
    |> Enum.join(" ")
  end

  def update_state(translation, state) do
    word_count =
      translation
      |> String.split(" ")
      |> Kernel.length()

    updated_word_count = word_count + state.word_count
    updated_document_count = if (word_count > 1) do state.document_count + 1 else state.document_count end

    frequency =
      translation
      |> String.split(" ")
      |> Enum.frequencies()

    updated_word_frequency =  Map.merge(state.word_frequency, frequency, fn _k, v1, v2 -> v1 + v2 end)

    %{state | document_count: updated_document_count, word_count: updated_word_count, word_frequency: updated_word_frequency}
  end

  def loop(state) do
    receive do
      {:translate, from, document, dictionary} ->
        translation = translate(document, dictionary)
        send(from, {:translation, translation})
        loop(update_state(translation, state))

      {:stats, from} ->
        send(from,{:state, state})
        loop(state)

      other ->
        IO.puts("Error ... ")
        IO.inspect(other)
        loop(state)
    end
  end
end
