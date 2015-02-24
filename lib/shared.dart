library shared;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';

part 'src/shared/components.dart';

//part 'src/shared/systems/name.dart';
part 'src/shared/systems/logic.dart';

const int PIXEL_PER_METER = 64;

const String playerTag = 'player';
const String futureTag = 'future';

GameState gameState = new GameState();

class GameState {
  double realityDistortion = 0.0;
}