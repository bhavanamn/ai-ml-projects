# 🧪 Flaw Detection System – Reactor Engineering Division

A **GUI-based flaw detection and reporting system** designed for industrial and research use in **Reactor Engineering**.  
This application performs **image-based flaw detection**, **depth estimation**, and **automatic PDF report generation** — combining **computer vision**, **data analysis**, and **visualization** in one unified tool.

---

## 🧭 Overview

This project automates the **flaw inspection process** by allowing users to:
- Load flaw images
- Process and analyze them
- Visualize results in **2D and 3D**
- Automatically **generate PDF reports** containing plots and summary tables.

It provides engineers and researchers a fast, reliable, and non-destructive way to inspect surface defects and document results.

---

## 🧠 Key Features

| Feature | Description |
|----------|-------------|
| 🖼️ **Image Import & Preprocessing** | Load single or multiple images; resizing, blurring, and thresholding applied automatically. |
| ⚙️ **Flaw Detection Pipeline** | Applies **Gaussian blur**, **thresholding**, and **peak detection** to locate and analyze surface flaws. |
| 📊 **3D Visualization** | Generates **interactive 3D surface plots** showing flaw intensity and topology. |
| 📈 **2D Depth Profiles** | Displays smoothed **depth vs. position graphs** for detailed analysis. |
| 🔍 **Peak Analysis** | Detects flaw boundaries, computes average depths, and highlights affected areas. |
| 📑 **Automated PDF Report Generation** | Exports a structured PDF with flaw summary tables and embedded graphs. |
| 💾 **Auto Image Storage** | Saves all processed and resized images in the output directory. |

---

## 🧰 Technologies Used

| Category | Tools / Libraries |
|-----------|------------------|
| **Language** | Python 3 |
| **GUI** | PyQt5 |
| **Image Processing** | OpenCV |
| **Mathematics & Analysis** | NumPy, SciPy |
| **Visualization** | Matplotlib (2D + 3D) |
| **Reporting** | ReportLab |
| **Data Management** | Pandas |

---

Screenshots:

<img width="350"  alt="image" src="https://github.com/user-attachments/assets/657ba988-d4f0-420b-954c-0c3ca0d116eb">




LaserLight Flaw Images:


<img width="959" alt="image" src="https://github.com/user-attachments/assets/0bd30ec4-57b3-4fae-916f-fa0e6efb66f4">
<img width="320" alt="image" src="https://github.com/user-attachments/assets/b11756b9-0844-41d0-a1ed-7ba184fb0475">
<img width="398" alt="image" src="https://github.com/user-attachments/assets/b73ab3bb-f458-41d7-92c7-975c92463bb6">


<img width="622" alt="image" src="https://github.com/user-attachments/assets/6f98e899-0ab1-4b56-b08c-965a3fde45db">





