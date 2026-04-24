## Github and Godot Structure Guide

---

### Part 1: The GitHub Repository Root Structure

Do not just dump the Godot files directly into the base of the GitHub repository. Keep a clean root directory.

```markdown
📦 Kalye404-Repo
 ┣ 📂 game/             <-- Your actual Godot project goes IN here!
 ┃ ┣ 📜 project.godot
 ┃ ┗ 📂 res://          <-- (Godot Structure inside here, see Part 2)
 ┣ 📜 .gitignore        <-- CRITICAL: Must use the Godot 4 standard gitignore
 ┣ 📜 README.md         <-- The Single Source of Truth (SSOT) you already wrote
 ┗ 📜 LICENSE           <-- (Optional) e.g., MIT License
```

**CRITICAL GITHUB STEP:** Godot 4 creates a hidden folder called `.godot/` that stores massive, temporary user files. **You must ignore it.** When creating the repo on GitHub, select "Add .gitignore" and choose the `Godot` template. If you don't, your repo will break on Day 1\.

---

### Part 2: The Godot Project Structure (Vertical Slicing)

Inside your `game/` folder, structure the Godot `res://` directory by **Feature**.

```markdown
📂 res://
 ┣ 📂 core/                 <-- The Engine Room (Project [SYS])
 ┃ ┣ 📂 autoloads/          <-- Global scripts (e.g., GameManager.gd, AudioManager.gd)
 ┃ ┣ 📂 ui/                 <-- Shared Menus (MainMenu.tscn, PauseMenu.tscn)
 ┃ ┗ 📂 transitions/        <-- Loading screens and scene switching logic
 ┃
 ┣ 📂 shared/               <-- Reusable Assets & Entities
 ┃ ┣ 📂 player/             <-- Totoy's scene (player.tscn), script, and sprite sheet
 ┃ ┣ 📂 audio/              <-- Generic sounds (button clicks, UI swooshes)
 ┃ ┗ 📂 fonts/              <-- Global fonts used across all scenes
 ┃
 ┣ 📂 features/             <-- The Vertical Slices (The actual games!)
 ┃ ┣ 📂 overworld/          <-- Project [WORLD]
 ┃ ┃ ┣ 📂 art/              <-- Street tilesets, NPC sprites
 ┃ ┃ ┣ 📜 overworld.tscn    <-- The main map scene
 ┃ ┃ ┗ 📜 npc_dialogue.gd   <-- Scripts only used here
 ┃ ┃
 ┃ ┣ 📂 tumbang_preso/      <-- Project[GAME 1]
 ┃ ┃ ┣ 📂 art/              <-- The Slipper, The Can
 ┃ ┃ ┣ 📜 tumbang_preso.tscn<-- The level scene
 ┃ ┃ ┣ 📜 can_physics.gd    <-- Scripts only used here
 ┃ ┃ ┗ 📜 power_bar.tscn    <-- UI only used here
 ┃ ┃
 ┃ ┣ 📂 patintero/          <-- Project [GAME 2]
 ┃ ┃ ┣ 📜 patintero.tscn    
 ┃ ┃ ┗ 📜 grid_logic.gd     
 ┃ ┃
 ┃ ┗ 📂 luksong_baka/       <-- Project [GAME 3]
 ┃   ┣ 📜 luksong_baka.tscn 
 ┃   ┗ 📜 qte_system.gd     
```

### Why this Vertical Slicing structure is a lifesaver:

1. **Zero Merge Conflicts:**  
   * Coder 1 is assigned to `[WORLD]`. They spend all week exclusively inside `res://features/overworld/`.  
   * Coder 2 is assigned to `[GAME 1]`. They spend all week exclusively inside `res://features/tumbang_preso/`.  
   * Because they are in completely different folders, Git will never overlap their files.  
2. **Asset Cleanliness:** The artist doesn't dump all 500 game images into one giant `assets/` folder. If they draw the *Lata* (Can), they put it exactly where it belongs: `features/tumbang_preso/art/lata.png`.  
3. **Modular Testing (F6):** A coder can open `tumbang_preso.tscn` and hit **F6** (Play Current Scene). Since all the logic, UI, and art it needs are completely contained in that one folder, it will run perfectly without relying on the rest of the game to be finished.  
4. **Matches Linear 1-to-1:** Your GitHub folders literally match your Linear Projects (`[WORLD]`, `[GAME 1]`, `[GAME 2]`). This makes project management incredibly intuitive.

### The "Shared" Rule:

The only time someone leaves their `features/` folder is to use something from `shared/` or `core/`.

* *Example:* If all minigames use the exact same Player Character, you build `player.tscn` inside `shared/player/`. Then, you simply **instance** that player scene into `overworld.tscn` and `tumbang_preso.tscn`.

If you establish this folder structure on Day 1 (put this in a quick "Technical Setup" ticket assigned to the Lead Programmer), your codebase will remain pristine until the final day of the semester.  