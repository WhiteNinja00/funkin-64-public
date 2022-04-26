package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.2h'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var songlist:Array<String> = [
		'mario-64'
	];

	var magenta:FlxSprite;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25, 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		var menu1:FlxSprite = new FlxSprite(-801, -104);
		menu1.frames = Paths.getSparrowAtlas('game room');
		menu1.animation.addByPrefix('thing', 'background', 24, false);
		menu1.animation.play('thing');
		add(menu1);

		var menu2:FlxSprite = new FlxSprite(93, 637);
		menu2.frames = Paths.getSparrowAtlas('game room');
		menu2.animation.addByPrefix('thing', 'table', 24, false);
		menu2.animation.play('thing');
		add(menu2);

		var menu3:FlxSprite = new FlxSprite(960, 76);
		menu3.frames = Paths.getSparrowAtlas('game room');
		menu3.animation.addByPrefix('thing', 'shelf', 24, false);
		menu3.animation.play('thing');
		add(menu3);

		var menu4:FlxSprite = new FlxSprite(228, 367);
		menu4.frames = Paths.getSparrowAtlas('game room');
		menu4.animation.addByPrefix('thing', 'screen uhhh', 24, false);
		menu4.animation.play('thing');
		add(menu4);

		var menu5:FlxSprite = new FlxSprite(276, 387);
		menu5.frames = Paths.getSparrowAtlas('game room');
		menu5.animation.addByPrefix('thing', 'screen stuff', 24, false);
		menu5.animation.play('thing');
		add(menu5);

		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		for (i in 0...songlist.length)
		{
			var offset:Float = 108 - (Math.max(songlist.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(1012 + (i * 110), 220);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('cartrages');
			menuItem.animation.addByPrefix('idle', songlist[i], 24);
			menuItem.animation.addByPrefix('selected', songlist[i] + " selected", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (songlist.length - 4) * 0.135;
			if(songlist.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				PlayState.SONG = Song.loadFromJson(songlist[curSelected], songlist[curSelected]);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 1;
				LoadingState.loadAndSwitchState(new PlayState());
			}
			else if (FlxG.keys.justPressed.ONE && CoolUtil.debugstuff)
			{
				MusicBeatState.switchState(new StoryMenuState());
			}
			else if (FlxG.keys.justPressed.TWO && CoolUtil.debugstuff)
			{
				MusicBeatState.switchState(new FreeplayState());
			}
			else if (FlxG.keys.justPressed.THREE && CoolUtil.debugstuff)
			{
				MusicBeatState.switchState(new CreditsState());
			}
			else if (FlxG.keys.justPressed.FOUR && CoolUtil.debugstuff)
			{
				MusicBeatState.switchState(new options.OptionsState());
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				spr.centerOffsets();
			}
		});
	}
}
