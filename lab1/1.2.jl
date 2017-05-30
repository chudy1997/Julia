abstract Zwierzę

type Drapieżnik <: Zwierzę
    id::Int64
    pozX::Int64
    pozY::Int64
end

type Ofiara <: Zwierzę
    id::Int64
    pozX::Int64
    pozY::Int64
end

function Ofiara(id::Int64)
    global statID=statID+1
    Ofiara(statID,-1,-1)
end

function Drapieżnik(id::Int64)
    global statID=statID+1
    Drapieżnik(statID,-1,-1)
end

type MiejsceZajęte <: Exception
end

type ZwierzeNieIstnieje <: Exception
end

function dodajZwierzę{T <: Zwierzę}(zwierzę::T, Świat, pozX, pozY)
    if(Świat[pozX][pozY]!=0)
        throw(MiejsceZajęte)
    else
        Świat[pozX][pozY] = zwierzę.id
        zwierzę.pozX = pozX
        zwierzę.pozY = pozY
    end
end

function odległość{T1 <: Zwierzę, T2 <: Zwierzę}(zwierzę1::T1, zwierzę2::T2)
    if(zwierzę1.pozX==-1 || zwierzę2.pozY==-1)
        throw(ZwierzeNieIstnieje)
    end
    abs(zwierzę1.pozX - zwierzę2.pozX)+abs(zwierzę1.pozY - zwierzę2.pozY)
end

function interakcja(zwierzę1::Drapieżnik, zwierzę2::Drapieżnik)
    if(zwierzę1.pozX==-1 || zwierzę2.pozY==-1)
        throw(ZwierzeNieIstnieje)
    end
    print("Wrrrr\n")
end

function interakcja(zwierzę1::Ofiara, zwierzę2::Ofiara)
    if(zwierzę1.pozX==-1 || zwierzę2.pozY==-1)
        throw(ZwierzeNieIstnieje)
    end
    print("Beeee\n")
end


function interakcja(zwierzę1::Drapieżnik, zwierzę2::Ofiara)
    if(zwierzę1.pozX==-1 || zwierzę2.pozY==-1)
        throw(ZwierzeNieIstnieje)
    end
    Świat[zwierzę2.pozX][zwierzę2.pozY] = 0
    zwierzę2.pozX = zwierzę2.pozY = -1
end

function interakcja(zwierzę1::Ofiara, zwierzę2::Drapieżnik)
    if(zwierzę1.pozX==-1 || zwierzę2.pozY==-1)
        throw(ZwierzeNieIstnieje)
    end
    Świat[zwierzę1.pozX][zwierzę1.pozY] = 0
    for i = 1:5, j = 1:5
        if Świat[i][j] == 0
            if zwierzę1.pozX == i &&  zwierzę1.pozY == j
                continue
            end
            Świat[i][j] = 1
            zwierzę1.pozX = i
            zwierzę1.pozY = j
            break
        end
    end
end

function main()
  Świat = [[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0]]
  global statID=0

  gazela = Ofiara(statID)
  mysz = Ofiara(statID)
  kot = Drapieżnik(statID)
  lew = Drapieżnik(statID)

  dodajZwierzę(kot, Świat, 1,2)
  dodajZwierzę(lew, Świat, 4,3)
  dodajZwierzę(mysz, Świat, 1,5)
  dodajZwierzę(gazela, Świat, 2,4)

  print(Świat,'\n')
  interakcja(mysz,gazela)

  print(Świat,'\n')
  interakcja(lew,kot)

  print(Świat,'\n')
  interakcja(lew,gazela)

  print(Świat,'\n')
end
