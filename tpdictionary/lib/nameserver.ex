defmodule NameServer do
    def start do
        pid = spawn(__MODULE__, :loop, [init()])
        Process.register(pid, :ns)
        pid
    end

    def add(host, ip) do
        send(:ns, {:add, self(), {host, ip}})
    end

    def lookup(host) do
        send(:ns, {:lookup, self(), {host}})

        receive do
            {:ip, value} ->
                value
        end
    end

    def init() do
        %{}
    end

    def loop(map) do
        receive do
            {:add, from, {host, ip}} ->
                new_map = Map.put(map, host, ip)
                loop(new_map)
            {:lookup, from, {host}} ->
                ip = Map.gey(map,host, :not_found)
                send from,{:ip, ip}
                loop(map)
        end
    end

end
