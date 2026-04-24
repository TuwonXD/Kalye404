# 🕹️ Kalye 404

**By CONE Dev Studios**  
*A Filipino Street Game Adventure built in Godot.*

Welcome to the central repository for *Kalye 404*. This README serves as our team's **Single Source of Truth (SSOT)**. Before asking the group chat for a link, check here first\!

---

## 🔗 Quick Links (The Hub)

*All accounts are registered under our studio email: \[Insert Studio Email\]@gmail.com*

* 📋 [**Linear.app Workspace**](https://linear.app/cone-dev-studios) \- *Our Kanban board and task tracker.*  
* 📁 [**Team Google Drive**](https://drive.google.com/drive/folders/1xxWkBDLYabxXcrxaDjitqCLqELrfxaj0?usp=sharing) \- *Academic and source files*  
* 📄 [**Game Project Overview**](https://docs.google.com/document/d/12LCyUtx4hG50ccHe9Sev0zDepzpY5AP8ezod2DS_4Mo/edit?usp=sharing) \- *Google Doc of our mechanics and scope.*

---

## 📖 Project Overview

**The Story:** After *The Great WiFi Outage* forces him out of his room and onto the streets of his new neighborhood, a shy gadget-obsessed kid named **Totoy** is swept into a world of laughter, flying tsinelas, and clattering tin cans. What starts as a simple errand to the sari-sari store becomes the beginning of his journey to become the undisputed champion of **Kalye 404**.

**The Goal:** Help Totoy progress through the neighborhood, defeating Kalye Kids and their Champions across three classic Filipino street games:

| Mini-Game | Mechanic |
|---|---|
| 🥿 **Tumbang Preso** | Timing-based power bars (Strength & Accuracy) |
| 🏃 **Patintero** | Memory sequence observation & recall |
| 🐄 **Luksong Baka** | Quick Time Event (QTE) key sequences |

For each game, Totoy must beat the **Bronze Grunt → Silver Grunt → Champion**. Defeating all three Champions wins the game.

**Tech Stack & Constraints:**

* **Engine:** Godot 4.6  
* **Target Hardware:** Low-end laptops (ThinkPad T14 i5 / Integrated Graphics)  
* **Art Style:** 2.5D (HD-2D style overworld with Billboard Sprites)

---

## 🛠️ Getting Started (Coder Workflow)

To keep our codebase clean and prevent merge conflicts, all coders must follow this Git workflow:

1. **Never push directly to `main`.**  
2. **Claim your task:** Assign yourself a ticket in Linear (e.g., `CONE-14`).  
3. **Create a branch:** Name it based on the Linear ticket: `git checkout -b feature/CONE-14-throw-physics`  
4. **Commit often:** Write clear commit messages.  
5. **Pull Requests (PR):** When opening a PR on GitHub, you MUST include this exact phrase in the description: `Resolves CONE-14` *(This tells GitHub to tell Linear to automatically move your ticket to "In Review" and "Done" when merged\!)*  
6. **Review:** Another team member must approve the PR before it gets merged.

---

## 🎨 Asset Pipeline Rules

Do **NOT** upload heavy raw files to GitHub. It will bloat our repository and slow down our laptops.

* **Google Drive gets RAW files:** Put your `.psd`, `.aseprite`, `.blend`, or Audacity projects in the Google Drive folder.  
* **GitHub gets GAME files:** Only push final, lightweight `.png`, `.wav`, or `.ogg` files into the Godot `res://assets/...` folders.