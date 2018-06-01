"""
`togglebuttons(options::Associative; selected::Union{T, Observable}, multiple=false)`

Creates a set of toggle buttons whose labels will be the keys of options.

If `multiple=true` the observable will hold an array containing the values
corresponding to all selected buttons

e.g. `togglebuttons(OrderedDict("good"=>1, "better"=>2, "amazing"=>9001))`
"""
function togglebuttons(options::Associative;
                       multiple=false, label="",
                       selected = multiple ?
                           Vector{Int}() : medianelement(1:length(options)))

    if !(selected isa Observable)
        selected = Observable{Any}(selected)
    end

    buttons =
        dom"md-button[v-on:click=select_fn(value), :key=idx,
                      :class={'md-toggle': is_selected(value)}]"(
            "{{label}}",
            # commas in attribute values (value, label, idx), don't parse well
            # in the dom"...", so we'll use the `attributes` kwarg
            attributes=Dict("v-for"=>"(value, label, idx) in options"),
            style=Dict(:textTransform=>"none")
        )

    select_fn = @js function (val)
        if (this.single_select)
            this.selected = val
        else
            this.selected.indexOf(val) === -1 ?
                this.selected.push(val) : # push if not in list
                this.selected.splice(this.selected.indexOf(val), 1) # remove if in list
        end
    end
    is_selected = @js function(val)
        @var res
        if (this.single_select)
            res = (this.selected === val)
        else
            res = (this.selected.indexOf(val) >= 0)
        end
        return res
    end

    template = dom"div"(
        wdglabel(label),
        dom"md-button-toggle[class=md-raised md-primary, :md-single=single_select, :md-manual-toggle=manual_toggle]"(buttons),
        style=Dict(:display=>"inline-flex")
    )

    vals = collect(values(options))
    labels_idxs = Dict(zip(keys(options), 1:length(options)))
    ob2 = Observable{Any}(vals[selected[]])
    on(selected) do x
        ob2[] = vals[x]
    end

    toglbtns = vue(template, ["selected" => selected,
                              :single_select=>!multiple,
                              :manual_toggle=>true,
                              :options=>labels_idxs],
                   methods=Dict("select_fn"=>select_fn,
                                "is_selected"=>is_selected))
    toglbtns["selected"] = selected
    @private toglbtns["value"] = ob2
    primary_obs!(toglbtns, ob2)
    slap_material_design!(toglbtns)
end

"""
`togglebuttons(values::AbstractArray; kwargs...)`

togglebuttons with labels `string.(values)`

see togglebuttons(options::Associative; ...) for more details
"""
togglebuttons(vals::AbstractArray; kwargs...) =
    togglebuttons(OrderedDict(zip(string.(vals), vals)); kwargs...)

"""
```
radiobuttons(options::Associative;
             value::Union{T, Observable} = first(values(options)),
             label="")
```

e.g. `radiobuttons(OrderedDict("good"=>1, "better"=>2, "amazing"=>9001))`

optionally, you can specify a `label` for the radio button group
"""
function radiobuttons(options::Associative;
                      selected=first(values(options)), label="")
    if !(selected isa Observable)
        selected = Observable{Any}(selected)
    end

    buttons =
        dom"md-radio[v-model=radio, :md-value=value, :key=idx, class=md-primary]"(
            "{{btnlabel}}",
            # commas in attribute values (value, btnlabel, idx), don't parse well
            # in the dom"...", so we'll use the `attributes` kwarg
            attributes=Dict("v-for"=>"(value, btnlabel, idx) in options")
        )
    template = dom"div"(wdglabel(label), buttons)
    radiobtns = vue(template, ["radio" => selected,
                               :options=>options])
    radiobtns["selected"] = selected
    primary_obs!(radiobtns, "radio")
    slap_material_design!(radiobtns)
end

"""
`radiobuttons(values::AbstractArray; kwargs...)`

radiobuttons with labels `string.(values)`

see radiobuttons(options::Associative; ...) for more details
"""
radiobuttons(vals::AbstractArray; kwargs...) =
    radiobuttons(OrderedDict(zip(string.(vals), vals)); kwargs...)

"""
```
dropdown(options::Associative;
         value = first(values(options)),
         label = "select",
         multiple = false)
```
A dropdown menu whose item labels will be the keys of options.

If `multiple=true` the observable will hold an array containing the values
of all selected items

e.g. `dropdown(OrderedDict("good"=>1, "better"=>2, "amazing"=>9001))`

"""
function dropdown(options::Associative;
                  label="select",
                  multiple=false,
                  selected=multiple ?
                      valtype(options)[] :
                      first(values(options)),
                  modelkey="dropd",
                  kwargs...)
    if !(selected isa Observable)
        selected = Observable{Any}(selected)
    end

    menu_items = map(enumerate(options)) do i_label_value
        i,(itemlabel, value) = i_label_value
        dom"""md-option[key=$i, value=$value]"""(itemlabel)
    end
    multi_str = multiple ? ", multiple=true" : ""
    template = dom"md-input-container"(
                   dom"label"(wdglabel(label)),
                   dom"md-select[v-model=$modelkey$multi_str]"(menu_items...)
               )
    dropmenu = vue(template, [modelkey => selected], kwargs...)
    dropmenu["selected"] = dropmenu[modelkey]
    primary_obs!(dropmenu, "selected")
    slap_material_design!(dropmenu)
end

"""
`dropdown(values::AbstractArray; kwargs...)`
dropdown with labels `string.(values)`

see dropdown(options::Associative; ...) for more details
"""
dropdown(vals::AbstractArray; kwargs...) =
    dropdown(OrderedDict(zip(string.(vals), vals)); kwargs...)
