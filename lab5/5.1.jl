function f(start,stop,step)
  actual=1
  @sync for i in start:step:stop
    @async begin
      j=1
      while j<=10
        if actual==i
          actual=actual%3+1
          print("$i ")
          j+=1
        else
          sleep(0.000001)
        end
      end
    end
  end
end

function example()
  print("for i in 1:1:3\n")
  f(1,3,1)
  print("\n\nfor i in 3:-1:1\n")
  f(3,1,-1)
end
