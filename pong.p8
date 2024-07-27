pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- game logic

function _init()
	init_shake()
	menu_scene={
		init=init_menu,
		update=update_menu,
		draw=draw_menu,
	}
	game_scene={
		init=init_game,
		update=update_game,
		draw=draw_game,
	}
	set_scene(game_scene)
end

function _update60()
	update_shake()
	scene.update()
end


function _draw()
	cls()
	scene.draw()
end

function set_scene(s)
	scene=s
	scene.init()
end
-->8
-- menu

function init_menu()
	menu_text='★ menu ★'
end

function update_menu()
	if (btnp(🅾️)) set_scene(game_scene)
end

function draw_menu()
	print(menu_text)
end
-->8
-- game

function init_game()
	game={
		status=0,
		score={
			player=0,
			cpu=0,
		}
	}
	items={
		create_grandma({x=64,y=64},{x=-1,y=0})
	}
	cpu_paddle=create_paddle({x=64,y=4})
	player_paddle=create_paddle({x=64,y=116})
	ball=create_ball({x=64,y=64})
end

function update_game()
	apply_colision_effect({
		player_paddle,
		cpu_paddle,
		ball
	})
	cpu_control(cpu_paddle, ball)
	player_control(player_paddle)
	update_paddle(player_paddle)
	update_paddle(cpu_paddle)
	update_items(items)
	update_ball(ball)
end

function draw_game()
	draw_map()
	draw_paddle(player_paddle)
	draw_paddle(cpu_paddle)
	draw_items(items)
	draw_ball(ball)
	print("player: "..player_paddle.score)
	print("cpu:    "..cpu_paddle.score)
end
-->8
-- game objects

function create_texture(p_txt)
	if(p_txt==nil)p_txt={}
	if(p_txt.x==nil)p_txt.x=0
	if(p_txt.y==nil)p_txt.y=0
	if(p_txt.width==nil)p_txt.width=8
	if(p_txt.height==nil)p_txt.height=8
	if(p_txt.flip_width==nil)p_txt.flip_width=false
	if(p_txt.flip_height==nil)p_txt.flip_height=false
	return p_txt
end

function create_object()
	return {
		position={x=0,y=0},
		velocity={x=0,y=0},
		texture=create_texture(),
		shape={
			width=8,
			height=8,
		},
		speed=1
	}
end

function apply_velocity(object,velocity)
	local s=object.speed
	object.velocity=multiplie_vectors({
		velocity,
		{x=s,y=s}
	})
end

function update_object(object, textures, speed)
	if(textures==nil)textures={}
	if(speed==nil)speed=1
	object.position=add_vectors({
		object.position,
		object.velocity
	})
	local index=flr(time()*speed)%count(textures)
	object.texture=textures[index+1]
end

function draw_object(object)
 local shape=object.shape
 if(shape==nil)shape=object.texture
	sspr(
		object.texture.x,
		object.texture.y,
		object.texture.width,
		object.texture.height,
		object.position.x,
		object.position.y, 
	 shape.width,
	 shape.height,
	 object.texture.flip_width,
	 object.texture.flip_height
 )
end

function apply_colision_effect(objects) 
	for obja in all(objects) do
		for objb in all(objects) do
			if not obja==objb then
				if is_colided(obja,objb) then
					if not obja.colide_fn==nil then
						obja.colide_fn(obja,objb)
					end
				end
			end
		end
	end
end

function is_colided(obja,objb)
	return not (obja.position.x>objb.position.x+objb.shape.width
		or obja.position.y>objb.position.y+objb.shape.height
		or obja.position.x+obja.shape.width<objb.position.x
		or obja.position.y+obja.shape.height<objb.position.y)
end

-->8
-- vectors

function add_vectors(vectors)
	local x=0
	local y=0
	for vector in all(vectors) do
		x+=vector.x
		y+=vector.y
	end
	return{x=x,y=y}
end

function multiplie_vectors(vectors)
	local x=nil
	local y=nil
	for vector in all(vectors) do
		if x==nil then
			x=vector.x
		else
			x*=vector.x
		end
		if y==nil then
			y=vector.y
		else
			y*=vector.y
		end
	end
	return{x=x,y=y}
end
-->8
-- paddle

