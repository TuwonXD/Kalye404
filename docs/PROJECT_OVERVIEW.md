# Game Project Overview  

## 1. Project Title: Kalye 404

## 2. Game Concept

### 2.1 Storyline

In an enclosed world with never-ending screen time, a shy gadget-obsessed boy thought that his summer was ruined when The Great WiFi Outage struck his new neighborhood. Being forced out of his cave by his mother's classic command to buy vinegar at the nearby sari-sari store, he hesitantly steps outside and is instantly hit by a wave of lively, chaotic energy—sounds of laughter, squeak of rubber shoes, and clatter of tin cans. Before he can even reach the store, a ragged tsinelas lands at his feet, followed by an energetic voice: "'Ya, pa-abot nga! Sali ka?" Swept into an unexpected whirlwind of throwing and running, he eventually stumbles back home drenched in sweat, clutching the vinegar and preparing for a scolding. Instead, his mother simply takes the bottle with a secret smile, unknowingly witnessing the birth of a new outdoor adventurer: a hopeful kid named Totoy, who will soon carve his name into the legendary streets of Kalye 404.

Hooked to the thrill, the laughter, and his new friend's exciting stories about the reigning Kalye Champions, Totoy enthusiastically steps out the door the next day, leaving his gadget behind. Throughout his journey, he encounters various Kalye Challenges where he faces highly skilled champions in fun games of Tumbang Preso, Patintero, and Luksong Baka. Victory earns him rare Kalye Treasures and access to new areas, but losing is never a complete defeat; it just means a short break to catch his breath and to drink a cold palamig before trying again. With this, Totoy must adapt and hone his agility, strategy, and wits to defeat the champions; ultimately leading to a realization that even when the WiFi finally comes back to life, the greatest adventures happen right outside his door—or more specifically, in Kalye 404.

### 2.2 Visual Concept

The provided visual conceptualizes "Kalye 404," a nostalgic adventure game where the player embarks on a journey to become the ultimate street game champion of their barangay. As depicted in the mockup, the core gameplay is driven by mastering a series of classic Filipino childhood games—specifically Tumbang Preso, Patintero, and Luksong Baka. Each game functions as a distinct mechanical challenge that the player must overcome while interacting with the neighborhood environment. By successfully competing against local rivals in these interconnected events, the player steadily builds their reputation, honing their timing and strategic movement to ultimately achieve the main objective of being recognized as the undisputed best kid on the street.

### 3. Goal of the Game

**Main Objective:**
Help Totoy become the Kalye 404 Champion (a.k.a. “the very best”) by progressing through the neighborhood and clearing each Kalye Challenge (Tumbang Preso, Patintero, and Luksong Baka). For each challenge, Totoy must defeat other Kalye Kids first before earning the right to face that game’s Kalye Champion.

**Game Start Condition:**
A new game begins right after The Great WiFi Outage, when Totoy steps into Kalye 404 for the first time. The player starts in an explorable map, where Totoy can move around and trigger mini-game events by talking to Kalye Kids. Interacting with a Kalye Kid transitions the game into that specific mini-game challenge.

**Win Condition:**
The player wins the game when Totoy has won all required mini-games by following each mini-game’s unique rules and win conditions, and has defeated all Kalye Champions. Champions can only be challenged after Totoy has beaten the other Kalye Kids/opponents for that mini-game (earning eligibility). After clearing all champions across all challenges, Totoy is recognized as the “very best” in Kalye 404\.

**Lose Condition (Game Over):**
A Game Over happens when the player fails the current Kalye Challenge’s fail state (example: stamina reaches 0 in Patintero, lives run out in Luksong Baka, or the challenge-specific failure condition is met). When this happens, the player retries; losing is a setback, not a permanent end of the entire game.

### 4. Genre of the Game

**Selected Genre:** Action-Adventure  
**Reason for Choosing the Genre:**  
Kalye 404 fits Action-Adventure because the player progresses through an adventure structure: exploring the neighborhood, meeting Kalye Kids, unlocking new areas, and collecting Kalye Treasures. At the same time, the core challenges focus on action-based skill and quick execution. For example, Tumbang Preso emphasizes timing and precision through power bars, Patintero tests fast and correct input sequences after observation, and Luksong Baka incorporates a Quick Time Event jumping challenge where Totoy must rapidly input key sequences to clear an obstacle.

