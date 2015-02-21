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
    var player = addEntity([new Controller(), new Position(400.0, 0.0), new Acceleration(), new Velocity(), new Renderable('player')]);
    tm.register(player, playerTag);

    addEntity([new Position(100.0, 0.0), new Acceleration(), new Velocity(), new Renderable('player', false)]);
    addEntity([new Position(200.0, 0.0), new Acceleration(), new Velocity(), new Renderable('player', false)]);
    addEntity([new Position(500.0, 0.0), new Acceleration(), new Velocity(), new Renderable('player')]);
    addEntity([new Position(600.0, 0.0), new Acceleration(), new Velocity(), new Renderable('player')]);
    for (int i = 0; i < 800; i += 64) {
      addEntity([new Position(i.toDouble(), -64.0), new Renderable('ground_0', random.nextBool())]);
    }
  }

  List<EntitySystem> getSystems() {
    return [
            new TweeningSystem(),

            new InputHandlingSystem(),
            new DirectionSystem(),

            new GravitySystem(),
            new AccelerationSystem(),
            new MovementSystem(),

            new WebGlCanvasCleaningSystem(ctx),
            new SpriteRenderingSystem(ctx, spriteSheet),

//            new FpsRenderingSystem(ctx),
            new AnalyticsSystem(AnalyticsSystem.GITHUB, 'minild57')
    ];
  }

  onInit() {
    world.addManager(new TagManager());
  }
}

