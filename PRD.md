# Project Requirements

**Project Name:** (temporary) *Fidel Learn*
**Platform:** Native iOS
**Technology:** Swift + SwiftUI
**Target Users:** Eritrean & Ethiopian diaspora learners

---

# 1. Product Vision

Create a **modern, engaging mobile app** that helps people learn **Tigrinya and Amharic** through interactive lessons, pronunciation practice, and spaced repetition.

The app should feel similar to modern language apps like Duolingo but focused on **Ge'ez-based languages**.

Primary goals:

• Teach **Ge'ez script (Fidel)**
• Teach **basic vocabulary and phrases**
• Improve **reading and pronunciation**
• Provide **offline learning**

---

# 2. Target Audience

## Primary Users

Diaspora Eritreans and Ethiopians who:

* Speak some language but cannot read/write
* Want to learn **Fidel**
* Want to reconnect with culture

Age range:

16–45

---

## Secondary Users

• Children learning the alphabet
• Non-native learners interested in the language
• Travelers

---

# 3. Supported Languages (Phase Plan)

Phase 1:

* Tigrinya

Phase 2:

* Amharic

Phase 3:

* Additional Ethiopian languages

---

# 4. Core Learning Model

The learning structure should follow this progression:

### Stage 1 — Alphabet (Fidel)

Users learn:

* Ge'ez characters
* Consonant + vowel forms
* Pronunciation

Example:

```
ሀ ሁ ሂ ሃ ሄ ህ ሆ
ha hu hi ha he h ə ho
```

---

### Stage 2 — Basic Words

Examples:

```
ሰላም — selam — hello
እማ — ema — mother
ኣቦ — abo — father
```

---

### Stage 3 — Phrases

Examples:

```
ሰላም ከመይ ኣለኻ
Hello how are you
```

---

### Stage 4 — Listening + Speaking

Users:

* Listen to audio
* Repeat phrases
* Record pronunciation

---

# 5. Core Features (MVP)

## 1. Alphabet Lessons (Fidel)

Features:

• Display characters
• Audio pronunciation
• Example word
• Visual grouping

Lesson structure:

```
Lesson 1
ሀ ሁ ሂ ሃ ሄ ህ ሆ
```

---

## 2. Flashcards

Each card includes:

* Letter or word
* English translation
* Audio
* Example sentence

Flashcard actions:

• flip card
• mark as learned
• repeat later

---

## 3. Quizzes

Types of quizzes:

### Multiple Choice

Example:

```
What sound is this?

ሀ

A) ha
B) sa
C) ka
```

---

### Match Letters

```
Match sound → letter
```

---

### Listening Quiz

```
Play audio → choose correct letter
```

---

## 4. Progress Tracking

Track:

* lessons completed
* accuracy
* daily streak
* learned words

Gamification elements:

• streak counter
• levels
• achievements

---

## 5. Offline Learning

All content should work without internet.

Local storage includes:

• lessons
• audio
• vocabulary

---

# 6. Audio System

Every letter and word should have **native speaker audio**.

Example:

```
Word
ሰላም

English
Hello

Audio
▶️ play
```

Audio requirements:

• clear pronunciation
• slow speed
• normal speed

---

# 7. App Structure

Main navigation tabs:

```
Home
Lessons
Practice
Progress
Settings
```

---

## Home

Displays:

• daily goal
• streak
• continue lesson

---

## Lessons

Displays:

Course path

Example:

```
Alphabet
Words
Phrases
Listening
```

---

## Practice

Extra training:

• flashcards
• quizzes
• pronunciation

---

## Progress

Shows:

• words learned
• lessons completed
• streak

---

## Settings

Options:

• language selection
• audio speed
• dark mode

---

# 8. Design Requirements

Design principles:

• clean interface
• minimal distractions
• large readable Fidel text

Typography:

Fidel characters must be **large and clear**.

Recommended fonts:

• Noto Sans Ethiopic
• Abyssinica SIL

---

# 9. Data Model

Example lesson structure:

```
Lesson
 id
 title
 type
 order
```

Example word:

```
Word
 id
 fidel
 transliteration
 translation
 audio
 lesson_id
```

Example progress:

```
UserProgress
 lesson_id
 completed
 score
```

---

# 10. Technical Architecture

Recommended stack:

Frontend:

SwiftUI

Local database:

CoreData or SQLite

Audio:

AVFoundation

Data format:

JSON

---

# 11. Performance Requirements

App must:

• load in under 2 seconds
• work fully offline
• run smoothly on older iPhones

Minimum iOS version:

iOS 16+

---

# 12. Monetization (Optional)

Possible models:

Freemium:

Free:

* alphabet lessons
* basic words

Premium:

* full course
* pronunciation tools
* advanced lessons

Subscription example:

$3–5 / month

---

# 13. MVP Scope (First Release)

Version 1 should include:

• Tigrinya alphabet lessons
• 100 vocabulary words
• audio pronunciation
• flashcards
• quizzes
• progress tracking

---

# 14. Success Metrics

Track:

• daily active users
• lessons completed
• retention rate
• streak length

---

# 15. Future Features

After MVP:

• handwriting practice
• speech recognition
• multiplayer learning
• AI tutor
• Android version

---

## Next Steps

1. **Full SwiftUI project structure** (like a real startup)
2. **Full Tigrinya Fidel dataset** (231 characters)
3. **Lesson design** (Duolingo-style)
4. **Build with Cursor** (10× faster)
