defmodule Bench do
    def sup() do
       
        Enum.map([5_000, 10_000, 25_000, 50_000, 75_000, 100_000, 125_000, 150_000, 175_000, 200_000], &Bench.bench/1)
    end
    def bench(n) do
        :timer.tc(Second, :new, [n])
        elem(:timer.tc(Second, :new, [n]),0)
    end
end

defmodule First do

    def new(n) do
        list = Enum.to_list(2..n)
        primes(list)
    end

    def primes([head]) do [head] end

    def primes([head|tail]) do
        case remove(head, tail) do
            [] -> []
            [h|t] -> [head|primes([h|t])]
        end
    end
    def remove(_, []) do [] end

    def remove(head, [next|tail]) do
        case rem(next, head) do
            0 -> remove(head, tail)
            _ -> [next|remove(head, tail)]
        end
    end
    
end

defmodule Second do

    def new(n) do
        list = Enum.to_list(2..n)
        primes(list, [])
    end

    def primes([head|tail], res) do
        if (truth(head, res) == true) do
            primes(tail, res ++ [head])
        else
            primes(tail, res)
        end
    end

    def primes([], res) do res end

    def truth(head, [h|t]) do
        case rem(head, h) do
            0 -> false
            _ -> truth(head, t)
        end
    end
    def truth(_, []) do true end
end

defmodule Third do
    def new(n) do
        list = Enum.to_list(2..n)
        primes(list, [])
    end

    def primes([head|tail], res) do
        if (truth(head, res) == true) do
            primes(tail, [head|res])
        else
            primes(tail, res)
        end

    end
    def primes([], res) do Enum.reverse(res) end

    def truth(head, [h|t]) do
        case rem(head, h) do
            0 -> false
            _ -> truth(head, t)
        end
    end
    def truth(_, []) do true end
end