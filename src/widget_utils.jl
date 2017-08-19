export obs

using Vue

# store mapping from widgets to observables
widgobs = Dict{Any, Observable}()
# users access a widget's Observable via this function
obs(widget) = widgobs[widget]

function make_widget(template, wobs::Observable;
                     obskey=:value, realobs=wobs, data=Dict(),
                     run_predeps=predeps_fn, run_ondeps=ondeps_fn,
                     watch_obs=true, kwargs...)
    watch_obs && on(identity, wobs) # ensures updates propagate back to julia
    data[obskey] = wobs
    widget = vue(template, data; dependencies=widget_deps,
                 run_predeps=run_predeps, run_ondeps=run_ondeps, kwargs...)
    widgobs[widget] = realobs
    widget
end

kwargstr(; kwargs...) = join(map(kw->string(kw[1],"=",kw[2]),kwargs), ",")

"""Helps init widget's value and observable depending on which ones were set"""
function init_wsigval(obs, value; default=value, typ=typeof(default))
    if obs == nothing
        if value == nothing
            value = default
        end
        _typ = typ === Void ? typeof(value) : typ
        obs = Observable{_typ}(value)
    else
        # obs was set
        if value == nothing
            value = obs[]
        else
            #signal set and value set
            obs[] = value
        end
    end
    obs, value
end

# Get median elements of ranges, used for initialising sliders.
# Differs from median(r) in that it always returns an element of the range
medianidx(r) = (1+length(r)) ÷ 2
medianelement(r::Union{Range, Array}) = r[medianidx(r)]
medianelement(r::Associative) = collect(values(r))[medianidx(values(r))]

inverse_dict(d::Associative) = Dict(zip(values(d), keys(d)))
