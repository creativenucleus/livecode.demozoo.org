t=9TIC=load'cls(6)t=t+.01s=math.sin for y=0,140 do x=(s(y)*99+t*y)%300-20q=15-y/49 for k=0,1 do elli(x,y,9-k,7-k,q*k)circ(x+8,y-8,5-k,q*k)elli(x+14,y-8,3,2,4)pix(x+9,y-9,2)line(x,y,x+s(y*t/9)*(10*k-5),y+9,4)w=s(y*9+t)<.98or print("QUACK",x,y-20,12)end end'