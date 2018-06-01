using DataStructures, JSON

include("options_widgets.jl")
include("filedialog.jl")

function slider{T}(::Material, vals::Range{T};
                value=medianelement(vals),
                label="", kwargs...)

    if !(value isa Observable)
        value = Observable{T}(value)
    end

    kwdata = Dict{Propkey, Any}(kwargs)
    if !haskey(kwdata, :useKeyboard)
        kwdata[:useKeyboard] = true
    end

    # add the label to the component's data
    kwdata[:label] = label

    extra_vbinds = Dict()

    if vals isa Range
        for (key, val) in
        ((:min, first(vals)), (:max, last(vals)), (:interval, step(vals)))
            # set the data to be added to the Vue instance with the same key
            kwdata[key] = val
        end
    else
        # Vector or Associative
        if vals isa Vector
            vlabels = eltype(vals) <: AbstractFloat ?
                map(x->round(x, 2)|>string, vals) : string.(vals)
            vals = OrderedDict(zip(vlabels, vals))
        end

        # selection slider labels are the keys
        kwdata[:formatter] = @js function(v)
            if (v % 1 === 0) v = v + ".0" end # js removes decimal points on Ints
            $(inverse_dict(vals))[v]
        end
        # selection slider vals are the values
        svals = values(vals) |> collect
        kwdata[:piecewise] = true
        length(svals) < 10 && (kwdata[:piecewiseLabel] = true)
        # using WebIO.jsexpr here allows the slider to potentially have
        # functions as values, which could be interesting.
        extra_vbinds["data"] = "vals"=>WebIO.jsexpr(svals)
    end

    isvert = get(kwdata, :direction, "horizontal") == "vertical"
    extra_styles = if isvert
        kwdata[:dotSize] = 12
        Dict("width"=>"12px", :height=>"300px", Symbol("margin-left")=>"50px",
        :padding=>"0.1px")
    else
        Dict(:width=>"60%", Symbol("margin-top")=>"40px", :padding=>"2px")
    end

    labelwdg = if get(kwdata, :piecewiseLabel, false)
        extra_styles[Symbol("margin-bottom")] = "25px"
        wdglabel(label; padt=32, style=Dict(Symbol("vertical-align")=>"top"))
    else
        wdglabel(label)
    end

    vbindprops, data = kwargs2vueprops(kwdata; extra_vbinds=extra_vbinds)

    prop_str = props2str(vbindprops, Dict("ref"=>"slider", "v-model"=>"value"))

    template = dom"div"(
        labelwdg,
        dom"vue-slider[$prop_str]"(
            style=merge(Dict(:display=>"inline-block"), extra_styles)
        )
    )
    data["value"] = value
    s = vue(template, data)
    import!(s, "https://nightcatsama.github.io/" *
               "vue-slider-component/dist/index.js")

    onimport(s, @js function (Vue, vueSlider)
            Vue.component("vue-slider", vueSlider)

    end)

    primary_obs!(s, "value")
    s
end

"""
`vslider(data; kwargs...)`

Same as `slider` just with direction set to "vertical"
"""
vslider(args...; kwargs...) = slider(args...; direction="vertical", kwargs...)

function button(::Material, text=""; value=0, label=text)
    (value isa Observable) || (value = Observable(value))
    attrdict = Dict("v-on:click"=>"clicks += 1","class"=>"md-raised md-primary")
    template = dom"md-button"(label, attributes=attrdict)
    button = vue(template, ["clicks" => value]; obskey=:clicks)
    primary_obs!(button, "clicks")
    slap_design!(button)
end

function checkbox(::Material; label="", value=false)
    checked=value
    if !(checked isa Observable)
        checked = Observable(checked)
    end

    attrdict = Dict("v-model"=>"checked", "class"=>"md-primary")
    template = dom"md-checkbox"(attributes=attrdict)(label)
    checkbox = vue(template, ["checked" => checked])
    primary_obs!(checkbox, "checked")
    slap_design!(checkbox)
end

"""
`textbox(label=""; text::Union{String, Observable})`

Create a text input area with an optional `label`

e.g. `textbox("enter number:")`
"""
function textbox(::Material, label="";
                 value = "",
                 placeholder=label)

    text=value
    if !(text isa Observable)
        text = Observable(text)
    end
    template = dom"md-input-container"(
                 dom"""md-input[v-model=text, placeholder=$placeholder]"""(),
               )

    textbox = vue(template, ["text"=>text])
    primary_obs!(textbox, "text")
    slap_design!(textbox)
end

function wdglabel(::Material, text; padt=5, padr=10, padb=0, padl=0, style=Dict())
    fullstyle = Dict(:padding=>"$(padt)px $(padr)px $(padb)px $(padl)px")
    merge!(fullstyle, style)
    dom"label[class=md-subheading]"(text;
        style=fullstyle
    )
end
