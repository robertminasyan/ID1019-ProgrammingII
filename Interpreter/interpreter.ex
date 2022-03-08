defmodule Env do
    def new() do [] end

    def add(id, str, env) do
        [{id, str}|env]
    end

    def lookup(_, []) do nil end
    def lookup(id, [{id, str}|_]) do {id, str} end
    def lookup(id, [_|tail]) do lookup(id, tail) end

    def remove(_, []) do [] end
    def remove(ids, [{ids, _}|tail]) do tail end
    def remove(ids, [head|tail]) do [head|remove(ids, tail)] end
end

defmodule Eager do
    def eval_expr({:atm, id}, _) do {:ok, id} end

    def eval_expr({:var, id}, env) do
        case Env.lookup(id, env) do
            nil ->
                :error
            {_, str} ->
                {:ok, str}
        end
    end

    def eval_expr({:cons, a, b}, env) do
        case eval_expr(a, env) do
            :error ->
                :error
            {:ok, str} ->
                case eval_expr(b, env) do
                    :error ->  
                        :error
                    {:ok, ts} ->
                        {:ok, {str, ts}}
                end
        end
    end

    def eval_match(:ignore, _, env) do
        {:ok, env}
    end
    
    def eval_match({:atm, id}, id, env) do
        {:ok, env}
    end

    def eval_match({:var, id}, str, env) do
        case Env.lookup(id, env) do
            nil ->
                {:ok, Env.add(id, str, env)}
            {_, ^str} ->
                {:ok, env}
            {_, _} ->
                :fail
        end
    end

    def eval_match({:cons, hp, tp}, {a, b}, env) do
        case eval_match(hp, a, env) do
            :fail ->
                :fail
            {:ok, env} ->
                eval_match(tp, b, env)
        end
    end

    def eval_match(_, _, _) do
        :fail
    end

    def extract_vars(pattern) do extract_vars(pattern, []) end

    def extract_vars({:var, id}, vars) do [id|vars] end
    def extract_vars({:atm, _}, vars) do vars end
    def extract_vars(:ignore, vars) do vars end
    def extract_vars({:cons, a, b}, vars) do extract_vars(b, extract_vars(a, vars)) end

    def eval_scope(pattern, env) do
        Env.remove(extract_vars(pattern), env)
    end

    def eval_seq([exp], env) do
        eval_expr(exp, env)
    end

    def eval_seq([{:match, a, b} | seque], env) do
        case eval_expr(b, env) do
            :error ->
                :error
            {:ok, str} ->
                env = eval_scope(a, env) # tagit bort allt som vinder rtill a
            case eval_match(a, str, env) do
                :fail ->
                    :error
                {:ok, env} ->
                    eval_seq(seque, env)
            end
        end
    end

    def eval_expr({:case, expr, cls}, env) do
        case eval_expr(expr, env) do
            :error ->
                :error
            {:ok, str} ->
                eval_cls(cls, str, env)
        end
    end

    def eval_cls([], _, _, _) do
        :error
    end
    def eval_cls([{:clause, ptr, seq} | cls], str, env) do
        env = eval_scope(ptr, env)
        case eval_match(ptr, str, env) do
            :fail ->
                eval_cls(cls, str, env)
            {:ok, env} ->
                 eval_seq(seq, env)
        end
    end
end