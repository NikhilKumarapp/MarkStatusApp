
# MarkStatusApp

This project is a location-based attendance system built using Flutter and Google Maps. It allows tracking of live locations, routes traveled, stop times, and distance calculations with database integration for storing user data.


## Features

- Live location tracking using Google Maps.
- Route drawing and markers for start and end points.
- Displaying total distance and travel duration for members.
- SQLite database integration for storing stop times and member information.
- Filtering routes by date, stop time calculations, and viewing individual routes.


## Installation

#### Prerequisites
Before you begin, ensure you have the following installed:

- Flutter SDK: [Install Flutter](https://flutter-ko.dev/get-started/install)
- Google Maps API Key: You will need an API key for Google Maps. Get one from the [Google Cloud Console](https://console.cloud.google.com/).
- SQLite: SQLite is integrated within Flutter, but make sure your project dependencies include the sqflite package for database management.

#### Setup Instructions
***Clone the Repository***

First, clone the project to your local machine using the following command:

```bash
git clone https://github.com/NikhilKumarapp/MarkStatusApp.git
cd MarkStatusApp
```

***Get Dependencies***

Run the following command to install the required dependencies:

```bash
flutter pub get
```
***Configure Google Maps API Key***

Open the android/app/src/main/AndroidManifest.xml file and insert your Google Maps API key in the following section:

```bash
<meta-data
   android:name="com.google.android.geo.API_KEY"
   android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

***Run the Project***

You can now run the project on an emulator or physical device using this command:

```bash
flutter run
```

## Tech Stack

**Framework:** Flutter

**Dependencies:** Cupertino_icons, timeline_tile, google_maps_flutter, location, flutter_polyline_points

**Database:** SQLite

**Languages:** Dart


## Future Enhancements

List potential improvements or new features I plan to add, such as:

- Adding notifications for stop times.
- Enhancing the UI with better route filtering options.
- Exporting route data to a CSV.
## License

[MIT](https://choosealicense.com/licenses/mit/)
