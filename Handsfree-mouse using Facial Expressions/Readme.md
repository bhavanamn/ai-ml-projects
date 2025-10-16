# 🖱️ Hands-Free Mouse Using Facial Expressions  
### *Empowering Physically Disabled Individuals through Human-Computer Interaction (HCI)*  


Published in: *Proceedings of the Fourth International Conference on Sentiment Analysis and Deep Learning (ICSADL 2025)*  

---

## 🧭 Abstract  

This project presents the design and implementation of a **Hands-Free Mouse System** based on **facial expression recognition**, aimed at enabling **physically disabled users** to interact with computers without traditional input devices.  

Leveraging **computer vision** and **machine learning**, the system interprets **facial movements**—such as blinking, head tilts, and mouth openings—to simulate mouse actions like cursor movement, clicks, and scrolling.  

The solution enhances **accessibility**, **inclusivity**, and **independence** for users with limited physical mobility.

---

---

## 🧩 System Overview  

### 🧠 Core Idea
The system uses a **webcam feed** to detect and track **facial landmarks** (eyes, nose, mouth, and head position).  
By recognizing specific gestures, it simulates equivalent **mouse operations** using Python automation libraries.

| User Action | System Response |
|--------------|----------------|
| 👃 Nose Movement | Cursor Movement |
| 👁️ Left Eye Blink | Left Click |
| 👁️ Right Eye Blink | Right Click |
| 🤕 Head Tilt Left | Scroll Up |
| 🤕 Head Tilt Right | Scroll Down |
| 👄 Mouth Open | Double Click |

---

## ⚙️ Implementation Details  

### 🔹 Algorithms and Techniques  

1. **OpenCV** – Captures real-time webcam video frames and performs image processing (BGR→RGB conversion, landmark visualization).  
2. **MediaPipe FaceMesh** – Detects and tracks **468 facial landmarks** using a deep learning model.  
3. **PyAutoGUI** – Simulates system-level mouse movements, clicks, and scroll events.  
4. **PyQt5 GUI** – Provides a user interface for controlling tracking and viewing camera feedback.  
5. **Eye Aspect Ratio (EAR)** – Detects eye blinks by analyzing the vertical/horizontal distances between eye landmarks.  
6. **Head Tilt Detection (Angle Calculation)** – Calculates the head’s angular deviation using trigonometric ratios of facial key points.  
7. **SpeechRecognition (Google Web Speech API)** – Converts voice to text for hands-free typing and extended functionality.  

---

## 💻 System Architecture  

```plaintext
Webcam Input
     │
     ▼
Facial Landmark Detection (MediaPipe)
     │
     ├──> Blink Detection (EAR)
     ├──> Head Tilt Detection (Angle Calculation)
     ├──> Mouth Movement Detection
     │
     ▼
Action Mapping (PyAutoGUI)
     │
     ▼
Mouse / Scroll / Click / Typing Control
