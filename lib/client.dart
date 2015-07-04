library client;

import 'dart:html' hide Player, Timeline;
export 'dart:html' hide Player, Timeline;
import 'dart:web_gl';
import 'dart:typed_data';

import 'package:minild57/shared.dart';

import 'package:gamedev_helpers/gamedev_helpers.dart';
export 'package:gamedev_helpers/gamedev_helpers.dart';

//part 'src/client/systems/name.dart';
part 'src/client/systems/events.dart';
part 'src/client/systems/rendering.dart';

class Game extends GameBase {
  CanvasElement hudCanvas;
  CanvasRenderingContext2D hudCtx;

  Game()
      : super('minild57', '#webgl', 800, 600, webgl: true, bodyDefsName: null) {
    hudCanvas = querySelector('#context2d');
    hudCtx = hudCanvas.context2D;
    hudCtx
      ..textBaseline = 'top'
      ..font = '12px Verdana';
  }

  void createEntities() {
    TagManager tm = world.getManager(TagManager);
    var player = addEntity([
      new Controller(),
      new Position(19000.0, 0.0),
      new Acceleration(),
      new Velocity(),
      new Renderable('player')
    ]);
    tm.register(player, playerTag);
    addEntity([new Equipment(), new Renderable('sword')]);

    for (int i = -1024; i < 20000; i += 64) {
      addEntity([
        new Position(i.toDouble(), -64.0),
        new Renderable('ground', 1, 1.0, random.nextBool())
      ]);
    }
    for (int x = -1024; x < -100; x += 64) {
      for (int y = 0; y < 300; y += 60) {
        addEntity([
          new Position(x.toDouble(), y.toDouble()),
          new Renderable('ground', 1, 1.0, random.nextBool())
        ]);
      }
    }
    addEntity([
      new DeadMonster(3, 0.0),
      new Position(0.0, 0.0),
      new Renderable('corpse')
    ]);
    for (int i = 500; i < 19000; i += 100 + random.nextInt(400)) {
      addEntity([
        new DeadMonster(random.nextInt(3)),
        new Position(i.toDouble(), 0.0),
        new Renderable('corpse')
      ]);
    }
    var future =
        addEntity([new Position(22500.0, 0.0), new Velocity(-100.0, 0.0)]);
    tm.register(future, futureTag);
  }

  Map<int, EntitySystem> getSystems() {
    return {
      GameBase.rendering: [
        new SoundSystem(helper.audioHelper),
        new GravitySystem(),
        new AccelerationSystem(),
        new MovementSystem(),
        new WebGlCanvasCleaningSystem(ctx),
        new BackgroundRenderingSystem(ctx),
        new BackgroundLayer0RenderingSystem(ctx),
        new SpriteRenderingSystem(ctx, spriteSheet),
        new FutureRenderingSystem(ctx),
        new PlayerRenderingSystem(ctx, spriteSheet),
        new EquipmentRenderingSystem(ctx, spriteSheet),
        new HudRenderingSystem(hudCtx),
        new EndingScreenRenderingSystem(hudCtx),
        new BeginningScreenRenderingSystem(hudCtx),
      ],
    GameBase.physics: [
      new TweeningSystem(),
      new InputHandlingSystem(),
      new DustSpawningSystem(),
      new AiSystem(),
      new DirectionSystem(),
      new AttackStopSystem(),
      new AnimationSystem(),
      new LifetimeSystem(),
      new DelayedJumpSystem(),
      new RealityDistortionSystem(),
      new DeadMonsterRealityDistortionSystem(),
      new DeadMonsterAttackSystem(),
    ]
    };
  }

  onInit() {
    world.addManager(new TagManager());
    return helper.audioHelper.loadAudioClips(['jump', 'jump_landing']);
  }
}
