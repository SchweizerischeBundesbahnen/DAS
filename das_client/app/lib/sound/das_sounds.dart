import 'package:app/sound/advised_speed_end_sound.dart';
import 'package:app/sound/advised_speed_start_sound.dart';
import 'package:app/sound/break_slip_updated_sound.dart';
import 'package:app/sound/koa_sound.dart';
import 'package:app/sound/sound.dart';
import 'package:app/sound/warn_app_sound.dart';

class DASSounds {
  const DASSounds();

  Sound get advisedSpeedEnd => AdvisedSpeedEndSound();

  Sound get advisedSpeedStart => AdvisedSpeedStartSound();

  Sound get koa => KoaSound();

  Sound get warnApp => WarnAppSound();

  Sound get breakSlipUpdated => BreakSlipUpdatedSound();
}
