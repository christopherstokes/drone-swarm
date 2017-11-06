-- title:  Drone Swarm
-- author: Christopher Stokes
-- desc:   shooter playing as drone swarm
--         You Are Not The Main Character
-- script: moon

export width=240
export height=136
export tilesize=8
export fontsize=6

btnAxis=(a,b)->
	if btn(a) and btn(b)
		return 0
	elseif btn(a)
		return -1
	elseif btn(b)
		return 1
	else
		return 0

class Spr
	new:(id=0,w=1,h=1,alpha=0,scale=1,flip=0,rotate=0)=>
		@id=id
		@w=w
		@h=h
		@alpha=alpha
		@scale=scale
		@flip=flip
		@rotate=rotate

	draw:(x,y,chSpr)=>
		spr(@id+chSpr,x,y,@alpha,@scale,@flip,@rotate,@w,@h)

class Mob
	new:(ents={},pattern={"cos",.05},num=20)=>
		@ents=ents
		@pattern=pattern
		@num=num

	addEnt:(ent)=>
		table.insert(@ents,ent)

	changePattern:(pattern)=>
		@pattern=pattern

	update:=>
		for e=#@ents,1,-1
			if @pattern[1]=="cos"
				@ents[e].yChange=math.cos(@ents[e].t*@pattern[2])
			if @pattern[1]=="sin"
				@ents[e].yChange=math.sin(@ents[e].t*@pattern[2])

			@ents[e]\update!
			chSpr=0
			if @ents[e].t%60<30 then chSpr=@ents[e].w/8
			@ents[e].sprt\draw(@ents[e].x,@ents[e].y,chSpr)

			if @ents[e].x<=-(@ents[e].w) or (@ents[e].x>width+@ents[e].w and @ents[e].xChange > 0) then table.remove(@ents,e)

class Entity
	new:(x=0,y=0,sprt=0,w=8,h=8,yChange=0,xChange=-1)=>
		@x=x
		@y=y
		@w=w
		@h=h
		@yChange=yChange
		@xChange=xChange
		@sprt=sprt
		@t=0

	update:=>
		@t+=1
		@y+=@yChange
		@x+=@xChange
		if (((@x<=0 and @xChange < 0) or (@x>=width-@w and @xChange > 0)) and math.random(500)>425)
			@xChange*=-1
			if @sprt.flip==0 then @sprt.flip=1
			else @sprt.flip=0

class Particle
	new:(x=0,y=0,rng=2,dur=30)=>
		@x=x
		@y=y
		@rng=rng
		@dur=dur

class Bullet
	new:(x=0,y=0,dir=1)=>
		@x=x
		@y=y
		@t=0
		@dir=dir
		@col=6

	update:=>
		@t+=.05
		@x+=@t*@dir

	draw:=>
		pix(@x,@y,@col)

class Drone
	new:(x=0,y=0,r=3)=>
		@x=x
		@y=y
		@r=r
		@swr=0 --swarm radius
		@vel={x:math.random(),y:math.random()}

	draw:=>
		circ(@x,@y,@r,0)
		circ(@x,@y,@r-1,7)
		circ(@x+@vel.x,@y+@vel.y,@r-2,15)

	update:(sx,sy)=>
		distX=sx-@x
		distY=sy-@y
		distance=math.sqrt(((distX)^2)+((distY)^2))
		if (distance>@swr)
			if ((@x>sx+@swr) or (@x<sx-@swr))
				@vel.x=distX*(math.random(10)*.01)
			if ((@y>sy+@swr) or (@y<sy-@swr))
				@vel.y=distY*(math.random(10)*.01)

		@x+=@vel.x
		@y+=@vel.y
		@swr=math.random(#swarm.drones)+2

class Swarm
	new:(x=0,y=0,drones={})=>
		@x=x
		@y=y
		@drones=drones

	shoot:(dir=1)=>
		for i=1,#swarm.drones
			b=Bullet(swarm.drones[i].x,swarm.drones[i].y,dir)
			table.insert(bullets,b)

	createDrone:=>
		d=Drone(@x,@y)
		table.insert(@drones,d)

class RectCollider
 new:(x=0,y=0,w=1,h=1)=>
  @x=x
  @y=y
  @w=w
  @h=h

 draw:(col=8)=>
  rectb(@x,@y,@w,@h,col)

 collide:(B)=>
  if @x>(B.x+B.w) or (@x+@w-1)<B.x or @y>(B.y+B.h) or (@y+@h-1)<B.y
   return false
  else
   return true

class CircCollider
 new:(x=0,y=0,r=1)=>
  @x=x
  @y=y
  @r=r

 draw:(col=8)=>
  circb(@x,@y,@r,col)

 collide:(B)=>
  d=(@x-B.x)^2+(@y-B.y)^2
  r=(@r+B.r)^2

  if @x>=(B.x-B.r) and @y>=(B.y-B.r)
   r=(@r+B.r+1)^2

  if d>r
   return false
  else
   return true


createMob=(sp,w=8,h=8,x=width,y=math.random(8,height-16))->
	m=Mob!
	sp=Spr(sp)
	e=Entity(x,y,sp,w,h)
	m\addEnt(e)
	table.insert(mobs,m)

---------Game Loop Code-----------
export t=0
export bullets={}
export swarm=Swarm(120,67)
export mobs={}
swarm\createDrone!

createMob(1,8)
mobs[1]\changePattern({"cos",0.05})

export TIC=->
	if t%120==1
		sp=Spr(1)
		e=Entity(250,math.random(8,height-32),sp,8)
		mobs[1]\addEnt(e)
		--if math.random()>0.7 then mobs[1]\changePattern({"sin",0.03})
		--else mobs[1]\changePattern({"cos",0.05})

	--update
	swarm.y+=btnAxis(0,1) -- movement directions up and down
	swarm.x+=btnAxis(2,3) -- movement directions left and right

	if (btn(4) and t%4>2) then swarm\shoot! -- z button
	-- if (btn(5) and t%4>2) then swarm\shoot(-1) -- x button

	if btnp(7) then swarm\createDrone! -- s button
	if btnp(6) -- a button
		swarm.drones={}
		swarm\createDrone!

	--draw
	cls(0)

	for j=#bullets,1,-1
		bullets[j]\draw!
		bullets[j]\update!
		if bullets[j].x>width+20 or bullets[j].x<-20 then table.remove(bullets,j)

	for i=1,#swarm.drones
		swarm.drones[i]\draw!
		swarm.drones[i]\update(swarm.x,swarm.y)

	for m=#mobs,1,-1
		mobs[m]\update!
		if #mobs[m].ents<1 then table.remove(mobs,m)

	print("bullets: "..#bullets,0,0,6)
	print("drones: "..#swarm.drones,width-60,0)
	print("mobs: "..#mobs,0,height-6,6)
	t+=1
