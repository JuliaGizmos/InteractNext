"""
`filepicker(label=""; placeholder="", multiple=false, accept="*")`

Create a widget to select files.

If `multiple=true` the observable will hold an array containing the paths of all
selected files. Use `accept` to only accept some formats, e.g. `accept=".csv"`
"""
function filepicker(::Material, lbl = "Choose a file..."; label=lbl, class="", placeholder="", multiple=false, accept="*")

    if multiple
        onFileUpload = js"""function (event){
            var fileArray = Array.from(event)
            return this.path = fileArray.map(function (el) {return el.path;});
        }
        """
        path = Observable(String[])
    else
        onFileUpload = js"""function (event){
            return this.path = event[0].path
        }
        """
        path = Observable("")
    end
    m_str = multiple ? ",multiple=true" : ""
    template = dom"md-input-container"(
        dom"label"(label),
        dom"md-file[v-on:selected=onFileUpload,placeholder=$placeholder$m_str,accept=$accept]"(),
    )

    filewidget = vue(template, ["path"=>path], methods = Dict("onFileUpload" => onFileUpload))
    InteractBase.primary_obs!(filewidget, "path")
    InteractBase.slap_design!(filewidget)
end