function create_paddle(position)
	local object=create_object()
	object.score=0
	object.position=position
	object.shape={width=16,height=8}
	object.colide_fn=function(self,obj)
		local middle_x=obj.position.x+(obj.shape.width/2)
		local part=self.shape.width/3		
		if middle_x<self.position.x+part then
			obj.velocity=add_vectors({
				multiplie_vectors({
					obj.velocity,
					{x=1,y=-1}
				}),
				{x=-0.5,y=0}
			})
		elseif middle_x>(self.position.x+(part*2)) then
			obj.velocity=add_vectors({
				multiplie_vectors({
					obj.velocity,
					{x=1,y=-1}
				}),
				{x=0.5,y=0}
			})
		else
			obj.velocity=multiplie_vectors({
				obj.velocity,
				{x=1,y=-1}
			})
		end
	end
	return object
end

function cpu_control(paddle,ball)
	local bx=ball.position.x+(ball.shape.width/2)
	local px=paddle.position.x+(paddle.shape.width/2)
	paddle.velocity.x=0
	if bx>px then
		apply_velocity(paddle,{x=0.7,y=0})
	elseif bx<px then
		apply_velocity(paddle,{x=-0.7,y=0})
	end 
end

function player_control(paddle)
	paddle.velocity={x=0,y=0}
	if(btn(⬅️))apply_velocity(paddle,{x=-1,y=0})
	if(btn(➡️))apply_velocity(paddle,{x=1,y=0})
end

function update_paddle(paddle)
	update_object(paddle,{
		create_texture({x=40,width=16}),
		create_texture({x=40,width=16}),
		create_texture({x=40,width=16}),
		create_texture({x=40,width=16}),
		create_texture({x=40,width=16}),
		create_texture({x=40,width=16}),
		create_texture({x=40,width=16}),
		create_texture({x=40,width=16}),
		create_texture({x=56,width=16}),
		create_texture({x=72,width=16}),
		create_texture({x=56,width=16}),
	},5)
	paddle.position.x=min(paddle.position.x,128-paddle.shape.width)
	paddle.position.x=max(paddle.position.x,0)
end

function draw_paddle(paddle)
	sspr(72,8,16,16,paddle.position.x,paddle.position.y)
	draw_object(paddle)
end
-->8
-- ball

function create_ball(position)
	local object=create_object()
	object.position=position
	object.velocity.x=0
	object.velocity.y=1
	object.shape={
		width=8,
		height=8,
	}
	return object
end

function update_ball(ball,objects)
	bounds_ball(ball)
	update_object(ball,{
		create_texture({x=16}),
		create_texture({x=0}),
		create_texture({x=8}),
	 create_texture({x=0,flip_height=true}),
		create_texture({x=16,flip_height=true}),
		create_texture({x=0,flip_height=true,flip_width=true}),
		create_texture({x=8,flip_width=true}),
		create_texture({x=0,flip_width=true}),
	},15)
end

function draw_ball(ball)
	draw_object(ball)
end

function bounds_ball(ball)
	local bx=ball.position.x
	local by=ball.position.y
	if bx<0 or bx>128-ball.shape.width then
		ball.velocity=multiplie_vectors({
			ball.velocity,
			{x=-1,y=1}
		})
		shake(1)
	end
	if by<0 or by>128-ball.shape.height then
		ball.velocity=multiplie_vectors({
			ball.velocity,
			{x=1,y=-1}
		})
		shake(1)
	end
end

-->8
-- map

function draw_map()
	map(0,0,-16,-16)
	for x=2,17 do
		local bindex=flr(time())%7
		local windex=flr(time()*10)%7
		mset(x,5,34+bindex)
		mset(x,7,50+windex)
		mset(x,9,50+windex)
		mset(x,11,50+windex)
		mset(x,14,18+bindex)
	end
end
-->8
-- items

function create_grandma(position, velocity)
	local reverse=velocity.x>0
	return {
		position=position,
		velocity=velocity,
		animation={
			create_texture({x=0,y=32,flip_width=reverse}),
			create_texture({x=8,y=32,flip_width=reverse})
		},
		colide_fn=function(self,obj)
			if obj.paddle!=nil then
				obj.paddle.score+=1
			end
		end
	}	
end

function update_items(items)
	for item in all(items) do
		update_object(
			item,
			item.animation,
			15
		)
	end
end

function draw_items(items)
	for item in all(items) do
		draw_object(item)
	end
end
-->8
-- shake
function init_shake()
	sf=1
end

function shake(force)
	sf=force
end

function update_shake()
	local fade=0.95
	local sf_offset_x=shake_range(1)	
	local sf_offset_y=shake_range(1)
	sf_offset_x*=sf	
	sf_offset_y*=sf
	camera(sf_offset_x,sf_offset_y)
	sf*=fade
	if(sf<0.5)sf=0
end

function shake_range(range)
	return (range/2)-rnd(range)
