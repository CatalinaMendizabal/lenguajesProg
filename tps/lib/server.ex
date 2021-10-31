defmodule Server do
    def start(name, module) do
        pid = spawn(name, :loop, [module.init()])
        Process.register(pid, name)
        pid
    end
end
