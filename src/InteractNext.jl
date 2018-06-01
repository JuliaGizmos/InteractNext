module InteractNext

using Reexport
@reexport using InteractBase
using WebIO, Vue, DataStructures, CSSUtil, JSExpr

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

function InteractBase.libraries(::Material)
        [
            "/pkg/InteractMaterial/fonts.css",
            "/pkg/InteractMaterial/material.css",
            "/pkg/InteractMaterial/material.js",
            "/pkg/InteractMaterial/slider.js",
        ]
end

function InteractBase.slap_design!(w::Scope, T::Material)
    InteractBase.slap_design!(w, libraries(T))

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