## 5. Core Game Mechanics

### 5.1 Exploration Mechanic

**Visual Aesthetic: The HD-2D Barangay**

Kalye 404 utilizes a striking "HD-2D" (or 2.5D) visual style, heavily inspired by titles like *Octopath Traveler* and *Until Then*. This aesthetic marries the nostalgic charm of classic 2D pixel-art characters with modern, dynamic 3D environments and lighting. The game world is a lovingly crafted representation of a typical Filipino barangay. Players will navigate streets bathed in the warm, atmospheric glow of late afternoon suns and flickering streetlights, passing by highly detailed environmental set pieces such as bustling sari-sari stores, parked jeepneys, and tangled electric posts. The juxtaposition of flat, expressive 2D sprites against a layered, depth-rich background creates a cinematic and deeply immersive local setting.

**Exploration and Navigation**

Between the high-stakes street game events, the core gameplay loop relies on free-roaming exploration. The player controls Totoy from a fixed-angle perspective that emphasizes the depth of the street. Rather than moving on a flat plane, the character navigates a 3D-feeling space, able to walk "into" the background or towards the camera, allowing for layered level design with interactive foreground and background elements. This spatial depth encourages players to explore every narrow *eskinita* (alleyway) and street corner of the neighborhood.

**Interactive Environment and Progression**

The barangay serves as the central hub and the narrative connective tissue of the game. Exploration is not just for visual enjoyment; it is how the player progresses. Totoy must roam the streets to scout for potential challengers, converse with other neighborhood kids to gather tips or lore, and locate the specific "arenas" where games of Tumbang Preso, Patintero, or Luksong Baka are taking place. By wandering the neighborhood, players soak in the atmosphere and organically discover the next step in their journey to become the ultimate street game champion.

### 5.2 Tumbang Preso Mechanic

**Game Perspective and Objective** 

The game is played in a fixed 2D “behind-the-back” perspective. The objective is to be the first to score 5 hits on the can (i.e., win 5 rounds).

**Turn Order**

Totoy (the player) always takes the first turn as the Thrower, since he is the challenger initiating the match.

**Core Loop**

Each round has two roles: Thrower and Taya (guard). The player and the computer take turns being the Thrower/Taya.

1. **Throw Phase (Thrower’s turn)**. The Thrower attempts to knock down the can using two timing-based power bars: 
   - **Power Bar 1:** Strength (throw force) – determines how strong/far the throw goes.
   - **Power Bar 2:** Accuracy (throw direction) – determines how accurate the throw is toward the can.
   - Each power bar has two colored zones and a moving arrow/indicator; stopping the arrow in the better zone results in a better throw (stronger and/or more accurate).

2. **Opponent Accuracy Stat (AI Advantage/Variation)**. Each opponent has an Accuracy Stat that affects their performance when they are the Thrower. Higher accuracy opponents have a better chance of landing in the “good” zone (or a smaller penalty for landing in the “bad” zone), making their throws more consistent and harder to beat.

3. **Hit Check**
   - If the throw **hits** the can: the Thrower scores 1 point (1 round win).
   - If the throw **misses**: the Thrower gets a chance to escape.

4. **Escape Phase**. After a miss, an Escape Power Bar appears that determines the success rate of escaping for another attempt in the same round.
   - **Escape Success:** The Thrower successfully escapes and gets another throw attempt for that round.
   - **Escape Failure:** The Thrower fails to escape and becomes the Taya; the other side becomes the Thrower.

5. **Role Swap**. If the computer is the Thrower and misses, the player is also given the same Escape Power Bar to determine whether the computer escapes (and gets another attempt) or gets caught (swap roles).

**Success and Failure**
   - **Round Win**: Knocking down the can counts as 1 hit.
   - **Match Win Condition:** First to 5 hits wins the Tumbang Preso challenge.
   - **Failure:** Missing does not immediately lose the match; it triggers the Escape phase, and failure to escape causes a role swap (momentum shift).

**Difficulty Scaling**

Difficulty increases across levels by: 

- (1) speeding up the arrows on the Strength/Accuracy/Escape power bars,
- (2) shrinking the “good” colored zones,
- (3) requiring higher accuracy (stricter hit detection),
- (4) facing opponents with higher Accuracy Stats.

