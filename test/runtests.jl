using InteractNext, Observables, Colors, DataStructures
import InteractBase: scope
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

@testset "input" begin
    a = InteractBase.input();
    @test observe(a)[] == ""
    a = InteractBase.input(typ = "number");
    @test observe(a)[] == 0
    s = Observable{Any}(12)
    a = InteractBase.input(s, typ = "number");
    @test observe(a)[] == s[]
end

@testset "input widgets" begin
    a = filepicker()
    @test scope(a)["filename"][] == ""
    @test scope(a)["path"][] == ""
    scope(a)["path"][] = "/home/Jack/documents/test.csv"
    @test scope(a)["path"][] == observe(a)[] == "/home/Jack/documents/test.csv"

    a = datepicker(value = Dates.Date(01,01,01))
    b = datepicker(Dates.Date(01,01,01))
    @test observe(a)[] == observe(b)[] == Dates.Date(01,01,01)

    a = colorpicker(value = colorant"red")
    b = colorpicker(colorant"red")
    @test observe(a)[] == observe(b)[] == colorant"red"

    a = spinbox(label = "")
    @test observe(a)[] == nothing
    @test observe(a, "internalvalue")[] == ""
    observe(a, "internalvalue")[] = "12"
    @test observe(a)[] == 12

    a = textbox();
    @test observe(a)[] == ""
    s = "asd"
    a = textbox(value = s);
    @test observe(a)[] == "asd"

    # a = autocomplete(["aa", "bb", "cc"], value = "a");
    # @test observe(a)[] == "a"

    a = button("Press me!", value = 12)
    @test observe(a)[] == 12

    a = toggle(label = "Agreed")
    @test observe(a)[] == false
    s = Observable(true)
    a = toggle(s, label = "Agreed")
    @test observe(a)[] == true

    v = slider([0, 12, 22], value = 12)
    @test observe(v)[] == 12
    @test observe(v, "internalvalue")[] == 2
    observe(v, "internalvalue")[] = 3
    @test observe(v)[] == 22

end

@testset "options" begin
    a = dropdown(["a", "b", "c"])
    @test observe(a)[] == "a"
    a = dropdown(OrderedDict("a" => 1, "b" => 2, "c" => 3))
    @test observe(a)[] == 1
    a = dropdown(OrderedDict("a" => 1, "b" => 2, "c" => 3), value = 3)
    @test observe(a)[] == 3

    a = togglebuttons(["a", "b", "c"])
    @test observe(a)[] == "b"
    a = togglebuttons(OrderedDict("a" => 1, "b" => 2, "c"=>3))
    @test observe(a)[] == 2
    a = togglebuttons(OrderedDict("a" => 1, "b" => 2, "c" => 4), value = 3)
    @test observe(a)[] == 4

    a = radiobuttons(["a", "b", "c"])
    @test observe(a)[] == "a"
    a = radiobuttons(OrderedDict("a" => 1, "b" => 2, "c" => 3))
    @test observe(a)[] == 1
    a = radiobuttons(OrderedDict("a" => 1, "b" => 2, "c" => 3), value = 3)
    @test observe(a)[] == 3
end

@testset "ijulia" begin
    @test !InteractBase.isijulia()
end
