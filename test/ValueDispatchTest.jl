using FactCheck
using ValueDispatch

@facts "Value dispatch fns" begin

    @fact "@on with `=`" begin

        @dispatch fizzbuzz(n::Int) = (n % 3 == 0, n % 5 == 0)

        fizzbuzz(15) => :throws

        @on (true,true)  fizzbuzz(n) = "fizzbuzz"
        @on (true,false) fizzbuzz(n) = "fizz"
        @on (false,true) fizzbuzz(n) = "buzz"
        @on :default     fizzbuzz(n) = n

        fizzbuzz(15) => "fizzbuzz"
        fizzbuzz(3)  => "fizz"
        fizzbuzz(5)  => "buzz"
        fizzbuzz(4)  => 4

    end

    @fact "@on with `function`" begin

        @dispatch function bangclang(n::Int)
            (n % 3 == 0, n % 5 == 0)
        end

        bangclang(15) => :throws

        @on (true,true) function bangclang(n)
            "bangclang"
        end
        @on (true,false) function bangclang(n)
            "bang"
        end
        @on (false,true) function bangclang(n)
            "clang"
        end
        @on :default function bangclang(n)
            n
        end

        bangclang(15) => "bangclang"
        bangclang(3)  => "bang"
        bangclang(5)  => "clang"
        bangclang(4)  => 4

    end

    @fact "using `register`" begin

        @dispatch bizzbazz(n::Int) = (n % 3 == 0, n % 5 == 0)

        register(bizzbazz, (true,true)) do n
            "bizzbazz"
        end
        register(bizzbazz, (true,false)) do n
            "bizz"
        end
        register(n -> "bazz", bizzbazz, (false,true))
        register(n -> n, bizzbazz, :default)

        bizzbazz(15) => "bizzbazz"
        bizzbazz(3)  => "bizz"
        bizzbazz(5)  => "bazz"
        bizzbazz(4)  => 4

    end

end