### 5.3 Patintero Mechanic

**Game Perspective and Objective**

The game is played from a fixed 2D "behind-the-back" perspective. The player character is positioned at the bottom of the screen, and must cross three to four horizontal lines guarded by an opponent. To win the challenge, the player must successfully cross all lines to reach the finish area.

**Core Loop**

To cross a line guarded by an opponent, the player enters a "Duel" consisting of one to three memory rounds. Each round has two phases:

1. **Observation Phase.** A directional sequence (Up, Down, Left, Right) appears for a limited duration, between 2 to 4 seconds.
2. **Execution Phase.** Once the icons vanish, the player must correctly input the memorized sequence within a time limit.

**Success and Failure**

- **Success:** Completing all required rounds for a line allows the player to advance to the next zone.
- **Failure:** Inputting an incorrect key or failing to complete the sequence within the  timer results in a tag. Upon being tagged, the player loses stamina and is pushed back to the start of the current line. If the stamina reaches zero, the Patintero challenge is declared “Game Over” and the player must retry.

**Difficulty Scaling**

Difficulty increases across levels by: 

- (1) increasing the number of directional inputs from four to six or more keys,
- (2) reducing the time that the icons are visible during the Observation phase,
- (3) increasing the number of memory rounds required to clear a single line. 

### 5.4 Luksong Baka Mechanic

**Game Perspective and Objective**

The game is played from a fixed 2D side-view perspective. Totoy approaches the "Baka" (the crouching opponent) from the left side of the screen and must successfully jump over them. The objective is to clear a set number of jumps to win the challenge.

**Core Loop**

As Totoy approaches the Baka, a Quick Time Event (QTE) prompt appears on screen. The player must press the correct key sequence within the given time window to execute the jump.

1. **Approach Phase:** Totoy automatically walks toward the Baka. A prompt appears as he nears the jump point.

2. **Jump Phase:**
    - **Success:** Totoy clears the Baka and scores 1 point. The Baka rises slightly for the next attempt.
    - **Failure:** Totoy collides with the Baka and loses 1 life. The current attempt resets at the same height.

**Success and Failure**

- **Round Win:** Successfully clearing the Baka counts as 1 point.

- **Match Win Condition:** Scoring 5 successful jumps wins the Luksong Baka challenge.

- **Failure:** Each collision costs 1 life. Losing all 3 lives results in a Game Over and the player is sent back to Level 1.

**Difficulty Scaling**

Difficulty increases across levels by: 

- (1) shortening the QTE input time window,
- (2) increasing the number of keys in the sequence,
- (3) raising the Baka's starting height so the jump window is tighter from the beginning.

## 6. Gameplay Structure and Scope

### Game Type

Single-player semi-open world with per-challenge level progression.

### Main Gameplay Loop

- Totoy explores Barangay 404 on foot to locate opponents across the streets.
- Upon finding a Kalye Challenge for the first time, a one-time Tutorial Grunt introduces Totoy to the mechanics of that challenge.
- After the tutorial, the actual progression begins: Bronze Grunt → Silver Grunt → Champion.
- Winning advances Totoy to the next tier. Losing resets only the current tier; Totoy retries from exactly where he failed.
- Defeating the Champion of a challenge clears it and unlocks new areas of Barangay 404.
- The game is completed when all three Champions across all three Kalye Challenges are defeated.

### Scope Limitations

- Exploration is rendered in a 2.5D perspective, where the world has depth but characters and objects remain 2D sprites.
- All Kalye Challenge mini-games are strictly 2D.
- Simple keyboard controls.
- Semi-open world exploration between challenges.
- Three independent challenge progressions, each with a one-time tutorial and three difficulty tiers (Bronze, Silver, Champion).
- Losing at any tier resets only that tier, not the full challenge progression.
- All interactive opponents are computer-controlled.
- Cutscenes and story segments are limited to static dialogue boxes.

## 7. Target Platform

**Platform:** Desktop Computer or Laptop

**Reason:** The core mechanics across all three Kalye Challenges rely on precise and responsive keyboard inputs, such as timing-based power bars, sequential key presses, and QTE prompts. A keyboard provides the accuracy and speed these inputs require. Desktop is also the most accessible platform for the target audience and aligns with Godot's primary development and export workflow for both the 2.5D exploration and 2D mini-game components.