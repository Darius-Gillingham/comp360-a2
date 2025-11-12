# comp360-a2

## Controls:

    W: Accelerate				S: Decelerate
    A: Left				D: Right
    Space: Drift (Takes Practice)	Q: Change POV
    R: Respawn from checkpoint	E: Horn
    Esc: Return to Menu

SAMPLE VIDEO: https://youtu.be/PIgIpeiV4U4

## Assignment Plan/Log:

In our first meeting we split smaller groups to work on specific aspects of the assignment:

Joel & Darius: Track Implementation
Ryan & Aidan: Vehicle Implementation
Robert & Emma: Extra implementation and Design

In assignment 1, the group went above and beyond and made a generated biome per group member. To keep that energy going, we decided to create multiple tracks, and a separate vehicle for each group member. Within each subgroup members were in close communication and broke up tasks further.

Track implementation:
Joel would focus on spline tracks
Darius would focus on a hilbert track

Vehicle implementation:
Aidan would create a player vehicle
Ryan would create opponent vehicles

Design and Additions:
Emma would be in charge of art and design for vehicle interiors
Robert would create particle events for each track

Implementation went smoothly according to plan. In our finalizing meeting on November 11th the group met up and cleaned up a few bugs that occurred when merging work, but quickly finalized the code and had a project every member was proud of.
Git Log: https://github.com/Darius-Gillingham/comp360-a2

## Member Contributions

Aidan (300204053):
Implemented main car functionality.
Added drifting
Imported and aligned 6 car models
Implemented 6 distinct vehicles from parent car
Demo video: https://www.youtube.com/watch?v=H2HX3xXHALw

Darius (300200070):
Created City map using hilbert points
Built the code that created the hilbert curve used in the coastal cliffs map
Demo video: https://www.youtube.com/watch?v=ZKVs9QDkjwg

Emma (300189901):
Designed pixel art for the start menu.
Designed the pixel and implemented the first person mode.
Added horn sound effects to all playable vehicles.
Demo video: https://www.youtube.com/watch?v=lt9wh6wh0TY Volume Warning!!!! Horns are loud.

Joel Algera (300200033):
Created spline tracks over exported meshes from A1 (Dune and Alpine)
Created hilbert curve path (Coastal Cliffs map)
Created start menu functionality to select map and car
Demo video: https://youtu.be/zxC0dZmJY58

Robert Bocsanu (300198372):
Weather/particle effects (Tsunami and Dust Devils)
Checkpoint and respawn system
Helped Aidan prepare car models
Demo video: https://youtu.be/lGflG-T_70Q

Ryan Austin (300211146):
Implemented Opponent cars and collision
Implemented Opponent PathFollow3D behaviour
Implemented randomized opponent models on startup
Implemented Lap Detection, with start/finish line
Demo video: https://www.youtube.com/watch?v=1Gt7nOcWRF8
