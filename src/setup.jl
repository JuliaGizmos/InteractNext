const jspaths = Dict(
    "vue"=>"https://unpkg.com/vue@2.4.2",
    # "vue"=>"https://gitcdn.xyz/repo/vuejs/vue/master/dist/vue.min.js",
    # "vue"=>"https://gitcdn.xyz/repo/vuejs/vue/v2.4.2/dist/vue.js",
    "vue-slider"=>"https://gitcdn.xyz/repo/NightCatSama/vue-slider-component/v2.3.5/dist/index.js",
    "vue-material"=>"https://gitcdn.xyz/repo/vuematerial/vue-material/v0.7.4/dist/vue-material.js",
    "katex"=>"https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.8.2/katex.min.js",
    "katex-auto"=>"https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.8.2/contrib/auto-render.min.js",
    # "vue-material"=>"https://gitcdn.xyz/repo/vuematerial/vue-material/develop/dist/vue-material.js",
    # "vue-material"=>"https://gitcdn.xyz/repo/JobJob/vue-material/dev/dist/vue-material.js",
    # "vue-material"=>"file:///Users/job/Code/js/vue-material/dist/vue-material.js",
)

# TODO different deps for each widget type and/or async begin loading on using InteractNext
const widget_deps = [
    # CSS Deps
    # css only gets loaded once - not for all widgets - see
    # https://github.com/JuliaGizmos/WebIO.jl/blob/master/assets/basics/node.js#L206

    # Katex CSS
    Dict("url"=>"https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.8.2/katex.min.css", "type"=>"css"),

    # Vue material CSS
    Dict("url"=>"https://gitcdn.xyz/repo/JobJob/vue-material/css-dist/dist/vue-material.css", "type"=>"css"),
    # Dict("url"=>"https://gitcdn.xyz/repo/vuematerial/vue-material/develop/dist/vue-material.css", "type"=>"css"),

    # Widget js libs whose paths are set in the call to SystemJS.config
    Dict("url"=>"vue", "type"=>"js"),
    Dict("url"=>"vue-slider", "type"=>"js"),
    Dict("url"=>"vue-material", "type"=>"js"),
    Dict("url"=>"katex", "type"=>"js"),
    Dict("url"=>"katex-auto", "type"=>"js"),
]

const systemjs_config = Dict(
    "paths"=>jspaths
)

# Run before dependencies are loaded to set up js paths
const predeps_fn = @js function ()
    SystemJS.config($systemjs_config)
end

# Run when dependencies are loaded, but before Vue instance is created
# Initialises Vue componenet libraries
const ondeps_fn = @js function (Vue, VueSlider, VueMaterial, Katex, KatexAuto)
    if !Vue.vue_components_inited
        console.log("initing Vue components")
        Vue.component("vue-slider", VueSlider)
        Vue.use(VueMaterial)
        Vue.vue_components_inited = true
        window.katex = Katex
        window.katex.renderMathInElement = KatexAuto
    end
end

function webio_setup()
    Base.invokelatest(WebIO.register_renderable, Manipulate)
end
