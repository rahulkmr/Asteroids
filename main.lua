function love.load()
    arenaWidth = love.graphics.getWidth()
    arenaHeight = love.graphics.getHeight()

    asteroidStages = {
        {
            speed = 120,
            radius = 15
        },
        {
            speed = 70,
            radius = 30,
        },
        {
            speed = 50,
            radius = 50,
        },
        {
            speed = 20,
            radius = 80
        }
    }

    shipX = arenaWidth / 2
    shipY = arenaHeight / 2
    shipAngle = 0
    shipSpeedX = 0
    shipSpeedY = 0
    shipRadius = 30

    bullets = {}
    bulletRadius = 5
    bulletTimeLeft = 4
    bulletTimer = 0

    asteroids = {
        {
            x = 100,
            y = 100,
        },
        {
            x = arenaWidth - 100,
            y = 100,
        },
        {
            x = arenaWidth / 2,
            y = arenaHeight - 100,
        },
    }

    for asteroidIndex, asteroid in ipairs(asteroids) do
        asteroid.angle = love.math.random() * (2 * math.pi)
        asteroid.stage = #asteroidStages
    end
end


function love.keypressed(key)
    if key == 'escape' then
        love.event.push('quit')
    end
end


function areCirclesIntersecting(aX, aY, aRadius, bX, bY, bRadius)
    return (aX - bX) ^ 2 + (aY - bY) ^ 2 <= (aRadius + bRadius) ^ 2
end


function love.update(dt)
    if #asteroids == 0 then
        love.load()
    end

    local turnSpeed = 10

    if love.keyboard.isDown('right', 'd') then
        shipAngle = (shipAngle + turnSpeed * dt) % (2 * math.pi)
    elseif love.keyboard.isDown('left', 'a') then
        shipAngle = (shipAngle - turnSpeed * dt) % (2 * math.pi)
    end

    bulletTimer = bulletTimer + dt
    if love.keyboard.isDown('space') then
        if bulletTimer >= 0.5 then
            bulletTimer = 0
            table.insert(bullets, {
                x = shipX + math.cos(shipAngle) * shipRadius,
                y = shipY + math.sin(shipAngle) * shipRadius,
                angle = shipAngle,
                timeLeft = bulletTimeLeft,
            })
        end
    end


    if love.keyboard.isDown('up', 'w') then
        local shipSpeed = 100
        shipSpeedX = shipSpeedX + math.cos(shipAngle) * shipSpeed * dt
        shipSpeedY = shipSpeedY + math.sin(shipAngle) * shipSpeed * dt
    end

    shipX = (shipX + shipSpeedX * dt) % arenaWidth
    shipY = (shipY + shipSpeedY * dt) % arenaHeight

    for bulletIndex = #bullets, 1, -1 do
        local bullet = bullets[bulletIndex]

        bullet.timeLeft = bullet.timeLeft - dt
        if bullet.timeLeft <= 0 then
            table.remove(bullets, bulletIndex)
        else
            local bulletSpeed = 500
            bullet.x = (bullet.x + math.cos(bullet.angle) * bulletSpeed * dt) % arenaWidth
            bullet.y = (bullet.y + math.sin(bullet.angle) * bulletSpeed * dt) % arenaHeight
        end

        for asteroidIndex = #asteroids, 1, -1 do
            local asteroid = asteroids[asteroidIndex]

            if areCirclesIntersecting(bullet.x, bullet.y, bulletRadius,
                asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius) then
                table.remove(bullets, bulletIndex)

                if asteroid.stage > 1 then
                    local angle1 = love.math.random() * (2 * math.pi)
                    local angle2 = (angle1  - math.pi) % (2 * math.pi)

                    table.insert(asteroids, {
                        x = asteroid.x,
                        y = asteroid.y,
                        angle = angle1,
                        stage = asteroid.stage - 1,
                    })
                    table.insert(asteroids, {
                        x = asteroid.x,
                        y = asteroid.y,
                        angle = angle2,
                        stage = asteroid.stage - 1,
                    })
                end

                table.remove(asteroids, asteroidIndex)
                break
            end
        end

    end

    for asteroidIndex, asteroid in ipairs(asteroids) do
        asteroid.x = (asteroid.x + math.cos(asteroid.angle) *
            asteroidStages[asteroid.stage].speed * dt) % arenaWidth
        asteroid.y = (asteroid.y + math.sin(asteroid.angle) *
            asteroidStages[asteroid.stage].speed * dt) % arenaHeight

        if areCirclesIntersecting(shipX, shipY, shipRadius,
            asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius) then
            love.load()
            break
        end
    end
end


function love.draw()
    for y = -1, 1 do
        for x = -1, 1 do

            love.graphics.origin()
            love.graphics.translate(x * arenaWidth, y * arenaHeight)

            love.graphics.setColor(0, 0, 1)
            love.graphics.circle('fill', shipX, shipY, shipRadius)

            love.graphics.setColor(0, 1, 1)
            local shipCircleDistance = 20
            love.graphics.circle(
                'fill',
                shipX + math.cos(shipAngle) * shipCircleDistance,
                shipY + math.sin(shipAngle) * shipCircleDistance,
                5
            )

            for bulletIndex, bullet in ipairs(bullets) do
                love.graphics.setColor(0, 1, 0)
                love.graphics.circle('fill', bullet.x, bullet.y, bulletRadius)
            end

            for asteroidIndex, asteroid in ipairs(asteroids) do
                love.graphics.setColor(1, 1, 0)
                love.graphics.circle('fill', asteroid.x,
                    asteroid.y, asteroidStages[asteroid.stage].radius)
            end
        end
    end

    love.graphics.origin()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(table.concat({
        'shipAngle: ' .. shipAngle,
        'shipX: ' ..shipX,
        'shipY: ' ..shipY,
        'shipSpeedX: ' .. shipSpeedX,
        'shipSpeedY: ' ..shipSpeedY,
    }, '\n'))
end