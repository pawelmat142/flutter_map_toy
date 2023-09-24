import 'package:flutter/material.dart';

abstract class AppIcon {

  static const menu = Icons.menu;

  static const save = Icons.playlist_add_check;
  static const remove = Icons.playlist_remove_outlined;
  static const edit = Icons.edit_note;
  static const add = Icons.playlist_add;

  static const addPoint = Icons.add_location_alt_outlined;
  static const editPoint = Icons.edit_location_alt_outlined;
  static const cleanPoint = Icons.wrong_location_outlined;
  static const targetPoint = Icons.location_searching_outlined;


  static List<IconData> mapFlutterIcons = [
    Icons.cottage_outlined,
    Icons.festival_outlined,
    Icons.directions_car_outlined,
    Icons.account_balance_outlined,
    Icons.forest_outlined,
    Icons.landscape_outlined,
    Icons.water_outlined,
    Icons.grade_outlined,
    Icons.outlined_flag_rounded,
    Icons.water_drop_outlined,
    Icons.fastfood_outlined,
    Icons.restaurant_outlined,
    Icons.speaker_group_sharp,
    Icons.music_video_outlined,
    Icons.electric_bolt_outlined,
    Icons.info_outline,
    Icons.not_interested_outlined,
    Icons.front_hand_outlined,
  ];
}