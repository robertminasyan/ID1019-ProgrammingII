defmodule Derivative do

    @type literal() :: {:num, number()} | {:var, atom()}
    @type expr() :: literal() | 
    {:add, expr(), expr()} | 
    {:mul, expr(), expr()} |
    {:exp, expr(), literal()} |
    {:div, expr(), expr()} |
    {:ln, expr()} |
    {:squ, expr()} |
    {:sin, expr()} |
    {:cos, expr()}



    def test1() do
        e = {:div, {:var, :x}, {:num, 2}}
        d = derive(e, :x)
        c = calc(d, :x, 1)
        IO.write("expression: #{pprint(e)}\n")
        IO.write("derivative: #{pprint(d)}\n")
        IO.write("simplified: #{pprint(simplify(d))}\n")
        IO.write("calculated: #{pprint(simplify(c))}\n")
        :ok
    end
    def test2() do
        e = {:div, {:var, :x}, {:num, 3}}
        d = derive(e, :x)
        c = calc(d, :x, 9)
        IO.write("expression: #{pprint(e)}\n")
        IO.write("derivative: #{pprint(d)}\n")
        IO.write("simplified: #{pprint(simplify(d))}\n")
        IO.write("calculated: #{pprint(simplify(c))}\n")
        :ok
    end
    def test3() do
        e = {:add, {:mul, {:var, :x}, {:var, :x}}, {:num, 4}}
        d = derive(e, :x)
        c = calc(d, :x, 1)
        IO.write("expression: #{pprint(e)}\n")
        IO.write("derivative: #{pprint(d)}\n")
        IO.write("simplified: #{pprint(simplify(d))}\n")
        IO.write("calculated: #{pprint(simplify(c))}\n")
        :ok
    end

    def derive({:num, _}, _) do {:num, 0} end
    def derive({:var, v}, v) do {:num, 1} end
    def derive({:var, _}, _) do {:num, 0} end
    def derive({:add, e1, e2}, v) do 
        {:add, derive(e1, v), derive(e2, v)}
    end
    def derive({:mul, e1, e2}, v) do 
        {:add, 
        {:mul, derive(e1, v), e2}, 
        {:mul, e1, derive(e2, v)}} 
    end
    def derive({:exp, e, {:num, n}}, v) do 
        {:mul, 
            {:mul, {:num, n}, {:exp, e, {:num, n-1}}}, 
            derive(e, v)}
    end
    def derive({:ln, {:num, 0}}, _) do 
        raise "ln(0) is undefined bro"
    end
    def derive({:ln, e}, v) do 
        {:mul, 
            {:div, {:num, 1}, e}, derive(e, v)}
    end
    def derive({:div, _, {:num, 0}}, _) do
        raise "Division with zero is undefined bro"
    end
    def derive({:div, e1, e2}, v) do
        {:div, 
            {:add, 
                {:mul, derive(e1, v), e2},
                {:mul, {:num, -1}, {:mul, e1, derive(e2, v)}}},
            {:exp, e2, {:num, 2}}
        }
    end
    def derive({:squ, e}, v) do
        if (e < {:num, 0}) do raise "sqrt of a negative number is undefined bro" end 
        {:div, derive(e, v), {:mul, {:squ, e}, {:num, 2}}}
    end

    def derive({:sin, {:num, _}}, _) do 0 end

    def derive({:sin, e}, v) do
        {:mul, {:cos, e}, derive(e, v)}
    end
    def derive({:cos, e}, v) do
        {:mul, {:mul, {:num, -1}, derive(e, v)}, {:sin, e}} 
    end

    def calc({:num, n}, _, _) do {:num, n} end
    def calc({:var, v}, v, n) do {:num, n} end
    def calc({:var, v}, _, _) do {:var, v} end
    def calc({:add, e1, e2}, v, n) do 
        {:add, calc(e1, v, n), calc(e2, v, n)}
    end
    def calc({:mul, e1, e2}, v, n) do
        {:mul, calc(e1, v, n), calc(e2, v, n)}
    end
    def calc({:exp, e1, e2}, v, n) do 
        {:exp, calc(e1, v, n), calc(e2, v, n)}
    end
    def calc({:div, e1, e2}, v, n) do 
        {:div, calc(e1, v, n), calc(e2, v, n)}
    end
    def calc({:squ, e}, v, n) do 
        {:squ, calc(e, v, n)}
    end
    def calc({:sin, e}, v, n) do 
        {:sin, calc(e, v, n)}
    end
    def calc({:cos, e}, v, n) do
        {:cos, calc(e, v, n)}
    end
    def calc({:ln, e}, v, n) do
        {:ln, calc(e, v, n)}
    end

    def simplify({:add, e1, e2}) do 
        simplify_add(simplify(e1), simplify(e2)) 
    end
    def simplify({:mul, e1, e2}) do 
        simplify_mul(simplify(e1), simplify(e2)) 
    end
    def simplify({:exp, e1, e2}) do 
        simplify_exp(simplify(e1), simplify(e2)) 
    end
    def simplify({:div, e1, e2}) do
        simplify_div(simplify(e1), simplify(e2))
    end
    def simplify({:squ, e}) do 
        simplify_squ(simplify(e))
    end
    def simplify({:sin, e}) do
        simplify_sin(simplify(e))
    end
    def simplify({:cos, e}) do
        simplify_cos(simplify(e))
    end
    def simplify({:ln, e}) do
        simplify_ln(simplify(e))
    end
    def simplify(e) do e end

    def simplify_add(e1, {:num, 0}) do e1 end
    def simplify_add({:num, 0}, e2) do e2 end
    def simplify_add({:num, n1}, {:num, n2}) do {:num, n1+n2} end
    def simplify_add(e1, e2) do {:add, e1, e2} end

    def simplify_mul(_, {:num, 0}) do {:num, 0} end
    def simplify_mul({:num, 0}, _) do {:num, 0} end
    def simplify_mul({:num, 1}, e1) do e1 end
    def simplify_mul(e2, {:num, 1}) do e2 end
    def simplify_mul({:num, n1}, {:num, n2}) do {:num, n1 * n2} end
    def simplify_mul(e1, e2) do {:mul, e1, e2} end

    def simplify_exp(e1, {:num, 1}) do e1 end 
    def simplify_exp(_, {:num, 0}) do {:num, 1} end
    def simplify_exp({:num, n1}, {:num, n2}) do {:num, :math.pow(n1, n2)} end
    def simplify_exp(e1, e2) do {:exp, e1, e2} end

    def simplify_div(_, {:num, 0}) do raise "Division with zero is undefined bro" end
    def simplify_div({:num, 0}, _) do {:num, 0} end
    def simplify_div(e1, e1) do {:num, 1} end
    def simplify_div(e1, {:num, 1}) do e1 end
    def simplify_div({:num, n1}, {:num, n2}) do {:num, n1/n2} end
    def simplify_div(e1, e2) do {:div, e1, e2} end

    # these following (ln) are pretty useless
    def simplify_ln({:num, 0}) do raise "ln(0) is undefined bro" end
    def simplify_ln({:num, n}) do {:num, :math.log(n)} end
    def simplify_ln(e) do {:ln, e} end

    def simplify_squ({:num, n}) do {:num, :math.sqrt(n)} end
    def simplify_squ(e) do {:squ, e} end

    def simplify_sin({:num, n}) do {:num, :math.sin(n)} end
    def simplify_sin(e) do {:sin, e} end

    def simplify_cos({:num, n}) do {:num, :math.cos(n)} end
    def simplify_cos(e) do {:cos, e} end

    def pprint({:num, n}) do "#{n}" end
    def pprint({:var, v}) do "#{v}" end
    def pprint({:add, e1, e2}) do "(#{pprint(e1)} + #{pprint(e2)})" end
    def pprint({:mul, e1, e2}) do "#{pprint(e1)} * #{pprint(e2)}" end
    def pprint({:exp, e1, e2}) do "(#{pprint(e1)}) ^ (#{pprint(e2)})" end
    def pprint({:ln, e1}) do " ln(#{pprint(e1)})" end
    def pprint({:div, e1, e2}) do "(#{pprint(e1)}) / (#{pprint(e2)})" end
    def pprint({:squ, e}) do "sqrt(#{pprint(e)})" end
    def pprint({:cos, e}) do "cos(#{pprint(e)})" end
    def pprint({:sin, e}) do "sin(#{pprint(e)})" end
end