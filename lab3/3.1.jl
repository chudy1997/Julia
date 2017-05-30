@generated function harmonic_mean_gen{T}(args::T...)
  ex= :(0)
  for i= 1:length(args)
      ex= :($ex+1/args[$i])
  end
  return :(length(args)/$ex)
end

function harmonic_mean_gen_impl{T}(args::T...)
  ex= :(0)
  for i= 1:length(args)
    ex= :($ex+1/args[$i])
  end
  return :($(length(args))/$ex)
end

#harmonic_mean_gen(1,2,3,4,5,6,7,8,9,10) = 3.41417
#harmonic_mean_gen_impl(1,2,3,4,5,6,7,8,9,10)
