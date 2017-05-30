function foo1()
  for i=1:100000
    s=string(i)
  end
end

function foo2()
  for i=1:100
    s=string(i)
  end
end

#dla delay w granicach 0.0001-1.0 wyniki zachowują proporcję, natomiast w górę i w dół wyniki zaczynają odstawać od proporcji
using ProfileView
function profiler()
  foo1()
  foo2()
  del=0.0001
  while del<=1000.0
    Profile.init(delay = del)
    for i=1:500
      @profile foo1()
      @profile foo2()
    end
    print(del,'\n')
    Profile.print()
    del*=10
    #ProfileView.view()
  end
end
