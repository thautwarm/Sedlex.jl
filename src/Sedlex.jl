"""
A re-implementation of OCaml Sedlex: https://github.com/ocaml-community/sedlex
"""
module Sedlex
export lexbuf, from_ustring, LexerStateNotFound
export sedlex_call_state, sedlex_next_int, sedlex_mark, sedlex_start, sedlex_backtrack, sedlex_lexeme

const int = Int32

Base.@kwdef mutable struct lexbuf
    buf::Vector{int}
    len::int
    offset::int
    pos::int
    curr_bol::int
    curr_line::int
    start_pos::int
    start_bol::int
    start_line::int
    marked_pos::int
    marked_bol::int
    marked_line::int
    marked_val::int
    filename::String
    finished::Bool
end

"""
This token does not immediately compute lexemes,
making it possible for the token to get inlined (no allocation) when not used.
"""
struct LightToken
    lexeme_source::Vector{int}
    file::String
    token_id::int
    line::int
    col::int
    span::int
    offset::int
    @inline function LightToken(token_id, src::lexbuf, line, col, span, offset, file)
        new(src.buf, file, token_id, line, col, span, offset)
    end
end

function empty_lexbuf()
    lexbuf(
        buf = int[],
        len = 0,
        offset = 0,
        pos = 0,
        curr_bol = 0,
        curr_line = 0,
        start_pos = 0,
        start_bol = 0,
        start_line = 0,
        marked_pos = 0,
        marked_bol = 0,
        marked_line = 0,
        marked_val = 0,
        filename = "",
        finished = false,
    )
end

function from_ustring(a::String)
    buf = int.(collect(a))
    
    v_lexbuf = empty_lexbuf()
    
    v_lexbuf.buf = buf
    v_lexbuf.finished = true
    v_lexbuf.len = length(buf)

    return v_lexbuf
end

function new_line(v_lexbuf::lexbuf)
    v_lexbuf.curr_line += 1
    v_lexbuf.curr_bol = v_lexbuf.pos + v_lexbuf.offset
    return nothing
end

function sedlex_next_int(v_lexbuf::lexbuf)::int
    if v_lexbuf.pos == v_lexbuf.len && v_lexbuf.finished
        return int(-1)
    end
    ret = v_lexbuf.buf[v_lexbuf.pos + 1]
    v_lexbuf.pos += 1
    if ret == 10
        new_line(v_lexbuf)
    end
    return ret
end

function mark(v_lexbuf::lexbuf, i::Integer)
    v_lexbuf.marked_pos = v_lexbuf.pos
    v_lexbuf.marked_bol = v_lexbuf.curr_bol
    v_lexbuf.marked_line = v_lexbuf.curr_line
    v_lexbuf.marked_val = int(i)
    return nothing
end

function start(v_lexbuf::lexbuf)
    v_lexbuf.start_pos = v_lexbuf.pos
    v_lexbuf.start_bol = v_lexbuf.curr_bol
    v_lexbuf.start_line = v_lexbuf.curr_line
    mark(v_lexbuf, -1)
end

function backtrack(v_lexbuf::lexbuf)
    v_lexbuf.pos = v_lexbuf.marked_pos
    v_lexbuf.curr_bol = v_lexbuf.marked_bol
    v_lexbuf.curr_line = v_lexbuf.marked_line
    return v_lexbuf.marked_val
end

function lexeme(v_lexbuf::lexbuf)
    String(Char[Char(v_lexbuf.buf[i]) for i = 1+v_lexbuf.start_pos:v_lexbuf.pos])
end

"""
retrive the text from the token object
"""
function lexeme(tk::LightToken)
    buf = tk.lexeme_source
    start_pos = tk.offset
    span = tk.span
    String(Char[Char(buf[i]) for i = 1+start_pos:start_pos+span])
end

struct LexerStateNotFound <: Exception
    i :: Integer
end

@generated function call_state(f_tups::T, i::Integer, args...) where T <: Tuple
    functions = [ft.instance for ft in T.parameters]
    ret = Expr(:block)
    for (i, f) in enumerate(functions)
        push!(ret.args, :(i == $(i - 1) && return $f(args...)))
    end
    push!(ret.args, :($throw($LexerStateNotFound(i))))
    ret
end

const sedlex_call_state = call_state
const sedlex_mark = mark
const sedlex_start = start
const sedlex_backtrack = backtrack
const sedlex_lexeme = lexeme

## Some unused helper functions

function lexeme_start(v_lexbuf::lexbuf)
    v_lexbuf.start_pos + v_lexbuf.offset
end

end
