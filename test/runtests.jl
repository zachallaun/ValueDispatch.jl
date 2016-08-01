using FactCheck
using ValueDispatch

facts("Value dispatch fns") do

    context("@on with `=`") do

        @dispatch fizzbuzz(n::Int) = (n % 3 == 0, n % 5 == 0)

        @fact_throws fizzbuzz(15)

        @on (true,true)  fizzbuzz(n) = "fizzbuzz"
        @on (true,false) fizzbuzz(n) = "fizz"
        @on (false,true) fizzbuzz(n) = "buzz"
        @on :default     fizzbuzz(n) = n

        @fact fizzbuzz(15) --> "fizzbuzz"
        @fact fizzbuzz(3)  --> "fizz"
        @fact fizzbuzz(5)  --> "buzz"
        @fact fizzbuzz(4)  --> 4

    end

    context("@on with `function`") do

        @dispatch function bangclang(n::Int)
            (n % 3 == 0, n % 5 == 0)
        end

        @fact_throws bangclang(15)

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

        @fact bangclang(15) --> "bangclang"
        @fact bangclang(3)  --> "bang"
        @fact bangclang(5)  --> "clang"
        @fact bangclang(4)  --> 4

    end

    context("using `register`") do

        @dispatch bizzbazz(n::Int) = (n % 3 == 0, n % 5 == 0)

        register(bizzbazz, (true,true)) do n
            "bizzbazz"
        end
        register(bizzbazz, (true,false)) do n
            "bizz"
        end
        register(n -> "bazz", bizzbazz, (false,true))
        register(n -> n, bizzbazz, :default)

        @fact bizzbazz(15) --> "bizzbazz"
        @fact bizzbazz(3)  --> "bizz"
        @fact bizzbazz(5)  --> "bazz"
        @fact bizzbazz(4)  --> 4

    end

end
