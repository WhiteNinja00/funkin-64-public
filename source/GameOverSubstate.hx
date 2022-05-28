package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{

	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var stageSuffix:String = "";
	
	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	override function create() {
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float) {
		super();

		PlayState.instance.setOnLuas('inGameOver', true);
		Conductor.songPosition = 0;

		if(!CoolUtil.demo) {
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				switch(PlayState.SONG.song) {
					case 'mario-64':
						playvideo('mariodead');
				}
			});
		}

		CoolUtil.senddiscordmessage('someone has died in ' + PlayState.SONG.song);
		Conductor.changeBPM(100);
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		var exclude:Array<Int> = [];
		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	var isFollowingAlready:Bool = false;

	override function update(elapsed:Float) {
		super.update(elapsed);
		PlayState.instance.callOnLuas('onUpdate', [elapsed]);

		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT) endBullshit();

		if (controls.BACK) {
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.coincounter = 0;
			PlayState.seenCutscene = false;
			MusicBeatState.switchState(new MainMenuState());
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}

		if (FlxG.sound.music.playing) Conductor.songPosition = FlxG.sound.music.time;

		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit() {
		super.beatHit();
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void {
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void {
		if (!isEnding) {
			isEnding = true;
			FlxG.sound.music.stop();
			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}

	function playvideo(name:String) {
		var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		bg.scrollFactor.set();
		add(bg);
		if(ClientPrefs.flashing) {
			(new FlxVideo('assets/videos/' + name + 'noflash.mp4', -160)).finishCallback = function() {
				remove(bg);
			}
		} else {
			(new FlxVideo('assets/videos/' + name + '.mp4', -160)).finishCallback = function() {
				remove(bg);
			}
		}
	}
}
