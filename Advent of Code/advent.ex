defmodule Advent1 do

    def call(function) do
        count(function, 0)
    end

    def count([_], ack) do ack end
    def count([head, next|tail], ack) do 
        case next > head do
            true -> count([next|tail], ack + 1)
            false -> count([next|tail], ack)
        end
    end
end

defmodule Advent2 do
    def call(function) do
        count(function, 0)
    end

    def three([head, next, next2|_]) do
        head + next + next2
    end

    def count([_, _, _], ack) do ack end
    def count([head, next, next2|tail], ack) do
        case three([head, next, next2|tail]) < three([next, next2|tail]) do
            true -> count([next, next2|tail], ack + 1)
            false -> count([next, next2|tail], ack)
        end
    end
end