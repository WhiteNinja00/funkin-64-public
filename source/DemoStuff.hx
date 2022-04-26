package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class DemoStuff extends MusicBeatSubstate
{
	var warnText:FlxText;

    var aretheydead = false;

    public function new(isdead:Bool)
    {
        super();
        this.aretheydead = isdead;
    }

	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(960, 720, FlxColor.BLACK);
		add(bg);

        if(aretheydead)
        {
            warnText = new FlxText(0, 0, 960 * 2,
                "lmao did you just die\n
                press enter to restart\n
                press esc to go the credits",
                32);
        }
        else
        {
            warnText = new FlxText(0, 0, 960 * 2,
                "hey\n
                thanks for playing this mod and im\n
                here to tell you that there is more\n
                on the way\n
                \n
                to check credits press esc\n
                to restart press enter",
                32);
        }
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT) {
            MusicBeatState.resetState();
		}
        else if(controls.BACK) {
            MusicBeatState.switchState(new CreditsState());
        }
		super.update(elapsed);
	}
}
