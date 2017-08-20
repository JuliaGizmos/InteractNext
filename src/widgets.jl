export slider, button, checkbox, textbox

using DataStructures, JSON

include("widget_utils.jl")
include("options_widgets.jl")
include("output_widgets.jl")

"""
```
function slider(data; # Range or Vector or Associative
                value=medianelement(range),
                ob::Observable=Observable(value),
                label="", kwargs...)
```

Creates a slider widget which updates observable `ob` when the slider is changed:
```
# slider from Range
s1 = slider(1:10; label="slide on", value="7")
slider_obs = obs(s1)

# slider from Array
lyrics = ["When","I","wake","up","yes","I ","know","I'm","gonna","be"]
s2 = slider(lyrics; label="Proclaim", value="7")
slider_obs = obs(s2)

# slider from Associative
# The slider will have keys(d) for its labels, while obs(s3) will hold d[selected]

using DataStructures
lyrics = ["When","I","wake","up","yes","I ","know","I'm","gonna","be"]
d = OrderedDict(zip(lyrics, 1:length(lyrics))
s3 = slider(d); label="No true Scotsman", value="7")
slider_obs = obs(s3)
```

Slider uses the Vue Slider Component from https://github.com/NightCatSama/vue-slider-component
you can pass any properties you wish to set as keyword arguments, e.g.
To make a vertical slider you can use
```
s = slider(1:10; label="level", value="3", orientation="vertical")
```
N.b. there is also a shorthand for that particular case - `vslider`
"""
function slider{T}(data::Union{Range{T}, Vector{T}, Associative{<:Any, T}};
                value=nothing,
                ob=nothing,
                label="", kwargs...)
    ob, value = init_wsigval(ob, value; typ=T, default=medianelement(data))
    obshadow = ob
    if data isa Range
        push!(kwargs, (:min, first(data)), (:max, last(data)), (:interval, step(data)))
    elseif data isa Vector
        push!(kwargs, ("v-bind:data", JSON.json(collect(data))))
    elseif data isa Associative
        push!(kwargs, ("v-bind:data", data |> keys |> collect |> JSON.json))
        obshadow = Observable(inverse_dict(data)[value])
        map!((v)->data[v], ob, obshadow)
    end

    push!(kwargs, (:ref, "slider"), ("v-model", "value"))
    attrdict = Dict(kwargs)
    template = dom"div"(
        wdglabel(label),
        dom"vue-slider"(attributes=attrdict,
            style=Dict(:width=>"60%", :display=>"inline-block",
                :padding=>"2px", Symbol("margin-top")=>"40px")
        )
    )
    s = make_widget(template, obshadow; realobs=ob)
end

"""
`vslider(range::Range; kwargs...)`

Same as `slider` just with orientation set to "vertical"
"""
vslider(data; kwargs...) = slider(data; orientation="vertical", kwargs...)

"""
button(text=""; ob::Observable = Observable(0))

Note the button text supports a special `clicks` variable, e.g.:
`button("clicked {{clicks}} times")`
"""
function button(text=""; ob::Observable = Observable(0), label="")
    attrdict = Dict("v-on:click"=>"clicks += 1","class"=>"md-raised md-primary")
    template = dom"div"(
        wdglabel(label), 
        dom"md-button"(text, attributes=attrdict)
    )
    button = make_widget(template, clicks; obskey=:clicks)
end

"""
```
checkbox(checked=false;
         label="",
         ob::Observable = Observable(checked))
```

e.g. `checkbox("be my friend?", checked=false)`
"""
function checkbox(checked=nothing;
                  label="",
                  ob=nothing)
    ob, value = init_wsigval(ob, checked; default=false)
    attrdict = Dict("v-model"=>"checked", "class"=>"md-primary")
    template = Node(Symbol("md-checkbox"), attributes=attrdict)(label)
    checkbox = make_widget(template, ob; obskey=:checked)
end

"""
```
textbox(label="";
        ob::Observable = Observable(""))
```

Create a text input area with an optional `label`

e.g. `textbox("enter number:")`
"""
function textbox(label=""; ob::Observable = Observable(""), placeholder="")
    template = dom"md-input-container"(
                 dom"label"(label),
                 dom"""md-input[v-model=text, placeholder=$placeholder]"""(),
               )
    textbox = make_widget(template, ob; obskey=:text)
end
