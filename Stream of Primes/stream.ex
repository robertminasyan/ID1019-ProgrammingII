defmodule Primes do
    def z(n) do
        fn() -> zPrivate(n) end
    end

    def zPrivate(n) do
        {n, fn() -> zPrivate(n+1) end}
    end

    def filter(fun, f) do
        {p, next} = fun.()
        if (rem(p, f) != 0) do
            {p, fn() -> filter(next, f) end}
        else
            filter(next, f)
        end
    end

    def sieve(n, p) do
        {next, f} = filter(n, p)
        IO.inspect(next)
        {next, fn -> sieve(f, next) end}
    end

    def primes() do
        fn() -> {2, fn() -> sieve(z(3), 2) end} end
    end

    defstruct [:next]

    def primes() do
        %Primes{next: Enumerable.reduce(primes.(), {:cont, 0}, primes.())}
    end

    defimpl Enumerable do
    def count(_) do {:error, __MODULE__} end
    def member?(_, _) do {:error, __MODULE__} end
    def slice(_) do {:error, __MODULE__} end
    def reduce(_, {:halt, acc}, _fun) do
        {:halted, acc}
    end
    def reduce(primes, {:suspend, acc}, fun) do
        {:suspended, acc, fn(cmd) -> reduce(primes, cmd, fun) end}
    end
    def reduce(primes, {:cont, acc}, fun) do
        {p, next} = Primes.next(primes)
        reduce(next, fun.(p,acc), fun)
    end

end

end


