#Szyfr Cezara
function isBigLetter(s::Char)
    s<='Z' && s>='A'
end

function isSmallLetter(s::Char)
    s<='z' && s>='a'
end

function findCezarChar(s::Char)
    if isBigLetter(s)
        Char((Int(s)+3-Int('A'))%26+Int('A'))
    elseif isSmallLetter(s)
        Char((Int(s)+3-Int('a'))%26+Int('a'))
    else
        s
    end
end

function reverseFindCezarChar(s::Char)
    if isBigLetter(s)
        Char((Int(s)-Int('A')+23)%26+Int('A'))
    elseif isSmallLetter(s)
        Char((Int(s)-Int('a')+23)%26+Int('a'))
    else
        s
    end
end

#scrambler
function scrambler(str::String)
    str=map((s) -> findCezarChar(s),str)
end

#descrambler
function descrambler(str::String)
    str=map((s) -> reverseFindCezarChar(s),str)
end
