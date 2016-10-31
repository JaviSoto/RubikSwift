# RubikSwift
Rubik's cube API in Swift, and an implementation of a [Genetic algorithm](https://en.wikipedia.org/wiki/Genetic_algorithm) to attempt to solve a given scramble of a cube.

### Genetic algorithm

The current implementation is very naive. It doesn't have any understanding of how to solve a cube. It essentially generates random sequences of moves, and calculates the "fitness" of each individual based on the number of pieces that are solved. The best ones are mutated by appending more random moves to the solution.

The [best solution](https://rubiks3x3.com/algorithm/?moves=RBuFBfdl12DlF2BUL5BuR404FbFd4051UfLfD2R24f3F2dlb41dfbul14f31L42U0BLU04fL5Ul10RburLub243b5L3uluR43u01fb0BFl1lr24R&initmove=fBLr41fDRdR4145u2Drf) it's found is solving 16 pieces (out of the 20 in a cube) in 18 minutes. I tried running it for >10h but never got further than that. It's currently able to try ~18k solutions per second.

### Instructions
- Open Xcode project and run the RubikSwiftCLIBundle scheme.

### TODO
This project was simply a weekend fun prototype. If you'd like to use the RubikSwift.framework in your application, I would be happy to add Carthage and/or CocoaPods support to it.
