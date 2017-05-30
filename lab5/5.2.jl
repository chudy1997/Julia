# using Plots
# using Gadfly
# using DataFrames

@everywhere const global_c0=-0.1-0.2im
@everywhere const global_c1=-0.4+0.6im
@everywhere const global_c2=0.285+0.01im
@everywhere const global_c3=-0.8+0.156im
@everywhere const global_c=-0.70176-0.3842im
@everywhere const global case=1

@everywhere function generate_julia(z; c=2, maxiter=200)
    for i=1:maxiter
        if abs(z) > 2
            return i-1
        end
        z = z^2 + c
    end
    return maxiter
end

function calc_julia0!(julia_set, xrange, yrange; maxiter=200, height=400, width_start=1, width_end=400)
   for x=width_start:width_end
        for y=1:height
            z = xrange[x] + 1im*yrange[y]
            if case==0
              julia_set[x, y] = generate_julia(z, c=global_c, maxiter=maxiter)
            else
              julia_set[x, y] = generate_julia(z, c=global_c0, maxiter=maxiter)
            end
        end
    end
end

function calc_julia1!(julia_set, xrange, yrange; maxiter=200, height=400, width_start=1, width_end=400)
  @sync @parallel for x=width_start:width_end
    for y=1:height
      z = xrange[x] + 1im*yrange[y]
      if case==0
        julia_set[x, y] = generate_julia(z, c=global_c, maxiter=maxiter)
      else
        julia_set[x, y] = generate_julia(z, c=global_c1, maxiter=maxiter)
      end
    end
  end
end

@everywhere function fun(x,xrange,yrange,height,julia_set,maxiter)
  for y=1:height
    z = xrange[x] + 1im*yrange[y]
    if case==0
      julia_set[x, y] = generate_julia(z, c=global_c, maxiter=maxiter)
    else
      julia_set[x, y] = generate_julia(z, c=global_c2, maxiter=maxiter)
    end
  end
end

function calc_julia2!(julia_set, xrange, yrange; maxiter=200, height=400, width_start=1, width_end=400)
  x=collect(width_start:width_end)
  pmap((x1)->fun(x1,xrange,yrange,height,julia_set,maxiter),x)
end

@everywhere function rang(julia_set::SharedArray,q::SharedArray)
    index = indexpids(q)
    if index == 0
        return 1:0, 1:0
    end
    n = length(q) - 1
    splits = [round(Int, s) for s in linspace(0,size(julia_set,2),n+1)]
    1:size(julia_set,1), splits[index]+1:splits[index+1]
end

@everywhere function filler!(julia_set, xrange, yrange,irange,jrange,maxiter)
    for i in irange, j in jrange
      z = xrange[i] + 1im*yrange[j]
      if case==0
        julia_set[i, j] = generate_julia(z, c=global_c, maxiter=maxiter)
      else
        julia_set[i, j] = generate_julia(z, c=global_c3, maxiter=maxiter)
      end
    end
end

@everywhere advection_shared_chunk!(q, julia_set,xrange,yrange,maxiter) = filler!(julia_set,xrange,yrange, rang(julia_set,q)...,maxiter)

function calc_julia3!(q,julia_set,xrange,yrange;maxiter=200)
  @sync begin
      for p in q
        @async remotecall_wait(advection_shared_chunk!, p,q, julia_set,xrange,yrange,maxiter)
      end
  end
end

function draw_julia(h,w)
  const maxWorkers=10;
   xmin, xmax = -2,2
   ymin, ymax = -1,1
   xrange = linspace(xmin, xmax, w)
   yrange = linspace(ymin, ymax, h)
   julia_set = SharedArray(Int64, (w, h))

   @time calc_julia0!(julia_set, xrange, yrange, height=h, width_end=w)
   Plots.heatmap(xrange, yrange, julia_set)
   png("lab5/julia0")
   @time calc_julia1!(julia_set, xrange, yrange, height=h, width_end=w)
   Plots.heatmap(xrange, yrange, julia_set)
   png("lab5/julia1")
   @time calc_julia2!(julia_set, xrange, yrange, height=h, width_end=w)
   Plots.heatmap(xrange, yrange, julia_set)
   png("lab5/julia2")
   q = SharedArray(Int,nprocs())
   for i=1:nprocs()
     q[i]=(procs()[i])
   end
   @time calc_julia3!(q,julia_set,xrange,yrange)
   Plots.heatmap(xrange, yrange, julia_set)
   png("lab5/julia3")
end

function write_data_to_file(h,w)
  const maxWorkers=10;
   xmin, xmax = -2,2
   ymin, ymax = -1,1
   xrange = linspace(xmin, xmax, w)
   yrange = linspace(ymin, ymax, h)
   julia_set = SharedArray(Int64, (w, h))
   @time calc_julia1!(julia_set, xrange, yrange, height=h, width_end=w)
   Plots.heatmap(xrange, yrange, julia_set)
   png("lab5/julia1")
   @time calc_julia2!(julia_set, xrange, yrange, height=h, width_end=w)
   Plots.heatmap(xrange, yrange, julia_set)
   png("lab5/julia2")


  q = SharedArray(Int,nprocs())
  for i=1:nprocs()
    q[i]=(procs()[i])
  end
  calc_julia1!(julia_set, xrange, yrange, height=h, width_end=w)
  calc_julia2!(julia_set, xrange, yrange, height=h, width_end=w)
  calc_julia3!(q,julia_set,xrange,yrange)

  out_file = open("lab5/out.csv", "a")
  if nprocs()==2
    write(out_file,"procs, cal1, cal2, cal3\n")
  end
  write(out_file,string(nprocs()-1)*", "*string(@elapsed calc_julia1!(julia_set, xrange, yrange, height=h, width_end=w))*", "*string(@elapsed calc_julia2!(julia_set, xrange, yrange, height=h, width_end=w))*", "*string(@elapsed calc_julia3!(q,julia_set,xrange,yrange))*"\n")
  close(out_file)
end

function draw_julia_from_file(name="lab5/out.csv")
  xmin, xmax = -2,2
  ymin, ymax = -1,1
  xrange = linspace(xmin, xmax, 2000)
  yrange = linspace(ymin, ymax, 2000)
  julia_set = SharedArray(Int64, (2000,2000))

  df = readtable(name)
  tmp=@elapsed calc_julia1!(julia_set, xrange, yrange, height=2000, width_end=2000)
  df0=[collect(0:9),[tmp,tmp,tmp,tmp,tmp,tmp,tmp,tmp,tmp,tmp]]
  Gadfly.plot(df,layer(x=df0[1],y=df0[2],Geom.line,Theme(default_color= colorant"purple")),
  layer(x="procs", y="cal3", Geom.bar,Theme(default_color= colorant"blue")),
  layer(x="procs", y="cal1", Geom.bar,Theme(default_color= colorant"orange")),
  layer(x="procs", y="cal2", Geom.bar,Theme(default_color= colorant"green")),Guide.Title("Julia Set"),
  Guide.manual_color_key("Legend", ["cal1","cal2","cal3","cal0"], ["orange", "green","blue","purple"]),Scale.group_discrete(),
  Guide.XLabel("workers"),Guide.YLabel("time"),Theme(default_color= colorant"green"))

end
