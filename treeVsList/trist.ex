defmodule Bench do
  def bench() do bench(100) end

  def bench(l) do

    ls = [16,32,64,128,256,512,1024,2*1024,4*1024,8*1024]

    time = fn (i, f) ->
      seq = Enum.map(1..i, fn(_) -> :rand.uniform(100000) end)
      elem(:timer.tc(fn () -> loop(l, fn -> f.(seq) end) end),0)
    end

    bench = fn (i) ->

      list = fn (seq) ->
        List.foldr(seq, list_new(), fn (e, acc) -> list_insert(e, acc) end)
      end

      tree = fn (seq) ->
        List.foldr(seq, tree_new(), fn (e, acc) -> tree_insert(e, acc) end)
      end      

      tl = time.(i, list) 
      tt = time.(i, tree)     

      IO.write("  #{tl}\t\t\t#{tt}\n")
    end

    IO.write("# benchmark of lists and tree (loop: #{l}) \n")
    Enum.map(ls, bench)

    :ok
  end
  
  def loop(0,_) do :ok end
  def loop(n, f) do 
    f.()
    loop(n-1, f)
  end
  
  
    def list_new() do [] end 

    def list_insert(e, []) do 
        [e]
    end
  
    def list_insert(e, [head|tail]) do 
      if e <= head do 
        [e|[head|tail]]
      else 
        [head|list_insert(e, tail)]
    end

    end

  def tree_new() do :nil
   end

  def tree_insert(e, :nil) do 
    {:node, e, :nil, :nil}
  end
  
  def tree_insert(e1, {:node, e2, left, right}) do 

    if e1 <= e2 do 
      {:node, e2, tree_insert(e1, left), right}
    else 
      {:node, e2, left, tree_insert(e1, right)}
    end
  end
end

