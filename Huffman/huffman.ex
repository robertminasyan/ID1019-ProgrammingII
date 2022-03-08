
defmodule Huffman do
    def sup() do
        bench(read("crime_and_punishment.txt"))
    end

    def bench(input) do
        text = input
        c = length(text)
        {tree, t2} = time(fn -> tree(text) end)
        #{encode, t3} = time(fn -> encode_table(tree) end)
        #IO.inspect(encode)
        encode = encode_table(tree)
        #s = length(encode)
        {encoded, t5} = time(fn -> encode(text, encode) end)
        #e = div(length(encoded), 8)
        {_, t6} = time(fn -> decode(encoded, encode) end) # since decode_table is same as encode_table

        IO.puts("text of #{c} characters")
        IO.puts("tree built in #{t2} ms")
        #IO.puts("table of size #{s} in #{t3} ms")
        IO.puts("encoded in #{t5} ms")
        IO.puts("decoded in #{t6} ms")
    end

    # Measure the execution time of a function.
    def time(func) do
        initial = Time.utc_now()
        result = func.()
        final = Time.utc_now()
        {result, Time.diff(final, initial, :microsecond) / 1000}
    end

    def sample do
        'the quick brown fox jumps over the lazy dog
        this is a sample text that we will use when we build
        up a table we will only handle lower case letters and
        no punctuation symbols the frequency will of course not
        represent english but it is probably not that far off'
    end
    
    def text() do
        'this is something that we should encode'
        #'ABCDEE'
    end

    def test do
        sample = sample
        tree = tree(sample)
        encode_table = encode_table(tree)
        #encode = encode(sample, encode_table)
        #decode_table = encode_table
        #decode = decode(encode, decode_table)
    end

    def tree(sample) do
        huffman(sort(freq(sample)))
    end
    
    def sort(list) do
        List.keysort(list, 1)
    end

    def freq(sample) do
        freq(sample, [])
    end
    def freq([char|rest], order) do
        freq(rest, search(char, order))
    end
    def freq([], order) do
        order
    end

    def search(char, [{char, ack}|t]) do
        [{char, ack+1}|t]
    end
    def search(char, [h|t]) do
        [h|search(char, t)]
    end
    def search(char, []) do
        [{char, 1}]
    end

    def huffman([wegood]) do wegood end
    def huffman([{first, ack1}, {second, ack2} | tail]) do
        huffman(insert({{first, second}, ack1+ack2}, tail))
    end

    def insert({tuple, ack1}, [{head, ack2}|tail]) do
        cond do
            ack1 >= ack2 -> [{head, ack2}|insert({tuple, ack1}, tail)]
            true -> [{tuple, ack1}|[{head, ack2}|tail]]
        end
    end
    def insert(hello, []) do [hello] end

    def encode_table({left, _}) do encode_table(left, []) end
    def encode_table({left, right}, ack) do 
        encode_table(left, [1|ack]) ++ encode_table(right, [0|ack])
    end
    def encode_table(last, ack) do
        [{last, Enum.reverse(ack)}]
    end


    def encode(charlist, codelist) do
        encode(charlist, codelist, codelist)
    end

    def encode([char|t], [{char, coding}|tail], codelist) do
        coding ++ encode(t, codelist)
    end
    def encode([h|t], [{char, coding}|tail], codelist) do
        encode([h|t], tail, codelist)
    end
    def encode([], _, _) do [] end

    def decode([], _) do
        []
    end
    def decode(seq, table) do
        {char, rest} = decode_char(seq, 1, table)
        [char | decode(rest, table)]
    end
    def decode_char(seq, n, table) do
        {code, rest} = Enum.split(seq, n)
        case List.keyfind(table, code, 1) do
            {char, _} ->
                {char, rest}
            nil ->
                decode_char(seq, n+1, table)
        end
    end

    def read(file) do
        {:ok, file} = File.open(file, [:read, :utf8])
        binary = IO.read(file, :all)
        File.close(file)
        case :unicode.characters_to_list(binary, :utf8) do
            {:incomplete, list, _} ->
                list
            list ->
                list
        end
    end


end