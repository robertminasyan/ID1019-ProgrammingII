defmodule Mylist do
    def take(_, 0) do [] end
    def take([h|t], n) do
            [h|take(t, n-1)]
    end

    def drop(t, 0) do t end
    def drop([_|t], n) do
        drop(t, n-1)
    end

    def append([], ys) do ys end
    def append([h|t], ys) do
        [h|append(t, ys)]
    end

    def member([], _) do false end
    def member([y|_], y) do true end
    def member([_|t], y) do
        member(t, y)
    end

    def position([y|_], y) do 1 end
    def position([_|t], y) do
        1 + position(t, y)
    end
end

defmodule Moves do
    def single({_, 0}, res) do res end

    def single({:one, p}, {main, first, second}) when p > 0 do
        {Mylist.take(main, length(main)-p), Mylist.append(Mylist.drop(main, length(main)-p), first), second}
    end

    def single({:one, p}, {main, first, second}) when p < 0 do
        {Mylist.append(main, Mylist.take(first, abs(p))), Mylist.drop(first, abs(p)), second}
    end

    def single({:two, p}, {main, first, second}) when p > 0 do
        {Mylist.take(main, length(main)-p), first, Mylist.append(Mylist.drop(main, length(main)-p), second)}
    end

    def single({:two, p}, {main, first, second}) when p < 0 do
        {Mylist.append(main, Mylist.take(second, abs(p))), first, Mylist.drop(second, abs(p))}
    end

    def move([], res) do [res] end
    def move([h|t], res) do
        [res|move(t, single(h, res))]
    end
end

defmodule Shunt do
        
    def split([h|t], s) do
        {Mylist.take([h|t], Mylist.position([h|t], s)-1), Mylist.drop([h|t], Mylist.position([h|t], s))}
    end

    def find({[], _, _}, {[], _, _}) do
        []
    end
    def find({[h|t], [], []}, {[a|b], [], []}) do
        {hs, ts} = split([h|t], a)
        ts = Mylist.append([a], ts)
        [_|stop] = Mylist.append(ts, hs)
        moves = [{:one, length(ts)}, {:two, length(hs)}, {:one, -(length(ts))}, {:two, -(length(hs))}]
        Mylist.append(moves, find({stop, [], []}, {b, [], []}))
    end

    def few({[], _, _}, {[], _, _}) do
        []
    end
    def few({[a|t], [], []}, {[a|b], [], []}) do
        few({t, [], []}, {b, [], []})
    end
    def few({[h|t], [], []}, {[a|b], [], []}) do
        {hs, ts} = split([h|t], a)
        ts = Mylist.append([a], ts)
        [_|stop] = Mylist.append(ts, hs)
        moves = [{:one, length(ts)}, {:two, length(hs)}, {:one, -(length(ts))}, {:two, -(length(hs))}]
        Mylist.append(moves, few({stop, [], []}, {b, [], []}))
    end

    def compress(ms) do
        ns = rules(ms)
        case ns do
            ^ms -> ms
            _ -> compress(ns)
        end
    end

    def rules([]) do [] end
    def rules([{_, 0}|t]) do
        rules(t)
    end
    def rules([{a, num1}, {a, num2}|t]) do
        rules([{a, num1+num2}|t])
    end
    def rules([h|t]) do
        [h|rules(t)]
    end
end

