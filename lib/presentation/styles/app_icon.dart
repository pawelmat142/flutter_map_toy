import 'package:flutter/material.dart';

abstract class AppIcon {

  static const defaultIcon = Icons.question_mark_rounded;
  static const menu = Icons.menu;
  static const confirm = Icons.done_outline_rounded;
  static const cancel = Icons.cancel;
  static const delete = Icons.delete_outline_rounded;
  static const search = Icons.search;
  static const savedMaps = Icons.save_alt_rounded;
  static const nameMarker = Icons.label_important_rounded;

  static const save = Icons.playlist_add_check;
  static const remove = Icons.playlist_remove_rounded;
  static const edit = Icons.edit_note;
  static const add = Icons.playlist_add;

  static const marker = Icons.location_on_rounded;
  static const addPoint = Icons.add_location_alt_rounded;
  static const editPoint = Icons.edit_location_alt_rounded;
  static const cleanPoint = Icons.wrong_location_rounded;
  static const targetPoint = Icons.location_searching_rounded;

  static const drawLine = Icons.drive_file_rename_outline_sharp;
  static const editLine = Icons.drive_file_rename_outline;
  static const drawColor = Icons.color_lens;
  static const drawWidth = Icons.open_in_full_rounded;
  static const drawWidth1 = Icons.expand_rounded;
  static const drawWidth2 = Icons.design_services_rounded;

  static const mapTypeNormal = Icons.map_sharp;
  static const mapTypeTerrain = Icons.terrain_rounded;
  static const mapTypeSatellite = Icons.satellite_alt_rounded;


  static List<IconData> mapFlutterIcons = [
    Icons.cottage_rounded,
    Icons.festival_rounded,
    Icons.directions_car_rounded,
    Icons.account_balance_rounded,
    Icons.forest_rounded,
    Icons.landscape_rounded,
    Icons.water_rounded,
    Icons.grade_rounded,
    Icons.flag_rounded,
    Icons.water_drop_rounded,
    Icons.fastfood_rounded,
    Icons.restaurant_rounded,
    Icons.speaker_group_sharp,
    Icons.music_note_rounded,
    Icons.electric_bolt_rounded,
    Icons.info_rounded,
    Icons.not_interested_rounded,
    Icons.front_hand_rounded,
  ];
}