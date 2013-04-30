using FactCheck
using ValueDispatch

@facts "Value dispatch fns" begin

    @fact "using `=`" begin

        @dispatch fizzbuzz(n::Int) = (n % 3 == 0, n % 5 == 0)

        fizzbuzz(15) => :throws

        @value fizzbuzz(n)::(true,  true ) = "fizzbuzz"
        @value fizzbuzz(n)::(true,  false) = "fizz"
        @value fizzbuzz(n)::(false, true ) = "buzz"
        @value fizzbuzz(n)::(:default)     = n

        fizzbuzz(15) => "fizzbuzz"
        fizzbuzz(3)  => "fizz"
        fizzbuzz(5)  => "buzz"
        fizzbuzz(4)  => 4

    end

    @fact "using `function`" begin

        @dispatch function bangclang(n::Int)
            (n % 3 == 0, n % 5 == 0)
        end

        bangclang(15) => :throws

        @value function bangclang(n)::(true,  true )
            "bangclang"
        end
        @value function bangclang(n)::(true,  false)
            "bang"
        end
        @value function bangclang(n)::(false,  true)
            "clang"
        end
        @value function bangclang(n)::(:default)
            n
        end

        bangclang(15) => "bangclang"
        bangclang(3)  => "bang"
        bangclang(5)  => "clang"
        bangclang(4)  => 4

    end

end
