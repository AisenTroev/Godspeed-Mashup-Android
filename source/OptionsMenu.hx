package;

import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("Mod Specific", [
			new OldTimings("Old Hit timings from KE 1.4.2"),
			new ColoredTypes("Change if different Note Types change color based on position."),
			new Popups("Turn on or off Popup Images")


		]),
		new OptionCategory("Gameplay", [
			new DFJKOption(controls),
			new NineKeyOption(controls),
			new DownscrollOption("Change the layout of the strumline."),
			new GhostTapOption("Ghost Tapping is when you tap a direction and it doesn't give you a miss."),
			new Grace("Turn off the Grace timer for the real chad input"),
			#if desktop		
			new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),
			new FPSCapOption("Cap your FPS"),
			new ScrollSpeedOption("Change your scroll speed (1 = Chart dependent)"),
			#end			
			new InstantRespawn("Toggle if you instantly respawn after dying."),
			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
			new ResetButtonOption("Toggle pressing R to gameover."),
			// new OffsetMenu("Get a note offset based off of your inputs!"),
			new CustomizeGameplay("Drag'n'Drop Gameplay Modules around to your preference")
		]),
		new OptionCategory("Appearance", [
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new CamZoomOption("Toggle the camera zoom in-game."),
			new RainbowFPSOption("Make the FPS Counter Rainbow"),
			new AccuracyOption("Display accuracy information."),
			new NPSDisplayOption("Shows your current Notes Per Second."),
			new SongPositionOption("Show the songs current position (as a bar)"),
			new CpuStrums("CPU's strumline lights up when a note hits it.")
		]),
		
		new OptionCategory("Misc", [
			new FPSOption("Toggle the FPS Counter"),
			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new WatermarkOption("Enable and disable all watermarks from the engine."),
			new AntialiasingOption("Toggle antialiasing, improving graphics quality at a slight performance penalty."),
			new ScoreScreen("Show the score screen after the end of a song"),
			new ShowInput("Display every single input in the score screen."),
			new Optimization("No backgrounds, no characters, centered notes, no player 2."),
			new BotPlay("Showcase your charts and mods with autoplay."),
		]),
		new OptionCategory("Saves and Data", [
			new ResetScoreOption("Reset your score on all songs and weeks. This is irreversible!"),
			new ResetSettings("Reset ALL your settings. This is irreversible!")
		])
		
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;
	override function create()
	{
		instance = this;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false, true);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height + 40, 0, "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 900)),Std.int(versionShit.height + 600),FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});
		
		#if mobileC
		addVirtualPad(UP_DOWN, A_B);
		#end		

		super.create();
	}

	var isCat:Bool = false;
	

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (acceptInput)
		{
			if (controls.BACK && !isCat)
				FlxG.switchState(new MainMenuState());
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				for (i in 0...options.length)
				{
					var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
					controlLabel.isMenuItem = true;
					controlLabel.targetY = i;
					grpControls.add(controlLabel);
					// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				}
				
				curSelected = 0;
				
				changeSelection(curSelected);
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(1);
				}
			}
			
			if (controls.UP_P)
				changeSelection(-1);
			if (controls.DOWN_P)
				changeSelection(1);
			
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
						{
							if (FlxG.keys.pressed.RIGHT)
								currentSelectedCat.getOptions()[curSelected].right();
							if (FlxG.keys.pressed.LEFT)
								currentSelectedCat.getOptions()[curSelected].left();
						}
					else
					{
						if (FlxG.keys.justPressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.justPressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				else
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.justPressed.RIGHT)
							FlxG.save.data.offset += 0.1;
						else if (FlxG.keys.justPressed.LEFT)
							FlxG.save.data.offset -= 0.1;
					}
					else if (FlxG.keys.pressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.pressed.LEFT)
						FlxG.save.data.offset -= 0.1;
					
					versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
				}
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
					versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
				else
					versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.justPressed.LEFT)
						FlxG.save.data.offset -= 0.1;
				}
				else if (FlxG.keys.pressed.RIGHT)
					FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT)
					FlxG.save.data.offset -= 0.1;
				
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
			}
		

			if (controls.RESET)
					FlxG.save.data.offset = 0;

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) {
						grpControls.members[curSelected].reType(currentSelectedCat.getOptions()[curSelected].getDisplay());
						trace(currentSelectedCat.getOptions()[curSelected].getDisplay());
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
						{
							var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
							controlLabel.isMenuItem = true;
							controlLabel.targetY = i;
							grpControls.add(controlLabel);
							// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						}
					curSelected = 0;
				}
				
				changeSelection();
			}
		}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end
		
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
			else
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		}
		else
			versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
