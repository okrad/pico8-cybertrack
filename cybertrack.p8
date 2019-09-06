pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

STATE_INTRO = 1
STATE_PLAYER_SELECTION = 2
STATE_LEVEL_START = 3
STATE_RUNNING = 4
STATE_LEVEL_COMPLETE = 5
STATE_GAMEOVER = 6

ORIENTATION_HORIZONTAL = 1
ORIENTATION_VERTICAL = -1

STATUS_ACTIVE = 1
STATUS_COLLECTED = 2

DEBUG = true

function _init()

	players = {}
	gameState = STATE_INTRO
	countdowncycles = 0
	countdown = 0
	level = 0

	world = {
		width = 500,
		height = 500
	}

end

function _update()

	if(gameState == STATE_INTRO) then

		if(btnp(4)) then
			highlightedPlayer = 1
			gameState = STATE_PLAYER_SELECTION
		end

	elseif(gameState == STATE_PLAYER_SELECTION) then

		if(btnp(2) and highlightedPlayer == 2) highlightedPlayer = 1
		if(btnp(3) and highlightedPlayer == 1) highlightedPlayer = 2
		if(btnp(4)) then

			create_players()
			next_level()

			gameState = STATE_LEVEL_START
		end

	elseif(gameState == STATE_LEVEL_START) then

		inccountdown()
		if(countdown > 2) gameState = STATE_RUNNING

	elseif(gameState == STATE_LEVEL_COMPLETE) then

		if(countdown > 2) then
			next_level()
			gameState = STATE_LEVEL_START
		else
			inccountdown()
		end

	elseif(gameState == STATE_RUNNING) then

		if(countdown < 4) inccountdown()

		if(trackidx < #track) then
			for i = 1, #players do
				update_player_state(i - 1)
			end
			trackidx += speed
		else
			countdowncycles = 0
			countdown = 0
			gameState = STATE_LEVEL_COMPLETE
		end

	end
end

function next_level()

	level += 1

	countdowncycles = 0
	countdown = 0

	-- tracksegments = 20
	tracksegments = 50
	speed = 2 + flr(level * .2)
	minsegmentlen =  flr(1 + 30  / (level * .2))
	maxsegmentlen =  flr(1 + 50  / (level * .2))
	trackidx = 1

	for p in all(players) do
		p.camera.x = p.camera.orig_x
		p.camera.y = p.camera.orig_y

		p.x = world.width / 2
		p.y = world.height / 2
	end

	generate_track()
end

function update_player_state(pn)

	local p = players[pn + 1]

	if(btn(0, pn)) then --left
		p.speedx = -speed
		p.speedy = 0
		p.flipx = false
		p.sprite = 2

	elseif(btn(1, pn)) then --right
		p.speedx = speed
		p.speedy = 0
		p.sprite = 2
		p.flipx = true

	elseif(btn(2, pn)) then --up
		p.speedy = -speed
		p.speedx = 0
		p.flipy = false
		p.sprite = 1

	elseif(btn(3, pn)) then --down
		p.speedy = speed
		p.speedx = 0
		p.sprite = 1
		p.flipy = true
	end

	p.x += p.speedx
	p.y += p.speedy

	p.camera.x += p.speedx
	p.camera.y += p.speedy

	if(p.speedx < 0) then -- moving left
		if(p.camera.x < 0) then
			p.camera.x = 0
		elseif(p.x > world.width - p.camera.width / 2) then
			p.camera.x -= p.speedx
		end

		if(p.x < 0)	then
			p.x = 0
		end
	elseif(p.speedx > 0) then -- moving right
		if(p.camera.x > world.width - p.camera.width) then
			p.camera.x = world.width - p.camera.width
		elseif(p.camera.x == p.speedx and p.x < p.camera.width / 2) then
			p.camera.x -= p.speedx
		end

		if(p.x > world.width - 8) then
			p.x = world.width - 8
		end
	end

	if(p.speedy < 0) then -- moving left
		if(p.camera.y < 0) then
			p.camera.y = 0
		elseif(p.y > world.height - p.camera.height / 2) then
			p.camera.y -= p.speedy
		end

		if(p.y < 0)	then
			p.y = 0
		end
	elseif(p.speedy > 0) then -- moving right
		if(p.camera.y > world.height - p.camera.height) then
			p.camera.y = world.height - p.camera.height
		elseif(p.camera.y == p.speedy and p.y < p.camera.height / 2) then
			p.camera.y -= p.speedy
		end

		if(p.y > world.height - 8) then
			p.y = world.height - 8
		end
	end

	for i = 1, trackidx do
		if(track[i].status != STATUS_COLLECTED and track[i].x > p.x and track[i].x < p.x + 8 and track[i].y > p.y and track[i].y < p.y + 8) then
			p.score += 1
			track[i].status = STATUS_COLLECTED
		end
	end
end

function create_players()

	players = {
		{
			sprite = 1,
			flipx = false,
			flipy = false,
			speedx = 0,
			speedy = 0,
			fov = 50,
			score = 0,
			x = world.width / 2,
			y = world.height / 2,
			screen = {
				x1 = 0,
				y1 = 7,
				x2 = 127,
				y2 = 127
			},
			camera = {
				x = (world.width - 128) / 2,
				y = (world.height - 128) / 2,
				width = 128,
				height = 120
			},

		}
	}

	if(highlightedPlayer == 2) then
		players[1].screen.x2 = 64
		players[1].camera.x = (world.width - 64) / 2
		players[1].camera.width = 64

		players[2] = {
			sprite = 1,
			flipx = false,
			flipy = false,
			speedx = 0,
			speedy = 0,
			fov = 50,
			score = 0,
			x = world.width / 2,
			y = world.height / 2,
			screen = {
				x1 = 65,
				y1 = 7,
				x2 = 127,
				y2 = 127
			},
			camera = {
				x = (world.width - 64) / 2,
				y = (world.height - 128) / 2,
				width = 64,
				height = 120
			}

		}

	end

	for p in all(players) do
		p.camera.orig_x = p.camera.x
		p.camera.orig_y = p.camera.y
	end

end

function _draw()
	cls()

	if(gameState == STATE_INTRO) then

		draw_intro()

	elseif(gameState == STATE_PLAYER_SELECTION) then

		draw_players_menu()

	elseif(gameState == STATE_LEVEL_START) then

		draw_track()
		draw_border()
		draw_player()
		draw_score()
		draw_countdown()

	elseif(gameState == STATE_RUNNING) then

		if(countdown < 4) draw_countdown()
		draw_track()
		draw_border()
		draw_player()
		draw_score()

	elseif(gameState == STATE_LEVEL_COMPLETE) then

		draw_track()
		draw_border()
		draw_player()
		draw_score()
		draw_level_complete()

	end

	debug()

end

function draw_intro()
	print('--- cybertrack ---', 28, 50, 7)
	print('press z to start', 34, 63, 7)
end

function draw_players_menu()
	if(highlightedPlayer == 1) then
		print('* 1 player', 40, 50, 7)
		print('  2 players', 40, 66, 7)
	else
		print('  1 player', 40, 50, 7)
		print('* 2 players', 40, 66, 7)
	end
end

function draw_countdown()

	print('level ' .. level, 40, 38, 7)

	if(countdown < 3) then
		print('ready in ' .. 3 - countdown .. '...', 40, 50, 7)
	else
		print('go!', 50, 50, 7)
	end
end

function draw_level_complete()
	print('level ' .. level .. ' complete!', 30, 38, 7)
end

function draw_border()

	local x, y, p

	for pn = 1, #players do

		p = players[pn]

		for x = p.screen.x1, p.screen.x2 do
			pset(x, p.screen.y1, 12)
			pset(x, p.screen.y2, 12)
		end
		for y = p.screen.y1, p.screen.y2 do
			pset(p.screen.x1, y, 12)
			pset(p.screen.x2, y, 12)
		end

	end
end

function draw_track()

	local i, color, pos, pn, p

	for pn = 1, #players do

		p = players[pn]

		for i = 1, trackidx + p.fov do
			if(#track > i) then

				if(track[i].x > p.camera.x and track[i].x < p.camera.x + p.camera.width and track[i].y > p.camera.y and track[i].y < p.camera.y + p.camera.height) then

					if(track[i].status == STATUS_COLLECTED) then
						color = 0
					elseif(i < trackidx - 1) then
						color = 3
					else
						color = 11
					end

					pos = world2screen(pn, track[i].x, track[i].y)

					pset(pos.x, pos.y, color)
				end
			end
		end
	end

end

function draw_player()

	local p, pn, pos

	for pn = 1, #players do
		p = players[pn]

		pos = world2screen(pn, p.x, p.y)

		sspr(8 * p.sprite, 0, 8, 8, pos.x, pos.y, 8, 8, p.flipx, p.flipy)
	end
end

function draw_score()

	local pn

	for pn = 1, #players do
		print("p" .. pn .. " score: " .. players[pn].score, (pn - 1) * 80, 0, 7)
	end
end

function debug()
	if(DEBUG) then

		local pn, p

		for pn = 1, #players do

			p = players[pn]

			print('P' .. pn .. ': ' .. p.x .. ', ' .. p.y .. ' - C: ' .. p.camera.x .. ', ' .. p.camera.y, 0, 112 + pn * 4, 7)
		end

		print('STATE: ' .. gameState, 0, 110, 7)
	end
end

function generate_track()

	track = {}

	local x, y = flr(world.width / 2), flr(world.height / 2)
	local orientation = ORIENTATION_VERTICAL
	local dirx, diry = 1, 0
	local i

	for i = 0, tracksegments do

		if(orientation == ORIENTATION_HORIZONTAL) then
			dirx = 0
			if(rnd(100) > 50) then
				diry = 1
			else
				diry = -1
			end
		else
			diry = 0
			if(rnd(100) > 50) then
				dirx = 1
			else
				dirx = -1
			end
		end

		pathinfo = generate_path(x, y, dirx, diry)
		x = pathinfo.endx
		y = pathinfo.endy

		orientation = orientation * -1

	end

end

function generate_path(x, y, dirx, diry)

	local i
	local segmentlen

	segmentlen = minsegmentlen + rnd(maxsegmentlen - minsegmentlen)

	if(dirx == 1) then
		segmentlen = min(world.width - 4 - x, segmentlen)
	elseif(dirx == -1 and x - segmentlen - 4 < 0) then
		segmentlen = x - 4
	end

	if(diry == 1 and y + segmentlen > world.height - 4) then
		segmentlen = min(world.height - 4 - y, segmentlen)
	elseif(diry == -1 and y - segmentlen < 4) then
		segmentlen = y - 4
	end

	for i = 0, segmentlen do
		track[#track + 1] = {
			x = x,
			y = y,
			status = STATUS_ACTIVE
		}
		x += dirx
		y += diry
	end

	return {
		endx = x,
		endy = y
	}

end

function world2screen(pn, wx, wy)

	local p = players[pn]

	return {
		x = p.screen.x1 + wx - p.camera.x,
		y = p.screen.y1 + wy - p.camera.y
	}
end

function inccountdown()
	countdowncycles += 1
	countdown = flr(countdowncycles / 30)
end

__gfx__
00000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000098889000900092000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700008580000888882000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000008580008855822000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000008880000888882000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700098289000900092000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000022222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000060100601006010060100601006010060100601006010060100601006010060100601006010000000000000000000000000000000000000000000000000000000000000000000000000000000000000
