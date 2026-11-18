# Hybrid Rendering Pipeline (Unity URP & HLSL)

A custom hybrid rendering pipeline built in Unity **Universal Render Pipeline (URP)** that seamlessly combines traditional polygonal mesh rendering with real-time **procedural raymarching**. 

Implemented via custom **Full-Screen Scriptable Render Features**, the pipeline reads the scene depth/color buffers, executes volumetric and SDF raymarching passes, and writes custom depth back into the buffer—enabling unified lighting, mutual shadow casting, and accurate depth intersection between polygonal meshes and procedural SDF geometry.

---

## Raymarching Environments & Shaders

The project features three distinct, fully procedural 3D raymarching shaders operating in real time alongside standard scene meshes:

1. **Infinite Mountain Terrain & Volumetric Clouds**
   * Procedural infinite terrain generation paired with dense volumetric cloudscapes.
   * Physically inspired light scattering and absorption using the **Beer-Lambert Law**, featuring realistic **silver lining** effects when looking toward the sun.
   * Mutual shadowing and occlusion between polygonal meshes and raymarched terrain/clouds.
<img width="1920" height="1080" alt="Image Sequence_050_0000" src="https://github.com/user-attachments/assets/6802a7e3-3ed1-491c-a6bd-f2d5e1cdfe18" />

2. **Infinite Ocean & Underwater Optics**
   * Dynamic ocean surface driven by **Gerstner waves** with smooth transitions above and below the water surface.
   * Physically based underwater light behavior, including volumetric **god rays (sunbeams)**, **Snell's window** total internal reflection, and depth-based underwater fog/scattering.
<img width="1920" height="1080" alt="Image Sequence_057_0000" src="https://github.com/user-attachments/assets/df3c4dee-7b2f-4720-9711-9fcaf5e7a46f" />

3. **Deep Space, Black Hole & Ice Planet**
   * Procedural cosmic environment featuring an ice planet surrounded by dynamic asteroid rings.
   * **Gravitational lensing** shader simulating spacetime distortion around a black hole.
   * Procedural star acting as the primary scene light source, set against a custom procedural nebula and starfield background (replacing traditional skyboxes).
<img width="1920" height="1080" alt="Image Sequence_054_0000" src="https://github.com/user-attachments/assets/943a3f0a-aca6-46ca-9166-d8156bf6450b" />

---

## Architecture & Dynamic Shader UI System

To keep the R&D framework clean and extensible, the application logic is decoupled using **VContainer (Dependency Injection)** and modular services:

* **Reflection-Based Shader Inspector:** A runtime UI system that dynamically inspects shader properties via reflection and automatically populates layout containers with custom UI component templates (`Float` sliders, `Vector` fields, `Range` controls, and `Color` pickers) bound directly to the active material properties in real time.
* **Scene & State Management:** Instant hot-swapping between full-screen render passes, with built-in controls to reset individual shader parameters or restore default scene states.

---

## Controls

* **`W` / `S`** — Thrust forward / backward
* **`A` / `D`** — Yaw left / right (vertical axis rotation)
* **`Mouse Vertical`** — Pitch (nose up / down)
* **`Mouse Horizontal`** — Roll (axial rotation)
* **`Q`** — Toggle Scene Switcher menu (instant transition between raymarching render features)
* **`E`** — Toggle Real-Time Shader Settings inspector
