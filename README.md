# Prague MHD - Timetable Application

Flutter application for viewing Prague public transport timetables using the Golemio API. The app displays stops, departures, and real-time vehicle positions on a map.

## Features

- **Stops List**: Browse all public transport stops with search functionality
- **Departures**: View departure times for selected stops with pull-to-refresh
- **Vehicle Tracking**: Real-time vehicle positions on an interactive map
- **Error Handling**: Comprehensive error states and loading indicators

## Prerequisites

- Flutter SDK (3.29.3 was used during development)
- Android Studio / VS Code with Flutter extensions

## Setup Instructions

### 1. Clone and Install Dependencies

```bash
git clone <repository-url>
cd prague-timetable
flutter pub get
dart run build_runner watch
```

### 2. Configure API Token

1. Get your API token from [Golemio API](https://api.golemio.cz/pid/docs/openapi/index.htm)

2. **Environment file (.env)**

   - Edit `.env.example` file in the project root:

   ```env
   GOLEMIO_API_TOKEN=your_actual_token_here
   ```

### 3. Run the Application in debug mode

```bash
flutter run --debug
```

**Note**: .env setup is for testing purposes! Never use it in actual production release, because .env file is public. Instead store all third party api keys on the backend

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
│   ├── stop.dart            # Stop information
│   ├── departure.dart       # Departure details
│   ├── vehicle_position.dart # Vehicle location data
│   ├── metro_line.dart      # Metro line information
│   ├── transport_type.dart  # Transport type definitions
│   └── api_result.dart      # API response wrapper
├── providers/                # Riverpod state management
│   ├── stops/               # Stops data management
│   ├── departures/          # Departures data management
│   └── vehicle_position/    # Vehicle position management
├── screens/                  # UI screens
│   ├── stops_screen.dart    # Stops list with search
│   ├── departures_screen.dart # Departures for a stop
│   └── vehicle_map_screen.dart # Vehicle tracking map
├── network/                  # Network layer
│   ├── api_service.dart     # Main API client
│   ├── logger.dart          # Network logging
│   └── endpoints/           # API endpoint definitions
│       ├── stops.dart       # Stops API endpoints
│       ├── departures.dart  # Departures API endpoints
│       └── vehicle_position.dart # Vehicle position endpoints
├── widgets/                  # Reusable UI components
│   ├── empty_container.dart # Empty state widget
│   └── error_widget.dart    # Error display widget
└── extensions/               # Dart extensions
    └── string.dart          # String utility extensions
```

## API Endpoints Used

- `GET /gtfs/stops` - Retrieve all stops
- `GET /public/departureboards` - Get departures for a specific stop
- `GET /public/vehiclepositions/{vehicleId}` - Get vehicle position

## State Management

The application uses **Riverpod** with the latest syntax for state management:

- **StopsNotifier**: Manages stops data with search functionality
- **DeparturesNotifier**: Handles departure data for specific stops
- **VehiclePositionNotifier**: Manages vehicle position with periodic updates

## Dependencies

- **flutter_riverpod**: State management
- **dio**: HTTP client for API calls
- **flutter_map**: OpenStreetMap integration (no API key required)

## Testing

Run the test suite:

```bash
flutter test
```

## Troubleshooting

### Common Issues

1. **API Token Error**: Ensure your token is correctly set in `.env` file
2. **Maps Not Loading**: The app uses OpenStreetMap, no API key is needed
3. **Build Errors**: Run `flutter clean` and `flutter pub get`
