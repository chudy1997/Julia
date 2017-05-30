# using DifferentialEquations
# using DataFrames
# using Gadfly

function lv(a,b,c,d,prey,pred,t1,t2)
  f=function(t,u,du)
    du[1] = a*u[1] - b*u[1]*u[2]
    du[2] = -c*u[2] + d*u[1]*u[2]
  end
  return solve(ODEProblem(f,[prey,pred],(t1,t2)),RK4(),dt=1/10)
end

function solve_and_write(sol,index)
  out_file = open("out.csv", "a")
  tmp=open("tmp.csv","w")
  write(tmp,"t, x, y, x-y, experiment\n")
  j=1
  for i in sol.u
    write(tmp,string(round(sol.t[j],3))*", "*string(round(i[1],3))*", "*string(round(i[2],3))*", "*string(round(i[1]-i[2],3))*", exp"*string(index)*"\n")
    write(out_file,string(round(sol.t[j],3))*", "*string(round(i[1],3))*", "*string(round(i[2],3))*", "*string(round(i[1]-i[2],3))*", exp"*string(index)*"\n")
    j+=1
  end
  close(tmp)
  close(out_file)
  df = readtable("tmp.csv")
  if index==1
    global df1 = readtable("tmp.csv")
  elseif index==2
    global df2 = readtable("tmp.csv")
  elseif index==3
    global df3 = readtable("tmp.csv")
  elseif index==4
    global df4 = readtable("tmp.csv")
  end
  df5=DataFrame()
  df5[:t]=df[1]
  df5[:x]=df[2]
  df5[:y]=df[3]
  max_prey=maximum(df5[:x])
  min_prey=minimum(df5[:x])
  mean_prey=mean(df5[:x])
  max_pred=maximum(df5[:y])
  min_pred=minimum(df5[:y])
  mean_pred=mean(df5[:y])

  print("exp",index,'\n',"maxPred: ",max_pred," ,minPred: ",min_pred," ,meanPred: ",mean_pred,'\n',"maxPrey: ",max_prey," ,minPrey: ",min_prey," ,meanPrey: ",mean_prey,"\n\n")
  plot(df, layer(x="t", y="x", Geom.line, Theme(default_color= colorant"orange")),
              layer(x="t", y="y", Geom.line), Theme(default_color=colorant"green"),
              Guide.XLabel("t"),
              Guide.YLabel("x/y"),
              Guide.Title("LV"),
              Guide.manual_color_key("Legend", ["x","y"], ["orange", "green"])
              )
end

function generate_examples(i=0)
  out_file = open("out.csv", "w")
  write(out_file,"t, x, y, x-y, experiment\n")
  close(out_file)
  index=1
  if i==1
    solve_and_write(lv(1.0,1.0,1.0,1.0,3.0,1.0,0.0,30.0),index)
  elseif i==2
    solve_and_write(lv(3.0,2.0,3.0,2.0,6.0,2.0,0.0,30.0),index)
  elseif i==3
    solve_and_write(lv(3.0,1.0,2.0,1.0,1.0,3.0,0.0,30.0),index)
  elseif i==4
    solve_and_write(lv(2.0,1.0,3.0,2.0,1.0,3.0,0.0,30.0),index)
  else
      solve_and_write(lv(1.0,1.0,1.0,1.0,3.0,1.0,0.0,30.0),index)
      index+=1
      solve_and_write(lv(3.0,2.0,3.0,2.0,6.0,2.0,0.0,30.0),index)
      index+=1
      solve_and_write(lv(3.0,1.0,2.0,1.0,1.0,3.0,0.0,30.0),index)
      index+=1
      solve_and_write(lv(2.0,1.0,3.0,2.0,1.0,3.0,0.0,30.0),index)
  end
end

function plotSth()
  generate_examples(5)
  df = readtable("out.csv")
  df1=DataFrame()
  tmp=df[df[:experiment] .=="exp1", :]
  df1[:t1]=tmp[1]
  df1[:x1]=tmp[2]
  df1[:y1]=tmp[3]
  tmp=df[df[:experiment] .=="exp2", :]
  df1[:t2]=tmp[1]
  df1[:x2]=tmp[2]
  df1[:y2]=tmp[3]
  tmp=df[df[:experiment] .=="exp3", :]
  df1[:t3]=tmp[1]
  df1[:x3]=tmp[2]
  df1[:y3]=tmp[3]
  tmp=df[df[:experiment] .=="exp4", :]
  df1[:t4]=tmp[1]
  df1[:x4]=tmp[2]
  df1[:y4]=tmp[3]
  plot(df1,layer(x="x1", y="y1",Geom.point,Theme(default_color= colorant"orange")),layer(x="x2", y="y2",Geom.point,Theme(default_color= colorant"red")),layer(x="x3", y="y3",Geom.point,Theme(default_color= colorant"purple")),layer(x="x4", y="y4",Geom.point,Theme(default_color= colorant"blue")))

  p1=plot(df1,Guide.title("Lotka-Volterra"),Guide.xlabel("t"),Guide.ylabel("x/y"),Guide.manual_color_key("Legend", ["Prey","Predators"],["blue", "green"]),
  layer(x="t1", y="x1",Geom.line,Theme(default_color= colorant"blue")),layer(x="t1", y="y1",Geom.line,Theme(default_color= colorant"green")))
  p2=plot(df1,Guide.title("Lotka-Volterra"),Guide.xlabel("t"),Guide.ylabel("x/y"),Guide.manual_color_key("Legend", ["Prey","Predators"],["blue", "green"]),
  layer(x="t2", y="x2",Geom.line,Theme(default_color= colorant"blue")),layer(x="t2", y="y2",Geom.line,Theme(default_color= colorant"green")))
  p3=plot(df1,Guide.title("Lotka-Volterra"),Guide.xlabel("t"),Guide.ylabel("x/y"),Guide.manual_color_key("Legend", ["Prey","Predators"],["blue", "green"]),
  layer(x="t3", y="x3",Geom.line,Theme(default_color= colorant"blue")),layer(x="t3", y="y3",Geom.line,Theme(default_color= colorant"green")))
  p4=plot(df1,Guide.title("Lotka-Volterra"),Guide.xlabel("t"),Guide.ylabel("x/y"),Guide.manual_color_key("Legend", ["Prey","Predators"],["blue", "green"]),
  layer(x="t4", y="x4",Geom.line,Theme(default_color= colorant"blue")),layer(x="t4", y="y4",Geom.line,Theme(default_color= colorant"green")))
  p=vstack(hstack(p1,p2),hstack(p3,p4))
  draw(SVG("out.svg",15inch,7inch),p)

end
