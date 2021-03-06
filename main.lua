debug = false  --set false for release
--audio
--music = love.audio.newSource('/assets/tamayama.wav')
--music:play()
bulletSound = love.audio.newSource('/assets/audio/bullet.ogg', 'static')
crash = love.audio.newSource('assets/audio/crash.ogg', 'static')
crash:setVolume(0.4)
--player
player = { x = 200, y = 610, speed = 150, img = nil }
isAlive = true
score = 0
-- bullets start
-- Timers for bullets; declared here to avoid editing in multiple places
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

-- Image Storage for bullets
bulletImg = nil

-- Entity Storage
bullets = {} --arry of current bullets being drawn and updated
-- bullets end

-- enemies start
-- Timers
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax

-- images
enemyImg = nil --pull tihs in during love.load function

-- enemy tables
enemies = {} -- array of enemies on screen

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1, y1 are the left-top coordinates of the first box, while w1, h1 are its width and height
-- x2, y2, w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

function love.load(arg)
	player.img = love.graphics.newImage('assets/plane.png')
	bulletImg = love.graphics.newImage('assets/bullet.png')
	enemyImg  = love.graphics.newImage('assets/enemy.png')
	--assets are ready to be used inside love
end

function love.update(dt) --dt is deltaTime

	--press escape key to exit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

-- player horizontal movement
	if love.keyboard.isDown('left', 'a') then
		if player.x > 0 then -- binds us to the map
			player.x = player.x - (player.speed*dt)
		end
	elseif love.keyboard.isDown('right', 'd') then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed*dt)
		end
	end

	--player vertical movement
	if love.keyboard.isDown('up', 'w') then
		if player.y > 0 then -- binds us to the map
			player.y = player.y - (player.speed*dt)
		end
	elseif love.keyboard.isDown('down', 's') then
		if player.y < (love.graphics.getHeight() - player.img:getHeight()) then
			player.y = player.y + (player.speed*dt)
		end
	end

	-- Time out how far apart our shots can be

	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer <0 then
		canShoot = true
	end

	if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
		-- Create some bullets
		newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg }
		table.insert(bullets, newBullet)
		canShoot =false
		canShootTimer = canShootTimerMax
		bulletSound:play()
	end

	-- update the positions of bullets

	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (250 * dt)

		if bullet.y < 0 then --remove bullets when they pass off the screen
			table.remove(bullets, i)
		end

	end

	-- time out enemy creation

	createEnemyTimer = createEnemyTimer - (1* dt)
	if createEnemyTimer < 0 then
		createEnemyTimer = createEnemyTimerMax

		-- Create an enemy
		randomNumber = math.random(10, love.graphics.getWidth() - 10)
		newEnemy = { x = randomNumber, y = -10, img = enemyImg }
		table.insert(enemies, newEnemy)
	end

	-- update the positions of enemies

	for i, enemy in ipairs(enemies) do
		enemy.y = enemy.y + (200 * dt)

		if enemy.y > 700 then -- remove enemies when off screen
			table.remove(enemies, i)

		end

	end

	-- run collision detection
	-- loop enemies first because there are less
	-- see if enemies hit the player
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				score = score + 1
			end

		end

		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
		and isAlive then
			table.remove(enemies, i)
			crash:play()
			isAlive = false
		end

	end

	if not isAlive and love.keyboard.isDown('r') then
		-- remove all our bullets and enemies from screen
		bullets = {}
		enemies = {}

		-- reset timers
		canShoottimer = canShootTimerMax
		createEnemyTimer = createEnemyTimerMax

		-- move player back to default position
		player.x = 50
		player.y = 610

		-- reset game state
		score = 0
		isAlive = true
	end

end

function love.draw(dt)
	--show score
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Score: " .. tostring(score), 400, 10)

	if isAlive then
		love.graphics.draw(player.img, player.x, player.y)
	else
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics.getHeight()/2-10)
	end

	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.img, bullet.x, bullet.y)
	end

	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
	end

end
