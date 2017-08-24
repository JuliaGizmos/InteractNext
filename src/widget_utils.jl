export obs

using Vue

import WebIO: camel2kebab

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

wdglabel(text; padt=5, padr=10, padb=0, padl=0) =
    dom"label[class=md-subheading]"(text;
        style=Dict(:padding=>"$(padt)px $(padr)px $(padb)px $(padl)px")
    )

const Propkey = Union{Symbol, String}

"""
`props2str(vbindprops::Dict{Propkey, String}, stringprops::Dict{String, String}`
input is
`vbindprops`: Dict of v-bind propnames=>values, e.g. Dict("max"=>"max", "min"=>"min"),
`stringprops`: Dict of vanilla string props, e.g. Dict("v-model"=>"value")
output is `"v-bind:max=max, v-bind:min=min, v-model=value"`
"""
function props2str(vbindprops::Dict{Propkey, String}, stringprops::Dict{String, String})
    vbindpropstr = ["v-bind:$key = $val" for (key, val) in vbindprops]
    vpropstr = ["$key = $val" for (key, val) in stringprops]
    join(vcat(vbindpropstr, vpropstr), ", ")
end

"""
`kwargs2vueprops(kwargs)` => `vbindprops, data`

Takes a vector of kwarg (propname, value) Tuples, returns neat properties
and data that can be passed to a vue instance.

Does camel2kebab conversion that allows passing normally kebab-cased html props
as camelCased keyword arguments.

To enable non-string values in html properties, we can use vue's "v-bind:".
To do so, a `(propname, value)` pair, passed as a kwarg, will be encoded as
`"v-bind:propkey=propname"`, (where `propkey = \$(camel2kebab(propname))`, i.e.
just the propname converted to kebab case). The value will be stored in a
corresponding entry in the returned `data` Dict, `propname=>value`

So we have the following for a ((camelCased) propname, value) pair:
`propkey == camel2kebab(propname)`
`propname == vbindprops[propkey]`
`data[propname] == value`
Note that the data dict requires the camelCased propname in the keys
"""
function kwargs2vueprops(kwargs)
    data = Dict{Propkey, Any}(kwargs)
    camelkeys = map(string, keys(data))
    propapropkeys = camel2kebab.(camelkeys) # kebabs are propa bo
    vbindprops = Dict{Propkey, String}(zip(propapropkeys, camelkeys))
    vbindprops, data
end
