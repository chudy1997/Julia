function treeOfTypes(x)
    treeOfTypesRec(x)
    println(x)
end

function treeOfTypesRec(x)
    if(x!=Any)
        treeOfTypesRec(supertype(x))
        print(supertype(x),"->")
    end
end

treeOfTypes(Int64)
