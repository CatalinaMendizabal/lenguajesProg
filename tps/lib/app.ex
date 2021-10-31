defmodule MyApp do
  use Application

  def start(_start_type, _start_args) do

    IO.puts("Starting...")

    children = [
      TranslatorSupervisor
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: :root_sup
    )
  end

  def stop(_state) do
    IO.puts("Stopping...")
    :ok
  end
end
