import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:week1/constants/my_colors.dart';

import '../../business_logic/cubit/characters_cubit.dart';
import '../../data/models/characters.dart';
import '../widgets/character_item.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {

  late List<Character> allCharacters;
  late List<Character> searchedForCharacters;
  bool _isSearching = false;
  final _searchTextController = TextEditingController();


  Widget _buildSearchField(){
    return TextField(
      controller: _searchTextController,
      cursorColor: MyColors.myGrey,
      decoration: const InputDecoration(
        hintText: "Find a character",
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: MyColors.myGrey,
          fontSize: 18,
        ),
      ),
      style: const TextStyle(
        color: MyColors.myGrey,
        fontSize: 18,
      ),
      onChanged: (searchedCharacter){
        addSearchedForItemsToSearchedForList(searchedCharacter);
      },
    );
  }

 void addSearchedForItemsToSearchedForList(String searchedCharacter){
    searchedForCharacters = allCharacters.where((character)=>
        character.fullName!.toLowerCase().startsWith(searchedCharacter))
        .toList();
    setState(() {

    });
 }

 List<Widget> _buildAppBarActions (){
    if(_isSearching){
      return [
        IconButton(
            onPressed: (){
              _searchTextController.text.isEmpty ?
              Navigator.pop(context):
              _clearSearch();
            },
            icon: const Icon(Icons.clear,
              color: MyColors.myGrey,)
        ),
      ];
    }else{
      return [
        IconButton(
            onPressed: _startSearch,
            icon: const Icon(
              Icons.search,
              color: MyColors.myGrey,
            ))
      ];
    }
 }

 void _startSearch(){
    ModalRoute.of(context)!
        .addLocalHistoryEntry(
        LocalHistoryEntry(onRemove: _stopSearching)
    );
    setState(() {
      _isSearching = true;
    });
 }
 void _stopSearching(){
    _clearSearch();
    setState(() {
      _isSearching = false;
    });
 }

 void _clearSearch(){
    setState(() {
      _searchTextController.clear();
    });
 }


  @override
  void initState() {
    super.initState();
    BlocProvider.of<CharactersCubit>(context).getAllCharacters();
  }

  Widget buildBlocWidget(){
    return BlocBuilder<CharactersCubit,CharactersState>
      (builder: (context,state){
        if(state is CharactersLoaded){
          allCharacters = (state).characters;
          return buildLoadedListWidgets();
        } else {
          return showLoadingIndicator();
          }
        },
    );
  }
  Widget showLoadingIndicator(){
    return const Center(child: CircularProgressIndicator(
      color: MyColors.myYellow,
    ),);
  }
  Widget buildLoadedListWidgets(){
    return SingleChildScrollView(
      child: Container(
        color: MyColors.myGrey,
        child: Column(
          children: [
            buildCharactersList()
          ],
        ),
      ),
    );
  }
  Widget buildCharactersList(){
    return GridView.builder(
        gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount
          (
          crossAxisCount: 2,
          childAspectRatio: 2/3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        shrinkWrap: true,
        physics:  const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: _searchTextController.text.isEmpty
            ? allCharacters.length : searchedForCharacters.length,
        itemBuilder: (context,index){
          return  CharacterItem(character:
          _searchTextController.text.isEmpty ?
          allCharacters[index] : searchedForCharacters[index]);
        }
    );
  }

  Widget _buildAppBarTitle(){
    return const Text("Characters",
      style: TextStyle(color: MyColors.myGrey),
    );
  }

  Widget buildNoInternetWidget(){
    return Center(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20,),
            const Text(
              "Can't Connect .. Check Your Internet",
              style: TextStyle(fontSize: 22,
                  color: MyColors.myGrey),
            ),
            Image.asset("assets/images/not_connected.png")
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.myYellow,
        leading: _isSearching ? const BackButton(
          color: MyColors.myGrey,)
                              : Container(),
        title: _isSearching ? _buildSearchField() : _buildAppBarTitle(),
        actions: _buildAppBarActions(),
      ),
      body:
      OfflineBuilder(
      connectivityBuilder: (
      BuildContext context,
      List<ConnectivityResult> connectivity,
      Widget child,
    ) {
        final bool connected = !connectivity.contains(ConnectivityResult.none);
        if (connected){
          return buildBlocWidget();
        }else{
          return buildNoInternetWidget();
        }
      },
        child: showLoadingIndicator(),
      )
    );
  }
}
