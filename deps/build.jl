const _pkg_root = dirname(dirname(@__FILE__))
const _pkg_deps = joinpath(_pkg_root,"deps")
const _pkg_assets = joinpath(_pkg_root,"assets")

!isdir(_pkg_assets) && mkdir(_pkg_assets)

deps = [
    "https://gitcdn.xyz/cdn/JobJob/" * "vue-material/js-dist/dist/vue-material.js",
    "https://nightcatsama.github.io/" * "vue-slider-component/dist/index.js",
    "https://gitcdn.xyz/cdn/JobJob/" * "vue-material/css-dist/dist/vue-material.css",
    "https://fonts.googleapis.com/css?family=Roboto:400,500,700,400italic|Material+Icons"
]
for (name, dep) in zip(["material.js", "slider.js", "material.css", "fonts.css"], deps)
    download(dep, joinpath(_pkg_assets, name))
end
