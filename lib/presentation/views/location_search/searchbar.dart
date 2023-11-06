import 'package:flutter/material.dart';
import 'package:flutter_map_toy/models/location_search_state.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';

class Searchbar extends StatelessWidget {

  final LocationSearchCubit cubit;
  final LocationSearchState state;

  const Searchbar(this.cubit, this.state,
      {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyle.defaultPaddingVal),
      child: TextField(
          focusNode: state.focusNode,
          onChanged: cubit.write,
          onEditingComplete: () => cubit.search(byButton: true),
          autofocus: true,
          // autofocus: state.state != BlocState.initializing,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search...'
          ),
      ),
    );
  }
}
