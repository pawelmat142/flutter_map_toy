import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/models/location_search_state.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/presentation/components/no_results.dart';
import 'package:flutter_map_toy/presentation/dialogs/spinner.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';
import 'package:flutter_map_toy/presentation/views/location_search/searchbar.dart';
import 'package:flutter_map_toy/presentation/views/map_screen/map_screen.dart';
import 'package:flutter_map_toy/utils/location_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: depend_on_referenced_packages
import 'package:google_maps_webservice/places.dart';

class LocationSearchScreen extends StatelessWidget {

  static const String id = 'location_search';
  static const double tileIconSize = 40;

  const LocationSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final cubit = BlocProvider.of<LocationSearchCubit>(context);
    final mapCubit = BlocProvider.of<MapCubit>(context);

    cubit.initialization(context).then((_) {
      cubit.cleanResults();
    });
    cubit.startLocationSubscription(context);

    return WillPopScope(
      onWillPop: () async {
        cubit.cleanResults();
        cubit.stopLocationSubscription();
        return true;
      },
      child: GestureDetector(
        onTap: () {
          cubit.state.focusNode.unfocus();
        },
        child: Scaffold(

          appBar: AppBar(title: const Text('Find place')),

          body: BlocBuilder<LocationSearchCubit, LocationSearchState>(
            builder: (ctx, state) {
              if (state.state == BlocState.initializing) {
                return const Spinner();
              }

              return ListView.separated(
                itemCount: state.places.length + 1,
                itemBuilder: (ctx, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        Searchbar(cubit, state),
                        if (state.places.isEmpty) const NoResults(),
                      ],
                    );
                  } else {
                    if (state.places.isNotEmpty) {
                      final PlacesSearchResult place = state.places[index-1];
                      place.icon;
                      return ListTile(
                        title: Text(place.name, style: AppStyle.listTileTitle),
                        subtitle: place.formattedAddress is String ? Text(place.formattedAddress!) : null,
                        isThreeLine: true,
                        trailing: getPlaceIcon(place),
                        onTap: () {
                          if (place.geometry != null) {
                            final point = LocationUtil.pointFromLocation(place.geometry!.location);
                            navigateToMapsScreen(context, mapCubit, point);
                          }
                        },
                      );
                    }
                  }
                  return null;
                },
                separatorBuilder: (ctx, index) {
                  if (index == 0) {
                    return const SizedBox(height: AppStyle.defaultPaddingVal,);
                  } else {
                    return const Divider(height: 1, color: AppColor.primaryDark,);
                  }
                }
              );
            },
          )
        ),
      ),
    );
  }

  navigateToMapsScreen(BuildContext context, MapCubit mapCubit, LatLng point ) {
    if (Navi.inStack(MapScreen.id)) {
      Navi.popUntilNamed(context, MapScreen.id);
      mapCubit.state.mapController?.animateCamera(CameraUpdate.newLatLng(point));
    } else {
      mapCubit.setInitialPosition(point: point).then((_) {
        Navigator.pushNamed(context, MapScreen.id);
      });
    }
  }

  Widget? getPlaceIcon(PlacesSearchResult place) {
    if (place.icon == null) {
      return null;
    }
    return SizedBox(
        width: tileIconSize,
        height: tileIconSize,
        child: Image.network(place.icon!,));
  }

  Widget? getPlaceTypes(PlacesSearchResult place) {
    if (place.types.isEmpty) {
      return null;
    }
    return Column(children: place.types.map((type) => Text(type)).toList());
  }
}
