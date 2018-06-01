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
            this.filename = fileArray.map(function (el) {return el.name;});
            return this.path = fileArray.map(function (el) {return el.path;});
        }
        """
        filename = Observable(String[])
        path = Observable(String[])
    else
        onFileUpload = js"""function (event){
            this.filename = event[0].name;
            return this.path = event[0].path;
        }
        """
        filename = Observable("")
        path = Observable("")
    end
    m_str = multiple ? ",multiple=true" : ""
    template = dom"md-input-container"(
        dom"label"(label),
        dom"md-file[v-on:selected=onFileUpload,placeholder=$placeholder$m_str,accept=$accept]"(),
    )

    filewidget = vue(template, ["path"=>path, "filename"=>filename], methods = Dict("onFileUpload" => onFileUpload))
    primary_obs!(filewidget, "path")
    slap_design!(filewidget)
end
