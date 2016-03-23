module ValueDispatch

using ExpressionUtils

export @dispatch, @on, register

const dispatchtable = Dict{Function, Dict}()

macro dispatch(ex)
    if ex.head == :(=)
        template = quote
            _ESC_name_(_SPLAT_params_) = _SPLAT_body_
        end
    elseif ex.head == :function
        template = quote
            function _ESC_name_(_SPLAT_params_)
                _SPLAT_body_
            end
        end
    else
        error(ArgumentError, "@dispatch must be given a generic function literal")
    end

    @gensym method

    out = quote
        local methodtable = Dict{Any, Any}(:default => false)

        function _name_(_UNSPLAT_params_)
            val = begin _UNSPLAT_body_ end
            method = get(methodtable, val, methodtable[:default])
            if method != false
                method(_UNSPLAT_params_)
            else
                error("No implementation for dispatch value $val")
            end
        end
        dispatchtable[_name_] = methodtable
        _name_
    end

    expr_replace(ex, template, out)
end

function register(method::Function, dispatchfn::Function, val)
    methodtable = get(dispatchtable, dispatchfn, false)
    if methodtable != false
        methodtable[val] = method
    else
        error("$dispatchfn is not a multimethod dispatch function")
    end
    dispatchfn
end

macro on(val, ex)
    if ex.head == :(=)
        template = :(_ESC_name_(_SPLAT_params_) = _SPLAT_body_)
    elseif ex.head == :function
        template = quote
            function _ESC_name_(_SPLAT_params_)
                _SPLAT_body_
            end
        end
    else
        error(ArgumentError, "@value must be given a generic function literal")
    end

    out = quote
        register(function (_UNSPLAT_params_)
            _UNSPLAT_body_
        end, _name_, $(esc(val)))
    end

    expr_replace(ex, template, out)
end

end # module ValueDispatch
