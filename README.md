# ToPlayList-iOS
An iOS app for discovering new games

Browse the newest releases or upcoming lists to discover new games, or search for specific ones.  
Save the games you want to play or have played to your ToPlay list or Played list.  

<p float="left" align="center">
  <img src="/doc/img/lists.png" width="30%"/>
  <img src="/doc/img/panning.png" width="30%"/> 
  <img src="/doc/img/stars.png" width="30%"/>
</p>

## Techie stuff
ToPlayList was my first iOS app ever, I learned basic iOS development, Swift, git etc. with this project.  
I started it while I was studying Computer Science at university in Budapest.  
As you can imagine, the code is far from perfect, please don't judge me. :)  

The game data in the list and detail views are downloaded from the IGDB REST API, and I store the lists and manage authentication with Firebase.  

To run the app, you need to add a Configuration file containing the IGDB API key, and development and production Firebase plists, because they are not tracked by git.

