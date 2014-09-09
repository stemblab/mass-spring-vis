nSprings = 8
springsAndMasses = new $blab.SpringsAndMasses("ms_container", nSprings) #;
x = numeric.linspace -0.5, 0.5, nSprings+1
disp = numeric.sin(2*Math.PI*x)
vel = numeric.linspace 0, 1, nSprings+1
springsAndMasses.plot(disp, vel)

