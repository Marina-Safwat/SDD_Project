# Smart Music Player(SMP) - Team Group 5

## Team Members

Rachana Gaire
Isaac Hollis
Marina Safwat

## Features

### Mood-Based Music

Fetch playlists based on 10 different moods
Update and track user mood preferences

### Song Management

Search songs by query and mood
Fetch the next song based on user's history
View user listening history
Access liked songs collection

### Available Moods

happy - Upbeat, joyful music
sad - Melancholic, emotional songs
chill - Relaxed, laid-back vibes
energetic - High-energy, pumped-up tracks
romantic - Love songs and ballads
angry - Intense, aggressive music
peaceful - Calm, serene sounds
party - Dance and party music
motivational - Inspiring, uplifting tracks
text - Custom mood category

### **Repository Setup**

1. Ensure Git is installed by running `git --version`. Git can be found here if not already installed: https://git-scm.com/
2. Clone the repository by running the following:
   `git@github.com:Marina-Safwat/SDD_Project.git`
3. Navigate to file pubspec.yaml and add the required dependencies
   Run: flutter pub get ( for installing dependencies)
   flutter run (to run on emulator or browser)

---

### **Components**

- **Login:** A login page where user can enter their credentials to enter our platform
- **Signup:** Page where the user can register themself in our application
- **Mood Screen:** Screen where the user can simply touch to select the mood
- **Home Page:** A welcoming page for users can see the list of songs as per the mood they picked.
- **Search page:**Search songs and list according to the query
- **Profile:** User profile contains their basic information and their mood they are in.
- **Mini Player:** Small component which pops up when the song is playing but the user is in page other than that playscreen
- **Player screen:** Screen that shows the information of the song that is playing. Also user can interact with the song and perform actions such as like/unlike, dislike/undislike, favorite/unfavorite, play/pause, skip, next, previous
- **LoadingSpinner:** Simple animation to be called while server processes request.

---

### **Beginner Terminology**

- **Flutter:** Flutter is an open source framework for building beautiful, natively compiled, multi-platform applications from a single codebase.

## Folder Structure

├──data/ # static sample data, global collections for testing
├── logic/ #authentication state, login flow
├── models/ # data models used across the application
├──screens/ # Contains all UI pages/screen
├──services/ # external service handlers APIs from SMP server(digital ocean)
└──widgets/ # UI components shared across multiple screens

