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

  Game() : super('minild57', 'canvas', 800, 600, webgl: true, bodyDefsName: null);

  void createEntities() {
    TagManager tm = world.getManager(TagManager);
    var player = addEntity([new Controller(), new Position(19000.0, 0.0), new Acceleration(), new Velocity(), new Renderable('player')]);
    tm.register(player, playerTag);
    addEntity([new Equipment(), new Renderable('sword')]);

    addEntity([new Position(-1000.0, 0.0), new Acceleration(), new Velocity(), new Renderable('monster_0', 4), new Ai(-1500.0, 500.0, 10.0 * PIXEL_PER_METER)]);
    for (int i = 0; i < 20000; i += 64) {
      addEntity([new Position(i.toDouble(), -64.0), new Renderable('ground', 1, 1.0, random.nextBool())]);
    }
    var future = addEntity([new Position(20000.0, 0.0), new Velocity(-100.0, 0.0)]);
    tm.register(future, futureTag);
  }

  List<EntitySystem> getSystems() {
    return [
            new TweeningSystem(),
            new SoundSystem(helper.audioHelper),

            new InputHandlingSystem(),
            new DustSpawningSystem(),
            new AiSystem(),
            new DirectionSystem(),
            new AnimationSystem(),

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

            new LifetimeSystem(),
            new DelayedJumpSystem(),
            new RealityDistortionSystem(),

            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'minild57')
    ];
  }

  onInit() {
    world.addManager(new TagManager());
    return helper.audioHelper.loadAudioClips(['jump', 'jump_landing']);
  }
}

