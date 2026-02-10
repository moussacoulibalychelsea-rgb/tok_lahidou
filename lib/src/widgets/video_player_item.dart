// export conditionnel : Web utilise le fichier web, sinon IO/native
export 'video_player_item_web.dart' if (dart.library.io) 'video_player_item_io.dart';
