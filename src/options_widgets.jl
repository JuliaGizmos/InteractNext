export togglebuttons, radiobuttons, dropdown

"""
```
togglebuttons(labels_values::Associative;
              value = first(values(labels_values)),
              ob::Observable = Observable(value),
              multiselect=false)

Creates a set of toggle buttons whose labels will be the keys of labels_values.
When selected the widget's observable `ob` will hold the corresponding value
of the last selected button.

If `multiselect=true` the observable will hold an array containing the values
corresponding to all selected buttons
```
e.g. `togglebuttons(OrderedDict("good"=>1, "better"=>2, "amazing"=>9001))`
"""
function togglebuttons(labels_values::Associative;
                       ob = nothing, value=nothing, multiselect=false)
    defaultval = multiselect ? valtype(labels_values)[] : first(values(labels_values))
    ob, value = init_wsigval(ob, value; default=defaultval)
    btns = map(enumerate(labels_values)) do i_label_value
        i,(label, value) = i_label_value
        select_fn = "selected=$value"
        multiselect && (select_fn =
            """ selected.indexOf($value) == -1 ? selected.push($value) :
                    selected.splice(selected.indexOf($value), 1) """
        )
        dom"""md-button[value=$value, id=$i]"""(label;
                                        attributes=Dict("v-on:click"=>select_fn))
    end
    attrdict = Dict{String, Any}()
    !multiselect && (attrdict["md-single"] = true)
    template = Node(Symbol("md-button-toggle"); attributes=attrdict)(btns...)
    toglbtns = InteractNext.make_widget(template, ob; obskey=:selected)
end

"""
togglebuttons(values::AbstractArray; kwargs...)
creates togglebuttons with labels `string.(values)`

see togglebuttons(labels_values::Associative; ...) for more details
"""
togglebuttons(vals::AbstractArray; kwargs...) =
    togglebuttons(OrderedDict(zip(string.(vals), vals)); kwargs...)

"""
```
radiobuttons(labels_values::Associative;
              value = first(values(labels_values)),
              ob::Observable = Observable(value))
```
e.g. `radiobuttons(OrderedDict("good"=>1, "better"=>2, "amazing"=>9001))`
"""
function radiobuttons(labels_values::Associative;
                       ob = nothing, value=nothing)
    defaultval = first(values(labels_values))
    ob, value = init_wsigval(ob, value; default=defaultval)
    # radio buttons only return strings, so we create a shadow obs
    obshadow = Observable(string(ob[]))
    conversion_fn = method_exists(convert, (Type{eltype(ob)}, String)) ? convert : parse
    map!((v)->conversion_fn(eltype(ob), v), ob, obshadow)
    btns = map(enumerate(labels_values)) do i_label_value
        i,(label, value) = i_label_value
        dom"""md-radio[v-model=radio, md-value=$value, class=md-primary]"""(label)
    end
    template = dom"div"(btns...)
    radiobtns = InteractNext.make_widget(template, obshadow; realobs=ob, obskey=:radio)
    widgobs[radiobtns] = ob
    radiobtns
end

"""
radiobuttons(values::AbstractArray; kwargs...)
creates radiobuttons with labels `string.(values)`

see radiobuttons(labels_values::Associative; ...) for more details
"""
radiobuttons(vals::AbstractArray; kwargs...) =
    radiobuttons(OrderedDict(zip(string.(vals), vals)); kwargs...)

"""
```
dropdown(labels_values::Associative;
         value = first(values(labels_values)),
         label = "select",
         ob::Observable = Observable(value),
         multiselect = false)
```
Creates a dropdown menu whose item labels will be the keys of labels_values.
When an item is selected, the widget's observable `ob` will hold the
value of the selected item.

If `multiselect=true` the observable will hold an array containing the values
of all selected items

e.g. `dropdown(OrderedDict("good"=>1, "better"=>2, "amazing"=>9001))`

"""
function dropdown(labels_values::Associative;
                  label="select", ob = nothing,
                  value=nothing, modelkey="dropd",
                  multiselect=false)
    defaultval = multiselect ? valtype(labels_values)[] : first(values(labels_values))
    ob, value = init_wsigval(ob, value; default=defaultval)
    menu_items = map(enumerate(labels_values)) do i_label_value
        i,(itemlabel, value) = i_label_value
        dom"""md-option[:key=$i, :value=$value]"""(itemlabel)
    end
    multi_str = multiselect ? ", multiple=true" : ""
    template =  dom"md-input-container"(
                    dom"label"(label),
                    dom"md-select[v-model=$modelkey$multi_str]"(menu_items...)
                )
    dropmenu = InteractNext.make_widget(template, ob; obskey=Symbol(modelkey))
end

"""
dropdown(values::AbstractArray; kwargs...)
creates dropdown with labels `string.(values)`

see dropdown(labels_values::Associative; ...) for more details
"""
dropdown(vals::AbstractArray; kwargs...) =
    dropdown(OrderedDict(zip(string.(vals), vals)); kwargs...)
