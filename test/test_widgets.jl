using InteractNext

s1 = slider(1:20)
#---

sobs = obs(s1)
display.([s1, sobs]);
#---
button1 = button("button one {{clicks}}")
#---
num_clicks = obs(button1)
button2 = button("button two {{clicks}}", num_clicks)
#---
display.([button1, button2, num_clicks]);
#---
button1
#---
using WebIO
WebIO.setup()
dom"div"(
    dom"div"("Hello, World!"),
    dom"div"("Hello, World!"),
    dom"div"("Hello, World!")
)
#---
using WebIO

wrapper = Widget()
wrapper(dom"div"("Hello, World!"))
#---
using Vue
WebIO.setup()

template = dom"p[v-if=visible]"("{{message}}")
ob = Observable("hello")
vue(template, [:message=>ob, :visible=>true])
#---
ob[] = "suckit"

#---
display(MIME("text/html"), "hello")
#---
using WebIO
WebIO.setup()
# dom"div"("allo allo")
dom"script"("""console.log("hello")""")
#---
using Blink
# using Juno
# w = Juno.Atom.blinkplot()
w = Window()
code = """
<script>console.log("hello, this is your console speaking")</script>
<div>yup</div>
"""
@js(w, Blink.fill("body", $code))
#---
using Blink
w = Window()
# w = Juno.Atom.blinkplot()
using InteractNext
s1 = slider(1:20)
sobs = obs(s1)
body!(w, dom"div"(s1, WebIO.render(sobs)))
#---
sobs[] = 9
#---
using InteractNext
#---
m1 = @manipulate for i in 1:20
    i
end
#---
m1
#---
stringmime(MIME"text/html"(), (Blink.@js w Plotly)) |> println
#---
plot(x->sin(2*x), 0:0.1:30)
#---
using WebIO
#---
n = dom"div"("heyyyy")
#---
using InteractNext, Plots
#---
plot(1:10) # MethodError due to world age until this is merged: https://github.com/JuliaPlots/Plots.jl/pull/916
#---
@manipulate for k in 1:20
    plot(x->sin(0.3k*x), 0:0.1:30)
end
#---
m1 = @manipulate for k in 1:20
    plot(x->sin(0.3k*x), 0:0.1:30)
end
#---
WebIO.render_inline(m1) |> println;
#---
using InteractNext
using Blink
# using InteractNext, Blink
using PlotlyJS
mp = @manipulate for k in 1:20, a in ["so", "it", "seems"]
    x = 0:0.1:30
    y = sin.(k*x)
    (a, plot(x, y))
end
w = Window()
body!(w, mp)
# ^^^

#---
using Mux
using InteractNext, Plots

plot(1:10)

function myapp(req)
    @manipulate for k in 1:20
        plot(x->sin(k*x), 0:0.1:30)
    end
end

webio_serve(page("/", req -> myapp(req)))

#---
using Blink, InteractNext
w = Window()
buttondiv = Node(:div, "<button>a button?</button>")
body!(w,buttondiv)
