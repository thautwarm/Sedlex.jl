using Sedlex
using Test
include("generated.jl")

#=
(space, Lexer_discard),
(flt, Lexer_tokenize(1)),
(integral, Lexer_tokenize(2)),
(string_lit, Lexer_tokenize(3)),
(pstring("+"), Lexer_tokenize(4)),
(pstring("+="), Lexer_tokenize(5)),
(peof, Lexer_tokenize(EOF_ID))
=#
const ID_space = nothing
const ID_flt = 1
const ID_integral = 2
const ID_plus = 4
@testset "Sedlex.jl" begin
    # Write your tests here.
    xs = lexall(from_ustring("1213 + 1.2"), is_eof) do x...
        Sedlex.LightToken(x...)
    end
    println(collect(xs))
    v_buf = from_ustring("1213 + 1.2")
    
    x = lex(v_buf) do args...
        Token(args...)
    end
    @test x.token_id == ID_integral

    x = lex(v_buf) do args...
        Token(args...)
    end

    @test x === nothing

    x = lex(v_buf) do args...
        Token(args...)
    end

    @test x.token_id == ID_plus

    x = lex(v_buf) do args...
        Token(args...)
    end

    @test x === nothing

    x = lex(v_buf) do args...
        Token(args...)
    end

    @test x.token_id == ID_flt
end
