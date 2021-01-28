import 'package:flutter/material.dart';

enum LOC_START_TIME_ENUM { TWO_HOURS, SIXTY_HOURS, THIRTY_HOURS }
enum LOC_END_TIME_ENUM { TEN_MIN, AFTER_EVERY_ONE_REACHED, AT_EOD }

TimeOfDay startTimeEnumToTimeOfDay(
    LOC_START_TIME_ENUM startTimeEnum, TimeOfDay startTime) {
  switch (startTimeEnum) {
    case LOC_START_TIME_ENUM.TWO_HOURS:
      break;

    case LOC_START_TIME_ENUM.SIXTY_HOURS:
      break;

    case LOC_START_TIME_ENUM.THIRTY_HOURS:
      break;
  }
}
