defmodule Testmips do

  def test() do
    code = Program.assemble(demo())
    #mem = Memory.new([])
    out = Out.new()
    Emulator.run(code, out)
  end

  def demo() do

    [{:addi, 1, 0, 5}, # 5
    {:lw, 2, 0, 3}, # 0
    {:add, 4, 2, 1}, # 5
    {:addi, 5, 0, 1}, # 1
    {:label, :loop},
    {:sub, 4, 4, 5}, # 4
    {:out, 4}, # 4
    {:bne, 4, 0, :loop}, # branch if not equal
    {:halt}]

  end
end

defmodule Registers do

    # new skapar en lista/tupel med alla 32 register
    def new() do
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    end

    # read hämtar värdet i ett register
    def read(_, 0) do 0 end # om register 0 så är värdet 0
    def read(reg, index) do elem(reg, index) end # elem hämtar värdet inuti registret med indexet

    # write skriver till ett register och returnerar hela listan
    def write(reg, 0, _) do reg end # om register 0 kan vi inte skriva till så returnerar omodifierat hela registret
    def write(reg, index, value) do put_elem(reg, index, value) end # put_elem sätter registret på indexet till value

    def memnew() do [] end

    def memput([],adress, newval) do [{adress, newval}] end
    def memput([{adress, value}|tail], adress, newval) do [{adress, newval}|tail] end
    def memput([head|tail], adress, newval) do [head | memput(tail, adress, newval)] end

    def memget([], adress) do 0 end
    def memget([{adress, value}|_], adress) do value end
    def memget([{_,_}|tail], adress) do memget(tail, adress) end

    def newlabel() do [] end

    def addlabel([], x, pc) do [{x, pc}] end
    def addlabel([list], x, pc) do [{x, pc}|list] end

    def findlabel([], x) do 0 end
    def findlabel([{x, pc}|tail], x) do pc end
    def findlabel([{y, pc}|tail], x) do findlabel(tail, x) end
    
end

defmodule Program do

    def assemble(prgm) do
        {:code, List.to_tuple(prgm)} # gör om demo-listan till tupler
    end

    #code are the tuples in a big tuple
    def read({:code, code}, pc) do
        elem(code, pc) # pc is the adress we want to read from and, elem reads value from this adress
    end

end

defmodule Out do

    def new() do [] end

    def put(out, a) do [a|out] end

    def close(out) do Enum.reverse(out) end

end

defmodule Emulator do

    def run(code, out) do
            reg = Registers.new()
            mem = Registers.memnew()
            labels = Registers.newlabel()
            labels = run(0, code, labels)
            #IO.inspect(labels)
            run(0, code, reg, out, mem, labels)
    end

    def run(pc, code, labels)do 
        nextlabel = Program.read(code, pc)

        case nextlabel do
            {:label, x} ->
                labels = Registers.addlabel(labels, x, pc)
                
                run(pc+1, code, labels)
            {:halt} ->
                labels
            {_} ->
                run(pc+1, code, labels)
            {_,_} ->
                run(pc+1, code, labels)
            {_,_,_} ->
                run(pc+1, code, labels)
            {_,_,_,_} ->
                run(pc+1, code, labels)
        end
    end

    def run(pc, code, reg, out, mem, labels) do
        next = Program.read(code, pc)

        case next do
            {:halt} ->
                {Out.close(out), mem, labels}

            {:out, rs} ->
                s = Registers.read(reg, rs)
                out = Out.put(out, s)
                run(pc+1, code, reg, out, mem, labels)
            
            {:add, rd, rs, rt} ->
                s = Registers.read(reg, rs)
                t = Registers.read(reg, rt)
                reg = Registers.write(reg, rd, s + t) 
                result = Registers.read(reg, rd)
                out = Out.put(out, result)
                run(pc+1, code, reg, out, mem, labels)
        
            {:sub, rd, rs, rt} ->
                s = Registers.read(reg, rs)
                t = Registers.read(reg, rt)
                reg = Registers.write(reg, rd, s - t)
                result = Registers.read(reg, rd)
                out = Out.put(out, result)
                run(pc+1, code, reg, out, mem, labels)
            
            {:addi, rt, rs, imm} ->
                s = Registers.read(reg, rs)
                reg = Registers.write(reg, rt, s + imm)
                result = Registers.read(reg, rt)
                out = Out.put(out, result)
                run(pc+1, code, reg, out, mem, labels)
            
            {:lw, rt, rs, imm} ->
                s = Registers.read(reg, rs)
                adress = s + imm
                value = Registers.memget(mem, adress)
                reg = Registers.write(reg, rt, value)
                result = Registers.read(reg, rt)
                out = Out.put(out, result)
                run(pc+1, code, reg, out, mem, labels)
            
            {:sw, rt, rs, imm} ->
                s = Registers.read(reg, rs)
                adress = s + imm
                t = Registers.read(reg, rt)
                mem = Registers.memput(mem, adress, t)
                run(pc+1, code, reg, out, mem, labels)

            {:bne, rs, rt, name} ->
                labelpc = Registers.findlabel(labels, name)
                imm = labelpc - pc
                s = Registers.read(reg, rs)
                t = Registers.read(reg, rt)
                cond do
                    s != t -> run(pc+imm, code, reg, out, mem, labels)
                    s == t ->  run(pc+1, code, reg, out, mem, labels)
                end

            {:label, x} ->
                run(pc+1, code, reg, out, mem, labels)
        end
    end
end

