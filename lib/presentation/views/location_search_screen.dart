import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/main.dart';
import 'package:flutter_map_toy/models/location_search_state.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';
import 'package:flutter_map_toy/presentation/views/location_search/searchbar.dart';

// ignore: depend_on_referenced_packages
import 'package:google_maps_webservice/places.dart';

class LocationSearchScreen extends StatelessWidget {

  static const String id = 'location_search';

  const LocationSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final cubit = BlocProvider.of<LocationSearchCubit>(context);
    cubit.initialization(context);
    cubit.startLocationSubscription(context);

    return WillPopScope(
      onWillPop: () async {
        cubit.cleanResults();
        cubit.stopLocationSubscription();
        return true;
      },
      child: Scaffold(

        appBar: AppBar(
          title: const Text('Search location'),
        ),

        body: BlocConsumer<LocationSearchCubit, LocationSearchState>(
          listener: (ctx, state) => state.initializing ? Spinner.show(context) : Spinner.pop(context),
          builder: (ctx, state) {


            return ListView.separated(
              itemCount: state.places.length + 1,
              itemBuilder: (ctx, index) {
                if (index == 0) {
                  return Searchbar(cubit, state);
                } else {
                  if (state.places.length > 1) {
                    final PlacesSearchResult place = state.places[index-1];
                    return ListTile(
                      title: Text(place.name),
                      subtitle: place.formattedAddress is String ? Text(place.formattedAddress!) : null,
                    );
                  }

                  return const SizedBox.shrink();
                }
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
    );
  }

  Widget? getPlaceTypes(PlacesSearchResult place) {
    if (place.types.isEmpty) {
      return null;
    }
    return Column(children: place.types.map((type) => Text(type)).toList());
  }
}
