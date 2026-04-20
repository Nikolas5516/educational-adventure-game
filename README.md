# Geography Learning App

An interactive 2D educational game for fourth-grade pupils to learn geography through play. Built with the Godot Engine as a mobile-first tablet application used during classroom sessions.

## About

This app was developed as part of a team project at Babeș-Bolyai University. The game turns geography lessons into engaging mini-games that pupils play on tablets during class, making learning interactive and fun.

## Features

- **12 Educational Games** across 3 difficulty levels (Easy, Medium, Hard)
- **4 games per level**, with the 4th being a special challenge round for that difficulty
- **Progressive difficulty** — pupils advance through levels as they master content
- **Mobile-optimized** — designed for tablets used in classroom settings
- **Dynamic scene management** — smooth transitions between games and menus
- **JSON-based data** — questions and content loaded from external data files for easy updates

## Tech Stack

- **Engine:** Godot Engine
- **Language:** GDScript
- **Data:** JSON (questions, game configurations)
- **Version Control:** Git/GitHub

## Game Structure

```
Easy Level
├── Game 1
├── Game 2
├── Game 3 
└── Game 4 — Special Challenge
Medium Level
├── Game 5 
├── Game 6
├── Game 7
└── Game 8 — Special Challenge
Hard Level
├── Game 9
├── Game 10
├── Game 11
└── Game 12 — Special Challenge
```

## How to Run

### Prerequisites
- [Godot Engine 4.x](https://godotengine.org/download)

### Steps

1. Clone the repository:
```bash
   git clone https://github.com/Nikolas5516/ioc-learning-app.git
```
2. Open Godot Engine
3. Click **Import** → navigate to the cloned folder → select `project.godot`
4. Click **Run** (F5) to launch the app

For mobile testing, use Godot's **Remote Debug** feature or export to Android.

## Team

Developed by a team of 10 at Babeș-Bolyai University. Project managed using **Scrum** methodology with regular sprint reviews and stakeholder feedback from educators.

## License

This project was developed for educational purposes at Babeș-Bolyai University.