function onCreate()
	-- background shit
	num = 2.75;
	makeLuaSprite('bg', 'mario bg', 0, -2000);
	setScrollFactor('bg', 1, 1);
	scaleObject('bg', num, num)
	addLuaSprite('bg', false);
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end