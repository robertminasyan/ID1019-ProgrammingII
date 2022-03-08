defmodule Chopstick do
    def start do
        stick = spawn_link(fn -> available() end)
    end

    def available() do
        receive do
            {:request, from} -> 
            send(from, :granted)
            gone()
            :quit -> :ok
        end
    end

    def gone() do
        receive do
            :return -> available()
            :quit -> :ok
        end
    end

    def request(stick) do
        send(stick, {:request, self()})
        receive do
            :granted -> :ok
        end
    end

    def return(stick) do
        send(stick, :return)
    end

    def quit(stick) do
        send(stick, :quit)
    end
end

defmodule Philosopher do
    def sleep(0) do :ok end
    def sleep(t) do
        :timer.sleep(:rand.uniform(t))
    end

    def start(hunger, right, left, name, ctrl) do
        philosofia = spawn_link(fn -> dreaming(hunger, right, left, name, ctrl) end)
    end

    def dreaming(hunger, right, left, name, ctrl) do
        sleep(5)
        if (hunger == 0) do
            :done
        else
            case Chopstick.request(right) do
                :ok ->
                    IO.puts("#{name} received a chopstick!")
                    case Chopstick.request(left) do
                        :ok ->
                            eating(hunger, right, left, name, ctrl)
                            IO.puts("#{name} received a chopstick!")
                    end
            end
        end
    end

    def eating(hunger, right, left, name, ctrl) do
        sleep(5)
        Chopstick.return(left)
        Chopstick.return(right)
        dreaming(hunger-1, right, left, name, ctrl)
    end

end