end
__gfx__
00111100001111000011110000000000000000000001111111111000000000000000000000000000000000000000000000000000000000000000000000000000
0166771001666610017777100000000000000000111cccccccccc111000111111111100000000000000000000000000000000000000000000000000000000000
1666777116666771167777610000000000000000ccc2222222222ccc111cccccccccc11100011111111110000000000000000000000000000000000000000000
16666771176667711666666100000000000000002222822222282222ccc2222222222ccc111cccccccccc1110000000000000000000000000000000000000000
16666661166667711666666100000000000000002222822222282222ccc2822222282ccc111cccccccccc1110000000000000000000000000000000000000000
1676666116666771166666610000000000000000ccc2222222222ccc111cccccccccc11100011111111110000000000000000000000000000000000000000000
0166661001666610016676100000000000000000111cccccccccc111000111111111100000000000000000000000000000000000000000000000000000000000
00111100001111000011110000000000000000000001111111111000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccffffffffccccccccccc77cccc77cc77ccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
ccccccccffffffff7c77ccc7ccccccccccc77ccccc7cc7cccccccccc7cccccc77cccccc700000000000000000000000000000000000000000000000000000000
ccccccccfffffffff7ff777f7c77ccc7ccccccccccc77ccc7cc77cc7f7cccc7ff777777f00000000000000000000000000000000000000000000000000000000
ccccccccfffffffffffffffff7ff777f7c77ccc77cccccc7777cc77fff7777ffffffffff00000000000000000000000000000000000000000000000000000000
ccccccccfffffffffffffffffffffffff7ff777ff777777ffff77fffffffffffffffffff00000000000000000000000000000000000000000000000000000000
ccccccccffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000
ccccccccffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000
ccccccccffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00005555555500000000000000000000000000000000000000000000
00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00555555555555000000000000000000000000000000000000000000
00000000f44fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00555555555555000000000000000000000000000000000000000000
000000004ff4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00055555555550000000000000000000000000000000000000000000
00000000fffffffffffffffffffffff7f7ff777ff777777ffff77fffffffffffffffffff00000000000000000000000000000000000000000000000000000000
00000000fffffffffffffffff7ff777c7c77ccc77cccccc7777cc77fff7777ffffffffff00000000000000000000000000000000000000000000000000000000
00000000fffffffff7ff777f7c77ccccccccccccccc77ccc7cc77cc7f7cccc7ff777777f00000000000000000000000000000000000000000000000000000000
00000000ffffff4f7c77ccc7ccccccccccc77ccccc7cc7cccccccccc7cccccc77cccccc700000000000000000000000000000000000000000000000000000000
00000000fffff4f4ccccccccccc77cccc77cc77ccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
00000000ff1111ffcccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
00000000f1e22e1fcc77cccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000
0000000012e22e21cccc7ccc7c7ccccccccccccccccccccccccccccccccccccccccc7ccc00000000000000000000000000000000000000000000000000000000
00000000122ee221ccc717ccccc7cccccc7cccc7ccccccccccccccccccccccccccccc7cc00000000000000000000000000000000000000000000000000000000
000000001e2ee2e1ccc717cccc717cccc717cccc77cccc7ccccccccccccc7cccccc777cc00000000000000000000000000000000000000000000000000000000
00000000f1e22e1fcc7cc17cc7cc17cc7cc17cccc17cccc777ccc7cc77c7177c777c117c00000000000000000000000000000000000000000000000000000000
00000000ff1221ff77cccc177cccc177cccc1777cc17777cc17cccc7cc7cc117cccccc1700000000000000000000000000000000000000000000000000000000
00000000f111111fcccccccccccccccccccccccccccccccccc17777cccccccc1cccccccc00000000000000000000000000000000000000000000000000000000
cccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccceccccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cceeeccccccceccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cf7f66cccceeeccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
71fff17ccf7f66cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c11111cc7111117c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7111117cc7c7c7cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c7c7c7cccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2121212121212121212121212121212121210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111112111111111110000003200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111131112111111111111111111121110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111211111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111211111113111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1131111111111111111111111111112111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111121111131112111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2111111111111111111111111121113111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001935019350183501735014350103500d350093500735007350093500b3500f350163501a3501d3501d3501e3501c3501b35018350123500f3500f3501035014350193501f35023350253502735028350
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000031450334503545030450324502f45025450204501b4501845014450114500f4500e4500e4500e4500d4500e4500f45010450124501345016450194501b4501c4501d4502045024450274502845000400
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002000001885000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 02424344
