defmodule Chopstick do
    def start do
        stick = spawn_link(fn -> available() end)
    end

    def available() do
        receive do
            {:request, from, ref} -> 
            send(from, {:granted, ref})
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

    # Andra
    def granted(timeout, sec, fir, 0) do
        receive do
            {:granted, sec} -> 
                :ok
        after
            timeout -> 
                return(fir)
                :no
        end
    end

    # Första
    def granted(timeout, left, right) do
        receive do
            {:granted, left} -> 
                granted(timeout, right, left, 0)
            {:granted, right} -> 
                granted(timeout, left, right, 0)
        after
            timeout -> 
                :no
        end
    end

    # right and left är pids
    def request(right, left, timeout) do
        send(left, {:request, self(), left})
        send(right, {:request, self(), right})
        granted(timeout, left, right)
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
    def delay(t) do
        sleep(t)
    end

    def start(hunger, right, left, name, ctrl, tuple) do
        :rand.seed(:exsss, tuple)
        philosofia = spawn_link(fn -> dreaming(hunger, right, left, name, ctrl) end)
    end

    def dreaming(0, right, left, name, ctrl) do 
    send(ctrl, :done) 
    end
    def dreaming(hunger, right, left, name, ctrl) do
        sleep(2000)
        case Chopstick.request(right, left, 300) do
            :ok ->
                IO.puts("#{name} received both chopsticks!")
                eating(hunger, right, left, name, ctrl)
            :no ->
                #Chopstick.return(right)
                #Chopstick.return(left)
                IO.puts("#{name} tries again!")
                dreaming(hunger, right, left, name, ctrl)
        end
    end

    def eating(hunger, right, left, name, ctrl) do
        sleep(50)
        IO.puts("#{name} just ate!")
        Chopstick.return(left)
        Chopstick.return(right)
        dreaming(hunger-1, right, left, name, ctrl)
    end
end

defmodule Dinner do
    def start() do spawn(fn -> init() end) end
    def init() do
        hej = :os.system_time(:milli_seconds)
        c1 = Chopstick.start()
        c2 = Chopstick.start()
        c3 = Chopstick.start()
        c4 = Chopstick.start()
        c5 = Chopstick.start()
        ctrl = self()
        s1 = {1, 50, 100}
        s2 = {200, 250, 300}
        s3 = {300, 350, 400}
        s4 = {500, 550, 600}
        s5 = {700, 750, 800}
        Philosopher.start(5, c1, c2, "Arendt", ctrl, s1)
        Philosopher.start(5, c2, c3, "Hypatia", ctrl, s2)
        Philosopher.start(5, c3, c4, "Simone", ctrl, s3)
        Philosopher.start(5, c4, c5, "Elisabeth", ctrl, s4)
        Philosopher.start(5, c5, c1, "Ayn", ctrl, s5)
        wait(5, [c1, c2, c3, c4, c5], hej)
    end

    def wait(0, chopsticks, hej) do
        Enum.each(chopsticks, fn(c) -> Chopstick.quit(c) end)
        da = :os.system_time(:milli_seconds)
        result_time = (da - hej)/1000
        IO.puts("Stop eating!")
        IO.puts(result_time)

    end
    def wait(n, chopsticks, hej) do
        receive do
            :done ->
                wait(n - 1, chopsticks, hej)
            :abort ->
                Process.exit(self(), :kill)
        end
    end

end
