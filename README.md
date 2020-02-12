# Bamboo

A posture tracking product. 

Our team at Imperial College London created a smart IoT device that is able to monitor your personal posture information using a flex and compass sensor together with a Raspberry Pi, ultimately providing useful feedback to help improve/condition one's posture habits.

This repository includes all of the software required for the development of the IoT sensor.

## Usage

Begin with a git clone of the repository:
`$ git clone https://github.com/zenasgram/Bamboo.git`

### Directory Layout

    .
    ├── android                           # Android environment configuration files
    ├── assets                            # 3D object source files
    ├── images                            # Rendered png source files (Human & Bamboo Models)
    ├── ios                               # iOS environment configuration files
    ├── lib                               # Top library
    │   ├── components            
    │   │   └── rounded_button.dart       # Refactored code for registration/login button design
    │   ├── models                 
    │   │   ├── mqtt.dart                 # MQTT listening client code
    │   │   └── simulator.dart            # Real-Time firebase code (used for data backup) + software data simulator
    │   ├── screens                     
    │   │   ├── home_screen.dart          # Code for primary UI screen (including the four modes: Home, Music, Sports, Sleep)
    │   │   ├── login_screen.dart         # Code for login - includes Firebase authentication code
    │   │   ├── registration_screen.dart  # Code for registration - includes Firebase authentication code
    │   │   └── welcome_screen.dart       # Code for initial screen on application boot
    │   │  
    │   ├── main.dart                     # Main script that navigates to screens
    │   └── constants.dart                # Source file that stores dictionaries (threshold, sensitivity map, etc.) and constants
    ├── test
    ├── pubspec.yaml                      # Package files (firebase, firestore, syncfusion charts, etc.)
    └── README.md
