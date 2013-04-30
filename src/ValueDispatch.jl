module ValueDispatch

using ExpressionUtils

export @dispatch, @value

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
        local methodtable = {:default => false}
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

function addmethod!(dispatchfn::Function, val, method::Function)
    methodtable = get(dispatchtable, dispatchfn, false)
    if methodtable != false
        methodtable[val] = method
    else
        error("$dispatchfn is not a multimethod dispatch function")
    end
    dispatchfn
end

macro value(ex)
    if ex.head == :(=)
        template = :(_ESC_name_(_SPLAT_params_)::_dispatchval_ = _SPLAT_body_)
    elseif ex.head == :function
        template = quote
            function _ESC_name_(_SPLAT_params_)::_dispatchval_
                _SPLAT_body_
            end
        end
    else
        error(ArgumentError, "@value must be given a generic function literal")
    end

    out = quote
        addmethod!(_name_, _dispatchval_, function (_UNSPLAT_params_)
            _UNSPLAT_body_
        end)
    end

    expr_replace(ex, template, out)
end

end # module ValueDispatch
