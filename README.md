# Real-Time Location Tracker (Flutter)

A real-time location tracking application built with Flutter, Google Maps, and Geolocator.

## Key Features Implemented:
1. **Real-time Periodic Updates:** Fetches user location every 10 seconds via `Geolocator`.
2. **Camera Animation:** Automatically animates the Google Map camera to the user's latest coordinates.
3. **Continuous Polyline Tracking:** Stores location history and connects coordinates sequentially with blue polylines.
4. **Interactive Marker & Info Window:** Displays a custom marker with the title "My current location" and real-time latitude/longitude coordinates on tap.
5. **Crash-Resistant Implementation:** Integrated timeout handling and fallback location coordination to prevent UI thread freezing.

## App Screenshots:
|       Polyline Tracking        |        Marker Info Window         |
|:------------------------------:|:---------------------------------:|
| ![Tracking Screenshot](ss1.png) | ![InfoWindow Screenshot](ss2.png) |

> **Note on Map Rendering:** The complete logic and APIs are fully integrated. In local emulator environments without an active Google Cloud billing profile, map vector tiles may show a watermark/placeholder while all internal tracking logic, coordinates, polylines, and markers execute successfully.