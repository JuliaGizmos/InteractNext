using Base.Test
using InteractNext
import InteractNext: kwargs2vueprops, Propkey
import JSON: json

@testset "kwargs2vueprops" begin
    function bestestfn(; kwargs...)
        kwargs2vueprops(kwargs)
    end

    vbindprops, data = bestestfn(piecewise=true, piecewiseLabel=true)
    @test vbindprops ==
            Dict("piecewise"=>"piecewise", "piecewise-label"=>"piecewiseLabel")
    @test JSON.json(data) ==
            JSON.json(Dict("piecewise"=>true, :piecewiseLabel=>true))
end