```


## Key Directories
 ### data/
This folder contains static sample data, global collections, or sample JSON assets used for testing the app's features.
File: data.dart : Hardcoded lists of categories, moods, or songs.



### logic/
Stores the application's logic and controller files.
logic/login/
Handles authentication state, login flow, and API calls related to user login.
auth_service.dart: Handles authentication logic, sign-in/sign-out methods.


pick_screen.dart: Handles initial selection logic (e.g., choosing mood or category).



### models/
This folder contains all data models used across the application. Each model represents a real-world entity and includes serialization/deserialization logic if required.
Files:
category.dart: Represents a music or mood category.


mood.dart: Defines different moods that the user can select.


Music.dart: A general music object containing metadata.


song.dart: Represents a single track, including id, name, artist,imageURL, AudioURL.


user_profile.dart:  Stores user-related information such as name, email, avatar, and mood.



### screens/
This folder contains all UI pages (Flutter widgets) that make up the app’s navigation structure.
Files:
home_screen/ : Main dashboard of the app.


login/ : Login and signup screens.


mood_screen/: Allows selecting moods like happy, sad, romantic.


player_screen/: Music player UI showing album art, preview playback, with button for like, dislike, favorite, etc.


profile_screen/: User profile screen.


search_screen/: Search functionality for songs.


tabs_screen.dart: Entry point with bottom navigation tabs.


Test_spotify.dart: Used for testing Spotify API integration.


Each screen contains UI code and smaller widget components necessary for rendering that page.

### services/
This folder contains all external service handlers — APIs, network requests, and integration logic.
File:
 apiService.dart – Responsible for calling backend services (e.g., Spotify API, your custom server).



### widgets/
This folder contains reusable UI components that are shared across multiple screens.


#### Folder widgets/home_screen/
These widgets are reused inside the home screen UI.
category_title.dart : Displays section titles (e.g., "Recommended for You")


grid.dart : Grid layout of items


song_card.dart : Beautiful card widget showing song info, image, and album name



#### widgets/login/
These widgets are reusable login-related UI components. These components keep the login UI clean and reusable across different auth flows.
button.dart : Reusable large login/register button


forget_password.dart : Link or UI for user password reset


logo_widget.dart : App logo for login screens


signup_google.dart : Google login button


signup_option.dart : Selection component (Sign In, Sign Up)


text_field.dart : Custom text input fields with icons & validation



widgets/profile_screen/
Everything needed for profile-related UI:
change_password.dart : Password update UI


songs_list.dart : Songs list component


firebase_options.dart : Auto-generated Firebase config file
# User Flow
## 1. App Start & Auth Flow

Entry point:
main.dart → PickScreen

### A. When app opens (PickScreen)

PickScreen listens to authService.authStateChanges:

ConnectionState.waiting
→ Show LoadingScreen

If snapshot.hasData == true (user already logged in)
→ Show MoodScreen (user must pick mood first)

If snapshot.hasData == false (no user logged in)
→ Show LoginScreen

## 2. Login / Signup Flow
### A. LoginScreen

From here user can:

Log in with email/password

Enter email + password → press LOG IN

authService.signIn(...)

On success:

Create/refresh UserProfile in users[email]

Navigate → PickScreen
→ authStateChanges has user → MoodScreen is shown.

“Forgot Password?”

Tap → navigate to ResetPassword

User enters email → authService.resetPassword(email: ...)

On success, pop back to LoginScreen.

“Sign Up”

Tap → go to SignupScreen

“Login with Gmail”

Tap Google button → authService.signInWithGoogle()

On success → usually:

Go back to PickScreen (through navigation)

Auth state is now logged-in → MoodScreen.

### B. SignupScreen

From here user can:

Enter email + password

Tap SIGN UP:

authService.createAccount(...)

On success:

Store UserProfile in users[email]

Navigate → PickScreen

PickScreen sees logged-in user → shows MoodScreen.

(Optional) Google signup button can follow similar flow using signInWithGoogle.

### C. ResetPassword (auth feature)

Reached from:

Login’s “Forgot Password?”

Profile’s “Change Password” card.

Enter email → tap RESET PASSWORD

Sends Firebase reset email → pops back.

## 3. Mood Selection Flow
MoodScreen (first screen after login)

Purpose: User must choose how they feel now before going into the app proper.

Shows grid of moods (moodss list).

When user taps a mood:

Navigate → TabsScreen(mood: selectedMood)

(Optionally you also call ApiService.updateUserMood(user.uid, mood.name) either here or inside TabsScreen/MoodHomeScreen.)

From now on, the current mood travels via:

TabsScreen.mood

MoodHomeScreen(mood: widget.mood)

And API calls: playlists, recommendations, etc.

## 4. Main App Navigation (Tabs)
### TabsScreen

Tabs:

Home tab → MoodHomeScreen

Search tab → SearchScreen

Mood tab → MoodScreen (to change mood again)

Profile tab → ProfileScreen

Under the bottom navigation:

body: Tabs[currentTabIndex]

miniPlayer(song) is shown above the bottom bar when a song is active.

## 5. Music Browsing & Playback Flow
### A. MoodHomeScreen

This is the “Home” tab for the current mood.

From here the user can:

See a “Recommended for you” song

Data from: ApiService.nextSong(user.uid, mood)

Tap card → onSongSelected(song) → handled in TabsScreen:

Set song in state

Start playback via AudioPlayer

Show mini-player

Open PlayerScreen

See “Songs for your mood: X”

Horizontal list of SongCards from ApiService.fetchPlaylist

Tap a card → again onSongSelected(song).

Change mood inline

Horizontal ChoiceChip bar for moodss.

Selecting a mood:

Updates _currentMoodName

Calls ApiService.updateUserMood(user.uid, mood.name)

Reloads playlist, recommendations, liked, history.

“Your liked songs” section

Uses ApiService.fetchLikedSongs(userId: uid)

Horizontal scroll of liked songs.

Tap → onSongSelected(song) (opens player & updates mini-player).

“Your listening history” section

Uses ApiService.fetchHistory(userId: uid)

Horizontal list of recently played songs.

Tap → onSongSelected(song).

### B. SearchScreen

User can:

Type text → ApiService.searchSongs(query, mood, limit)

See list of Songs with images, title, artists

Tap on a song:

Calls widget.onTap(song) from TabsScreen.

Same flow: set as current song → play → mini-player → optional PlayerScreen.

### C. Mini-Player & Full Player
Mini-player (in TabsScreen)

Shows current song image, name, play/pause button.

Tap mini-player → opens PlayerScreen for full controls.

PlayerScreen

Shows:

Big album art

Song title + artist

Progress bar (using AudioPlayer listeners)

Controls:

Play/Pause (calls onPlayPause from TabsScreen)

Next / Previous:

Navigator.pop(context, 'next') or 'previous' → tabs can implement queue later.

Shuffle / Repeat toggles (local UI state for now)

Reactions:

Like / dislike / favorite / thumbs up

Currently saved using SharedPreferences for:

liked_songs

favorite_songs

disliked_songs

Soon: we’ll also call backend actions:

ApiService.likeSong

ApiService.dislikeSong

ApiService.favoriteSong

When user dislikes a song:

It also:

Unlikes it if already liked

Auto-skips with Navigator.pop(context, 'next')

### 6. Profile & Settings Flow
ProfileScreen

From bottom tab “Profile”:

Shows:

User header

Avatar

Name (editable via _editName() → updates Firebase updateDisplayName)

Email

Bio

Card → tap to edit short text.

Your mood

Card with current favorite mood.

Tap → bottom sheet with mood list → choose one.

Calls _pickFavoriteMood() + _onMoodSelected (and API update).

(This is more like “profile mood”; runtime mood still from MoodScreen / chips.)

Change Password

ChangePassword card → opens ResetPassword screen.

Playlists

“Liked songs” card → LikedSongsScreen

“Listening history” card → HistorySongsScreen

Logout

Calls authService.googleSignOut() or authService.signOut() (you may combine).

Navigate back to LoginScreen.

On next app rebuild PickScreen shows LoginScreen due to authStateChanges.

LikedSongsScreen

Fetches ApiService.fetchLikedSongs(userId: uid).

Shows full vertical list of liked songs.

On tap → currently Snackbar, later can also:

Call onSongSelected(song)-style flow and open PlayerScreen via navigation from here (like TabsScreen does).

HistorySongsScreen

Fetches ApiService.fetchHistory(userId: uid) and reverses the list so recent first.

Shows vertical list of played songs.

On tap → same story: currently Snackbar, can be wired to player if you want.

## 7. Where backend actions will plug in (next step)

When we integrate reactions with the backend:

In PlayerScreen:

_toggleLike() → call ApiService.likeSong(user.uid, song.id, song.mood, isLiked)

_toggleDislike() → call ApiService.dislikeSong(...)

_toggleFavorite() → call ApiService.favoriteSong(...)

The liked & history sections then automatically match the server via fetchLikedSongs and fetchHistory.








```
