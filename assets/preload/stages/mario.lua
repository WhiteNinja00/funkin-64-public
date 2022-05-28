function onCreate()
	makeLuaSprite('bg', 'mario bg', 0, -2000);
	setScrollFactor('bg', 1, 1);
	scaleObject('bg', 2.75, 2.75)
	addLuaSprite('bg', false);
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end