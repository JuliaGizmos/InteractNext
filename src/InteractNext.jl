module InteractNext

using Reexport
@reexport using InteractBase
using WebIO, Vue, DataStructures, CSSUtil, JSExpr

import InteractBase: primary_obs!, slap_design!, medianelement

import InteractBase:
    filepicker,
    autocomplete,
    input, dropdown,
    checkbox,
    toggle,
    textbox,
    button,
    slider,
    togglebuttons,
    tabs,
    radiobuttons,
    radio,
    wrap,
    wdglabel,
    entry,
    NativeHTML

export Material

struct Material<:InteractBase.WidgetTheme; end

function InteractBase.slap_design!(w::Scope, T::Material)
    import!(w, "/pkg/InteractNext/vue-material.js")
    import!(w, "/pkg/InteractNext/vue-material.css")
    import!(w, "/pkg/InteractNext/fonts.css")
    import!(w, "/pkg/InteractNext/index.js")

    onimport(w, @js function (Vue, VueMaterial)
        Vue.use(VueMaterial)
    end)
    onimport(w, @js function (Vue, vueSlider)
        Vue.component("vue-slider", vueSlider)

    end)
    w
end

InteractBase.settheme!(Material())

include("widgets.jl")

end # module
