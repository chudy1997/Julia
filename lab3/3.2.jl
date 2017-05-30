macro rec_expansion(formula)
  s=string(formula)
  var=find_var_name(s) #finding variable name
  ran=find_range(s) #finding range

  ret=ran[1]!=1 ? string("for ",var,"=",ran[1],':',ran[2],"\n\t",s,"\nend") : string("for ",var,"=",ran[2],":-1:",ran[1],"\n\t",s,"\nend") #creating loop string
  ex=parse(ret)
  return ex
end

function find_var_name(s::String)
  var=""
  i=1
  while s[i]!='['
    i+=1
  end
  i+=1
  while s[i]!=']'
    var=string(var,s[i])
    i+=1
  end
  var
end

function find_range(s::String)
  min_ind=0;max_ind=0
  for i=1:length(s)
    tmp=""
    if(s[i]=='[')
      i+=2
      while(s[i]!=']')
        tmp=string(tmp,s[i])
        i+=1
      end
      if length(tmp)>0
        temp=parse(Int64,tmp,10)
        if temp<min_ind
          min_ind=temp
        elseif temp>max_ind
          max_ind=temp
        end
      end
    end
  end
  return [abs(min_ind)+1,length(y)-max_ind]
end

function f()
  for i=10:-2:1
    print(i)
  end
end
