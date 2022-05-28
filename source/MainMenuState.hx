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
	public static var psychEngineVersion:String = '0.5.2h';
	public static var curSelected:Int = 0;
	public static var othercurSelected:Int = 0;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var alltext:FlxTypedGroup<FlxText>;
	var songlist:Array<String> = ['mario-64'];
	var menustuff:Array<String> = ['play', 'credits', 'options'];
	var magenta:FlxSprite;
	var debugKeys:Array<FlxKey>;
	var uhhh = 0;
	var camFollow:FlxObject;
	var menu5:FlxSprite = new FlxSprite(276, 387);

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
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

		camFollow = new FlxObject(480, 360, 1, 1);
		add(camFollow);

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

		menu5 = new FlxSprite(276, 387);
		menu5.frames = Paths.getSparrowAtlas('game room');
		menu5.animation.addByPrefix('thing', 'screen stuff', 24, false);
		menu5.animation.play('thing');
		add(menu5);

		//if(CoolUtil.stupidbeta) menustuff.remove('trophies');

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		alltext = new FlxTypedGroup<FlxText>();
		add(alltext);

		for (i in 0...songlist.length) {
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.frames = Paths.getSparrowAtlas('cartrages');
			menuItem.animation.addByPrefix('idle', songlist[i] + " normal", 24);
			menuItem.animation.addByPrefix('selected', songlist[i] + " selected", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
		}

		for (i in 0...menustuff.length) {
			var daText:FlxText = new FlxText(300, 449 + (i * 30), 0, menustuff[i], 26);
			daText.alignment = CENTER;
			daText.color = 0xFF727272;
			daText.ID = i;
			alltext.add(daText);
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		changeItem();
		otherchangeItem();

		#if android
		addVirtualPad(NONE, A_B);
        #end

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8) FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		if(menu5 != null) {
			if(!ClientPrefs.flashing) menu5.animation.play('thing');
		}
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		if(uhhh == 0) {
			if (controls.UI_UP_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				otherchangeItem(-1);
			}
			if (controls.UI_DOWN_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				otherchangeItem(1);
			}
			if (controls.ACCEPT) {
				switch(menustuff[othercurSelected]) {
					case 'play':
						if(songlist.length == 1) {
							selectedSomethin = true;
							FlxG.sound.play(Paths.sound('confirmMenu'));
							PlayState.SONG = Song.loadFromJson(songlist[0], songlist[0]);
							PlayState.isStoryMode = false;
							PlayState.storyDifficulty = 1;
							LoadingState.loadAndSwitchState(new PlayState());
						} else {
							uhhh = 1;
							camFollow.setPosition(1325, 360);
						}
						case 'credits':
							MusicBeatState.switchState(new CreditsState());
						case 'trophies':
							MusicBeatState.switchState(new AchievementsMenuState());
						case 'options':
							MusicBeatState.switchState(new options.OptionsState());
				}
			}
		} else {
			if (controls.UI_LEFT_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}
			if (controls.UI_RIGHT_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}
			if (controls.UI_UP_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-5);
			}
			if (controls.UI_DOWN_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(5);
			}
			if (controls.BACK) {
				uhhh = 0;
				camFollow.setPosition(480, 360);
			}
			if (controls.ACCEPT) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				PlayState.SONG = Song.loadFromJson(songlist[curSelected], songlist[curSelected]);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 1;
				LoadingState.loadAndSwitchState(new PlayState());
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0) {
		curSelected += huh;
		if(curSelected >= songlist.length || curSelected < 0) curSelected -= huh;
		if(curSelected == 5 && huh == 1) curSelected -= huh;
		if(curSelected == 4 && huh == -1) curSelected -= huh;
		menuItems.forEach(function(spr:FlxSprite) {
			spr.animation.play('idle');
			spr.x = 1030 + (spr.ID * 110);
			spr.y = 220 + (spr.ID * 5);
			if(spr.ID > 4) {
				spr.x -= 575;
				spr.y += 283 - (spr.ID * 3);
			}
			if (spr.ID == curSelected) {
				spr.animation.play('selected');
				spr.y += 3;
			}
		});
	}

	function otherchangeItem(huh:Int = 0) {
		othercurSelected += huh;
		if (othercurSelected >= menustuff.length) othercurSelected = 0;
		if (othercurSelected < 0) othercurSelected = menustuff.length - 1;
		alltext.forEach(function(spr:FlxText) {
			spr.color = 0xFF727272;
			if (spr.ID == othercurSelected) {
				spr.color = 0xFFFFFFFF;
			}
		});
	}
}
